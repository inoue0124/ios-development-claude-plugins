# Feature Module テンプレート詳細（Swift 6.2 / SwiftUI）

## View テンプレート

### 標準パターン

```swift
import SwiftUI

struct <Feature名>View: View {
    @State private var viewModel: <Feature名>ViewModel

    init(viewModel: <Feature名>ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                contentView
            }
        }
        .task {
            await viewModel.fetch()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        Text("Hello, <Feature名>")
    }
}

#Preview {
    <Feature名>View(
        viewModel: <Feature名>ViewModel(
            repository: <Feature名>RepositoryMock()
        )
    )
}
```

### ナビゲーション付きパターン

```swift
import SwiftUI

struct <Feature名>View: View {
    @State private var viewModel: <Feature名>ViewModel

    init(viewModel: <Feature名>ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("<Feature名>")
                .task {
                    await viewModel.fetch()
                }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        // TODO: コンテンツを実装
        Text("Hello, <Feature名>")
    }
}
```

### リスト表示パターン

```swift
import SwiftUI

struct <Feature名>ListView: View {
    @State private var viewModel: <Feature名>ListViewModel

    init(viewModel: <Feature名>ListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.items) { item in
            <Feature名>RowView(item: item)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.fetch()
        }
    }
}
```

## ViewModel テンプレート

### 標準パターン

```swift
import Foundation

@Observable
class <Feature名>ViewModel {
    // MARK: - State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let repository: <Feature名>RepositoryProtocol

    // MARK: - Init

    init(repository: <Feature名>RepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    func fetch() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // TODO: データ取得処理を実装
            _ = try await repository.fetch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### UseCase 経由パターン

```swift
import Foundation

@Observable
class <Feature名>ViewModel {
    // MARK: - State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let fetchUseCase: Fetch<Feature名>UseCaseProtocol

    // MARK: - Init

    init(fetchUseCase: Fetch<Feature名>UseCaseProtocol) {
        self.fetchUseCase = fetchUseCase
    }

    // MARK: - Actions

    func fetch() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await fetchUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

## Repository テンプレート

### Protocol

```swift
import Foundation

protocol <Feature名>RepositoryProtocol: Sendable {
    func fetch() async throws -> <Feature名>Model
    func save(_ model: <Feature名>Model) async throws
    func delete(id: String) async throws
}
```

### 具象実装（URLSession ベース）

```swift
import Foundation

final class <Feature名>Repository: <Feature名>RepositoryProtocol {
    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func fetch() async throws -> <Feature名>Model {
        let url = baseURL.appendingPathComponent("<endpoint>")
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(<Feature名>Model.self, from: data)
    }

    func save(_ model: <Feature名>Model) async throws {
        // TODO: POST/PUT リクエスト
    }

    func delete(id: String) async throws {
        // TODO: DELETE リクエスト
    }
}
```

### モック（テスト・プレビュー用）

```swift
import Foundation

final class <Feature名>RepositoryMock: <Feature名>RepositoryProtocol {
    var fetchResult: Result<<Feature名>Model, Error> = .success(.mock)

    func fetch() async throws -> <Feature名>Model {
        return try fetchResult.get()
    }

    func save(_ model: <Feature名>Model) async throws {}

    func delete(id: String) async throws {}
}
```

## UseCase テンプレート

```swift
import Foundation

protocol Fetch<Feature名>UseCaseProtocol: Sendable {
    func execute() async throws -> <Feature名>Model
}

final class Fetch<Feature名>UseCase: Fetch<Feature名>UseCaseProtocol, Sendable {
    private let repository: <Feature名>RepositoryProtocol

    init(repository: <Feature名>RepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> <Feature名>Model {
        return try await repository.fetch()
    }
}
```

## DI テンプレート

### Environment ベースの依存注入

```swift
import SwiftUI

struct <Feature名>Dependency {
    let repository: <Feature名>RepositoryProtocol
    let viewModel: <Feature名>ViewModel

    static func resolve() -> <Feature名>Dependency {
        let repository = <Feature名>Repository()
        let viewModel = <Feature名>ViewModel(repository: repository)
        return <Feature名>Dependency(repository: repository, viewModel: viewModel)
    }
}

private struct <Feature名>DependencyKey: EnvironmentKey {
    static let defaultValue: <Feature名>Dependency = .resolve()
}

extension EnvironmentValues {
    var <feature名Camel>Dependency: <Feature名>Dependency {
        get { self[<Feature名>DependencyKey.self] }
        set { self[<Feature名>DependencyKey.self] = newValue }
    }
}
```

## 新旧パターン対照表（レガシー → 推奨の移行ガイド）

以下は非推奨（旧）パターンと推奨（新）パターンの対照表。旧パターンは使わない。

| 旧（非推奨） | 新（推奨） | 理由 |
|---|---|---|
| `class VM: ObservableObject` | `@Observable class VM` | Observation フレームワーク |
| `@Published var` | `var` | `@Observable` では不要 |
| `@StateObject private var vm` | `@State private var vm` | 新しいオーナーシップ API |
| `@ObservedObject var vm`（旧・非推奨） | `var vm` or `@Bindable var vm` | バインディング要否で選択 |
| `@EnvironmentObject var`（旧・非推奨） | `@Environment(Type.self) var` | 型安全な環境注入 |
| `PreviewProvider`（旧・非推奨） | `#Preview` | マクロベースのプレビュー |
