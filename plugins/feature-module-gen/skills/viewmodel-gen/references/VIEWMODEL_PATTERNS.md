# ViewModel パターン集（Swift 6.2 / @Observable）

## 基本パターン

### 最小構成

```swift
import Foundation

@Observable
class SimpleViewModel {
    var isLoading: Bool = false
    var errorMessage: String?

    private let repository: SimpleRepositoryProtocol

    init(repository: SimpleRepositoryProtocol) {
        self.repository = repository
    }

    func fetch() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // データ取得
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## Input / Output パターン

責務が複雑な ViewModel で、ユーザーアクション（Input）と画面状態（Output）を明確に分離する。

```swift
import Foundation

@Observable
class UserListViewModel {
    // MARK: - Output (State)

    var users: [User] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var hasMorePages: Bool = true

    // MARK: - Private State

    private var currentPage: Int = 0

    // MARK: - Dependencies

    private let repository: UserRepositoryProtocol

    // MARK: - Init

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Input (Actions)

    func onAppear() async {
        await fetchInitialPage()
    }

    func onRefresh() async {
        currentPage = 0
        users = []
        await fetchInitialPage()
    }

    func onLoadMore() async {
        guard !isLoading, hasMorePages else { return }
        currentPage += 1
        await fetchPage(currentPage)
    }

    func onUserTapped(_ user: User) {
        // ナビゲーション処理
    }

    // MARK: - Private

    private func fetchInitialPage() async {
        await fetchPage(0)
    }

    private func fetchPage(_ page: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await repository.fetchUsers(page: page)
            users.append(contentsOf: result.users)
            hasMorePages = result.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## UseCase 経由パターン

ViewModel が Repository に直接依存せず、UseCase を介してビジネスロジックを呼び出す。

```swift
import Foundation

@Observable
class OrderViewModel {
    var order: Order?
    var isLoading: Bool = false
    var errorMessage: String?

    private let fetchOrderUseCase: FetchOrderUseCaseProtocol
    private let cancelOrderUseCase: CancelOrderUseCaseProtocol

    init(
        fetchOrderUseCase: FetchOrderUseCaseProtocol,
        cancelOrderUseCase: CancelOrderUseCaseProtocol
    ) {
        self.fetchOrderUseCase = fetchOrderUseCase
        self.cancelOrderUseCase = cancelOrderUseCase
    }

    func fetch(orderId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            order = try await fetchOrderUseCase.execute(id: orderId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancel() async {
        guard let order else { return }
        do {
            try await cancelOrderUseCase.execute(id: order.id)
            self.order = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## @MainActor パターン

UI 更新が頻繁に発生する ViewModel では `@MainActor` でクラス全体を保護する。

```swift
import Foundation

@MainActor
@Observable
class RealTimeViewModel {
    var messages: [Message] = []
    var connectionStatus: ConnectionStatus = .disconnected

    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func startListening() async {
        connectionStatus = .connected
        for await message in repository.messageStream() {
            messages.append(message)
        }
    }
}
```

## レガシーからの移行

| 旧（非推奨） | 新（推奨） |
|---|---|
| `class VM: ObservableObject` | `@Observable class VM` |
| `@Published var name = ""` | `var name = ""` |
| `objectWillChange.send()` | 不要（自動追跡） |
| `$viewModel.name` (from @Published) | `$viewModel.name` (from @Bindable) |
