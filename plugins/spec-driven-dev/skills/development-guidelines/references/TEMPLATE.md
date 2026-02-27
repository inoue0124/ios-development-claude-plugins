# 開発ガイドラインテンプレート

以下のテンプレートに従って `docs/development-guidelines.md` を生成する。

---

```markdown
# 開発ガイドライン

> 生成日時: YYYY-MM-DD
> ステータス: Draft
> 入力: docs/product-requirements.md, docs/architecture.md, docs/repository-structure.md, CLAUDE.md

## 1. コーディング規約

### 1.1 命名規則（Swift API Design Guidelines 準拠）

| 対象 | 規則 | 例 |
|---|---|---|
| 型名 | UpperCamelCase | `HomeViewModel`, `ItemRepository` |
| メソッド名 | lowerCamelCase | `fetchItems()`, `loadMore()` |
| 変数名 | lowerCamelCase | `itemCount`, `isLoading` |
| Boolean | is / has / can / should プレフィックス | `isLoading`, `hasMore`, `canEdit` |
| Protocol | -able / -ible / -ing サフィックス または名詞 | `Sendable`, `ItemRepositoryProtocol` |
| ファイル名 | 主要型名と一致 | `HomeViewModel.swift` |

### 1.2 ファイル構成

- 1 ファイル 1 型を原則とする
- View は `View/` ディレクトリに配置
- ViewModel は `ViewModel/` ディレクトリに配置
- 拡張は `Extensions/` ディレクトリに配置

### 1.3 アクセスコントロール

| レベル | 用途 |
|---|---|
| `internal`（デフォルト） | モジュール内で使う型・メソッド |
| `private` | ファイル内でのみ使うプロパティ |
| `private(set)` | 読み取りは public、書き込みは private |
| `public` | モジュール外に公開する API |

### 1.4 SwiftLint / SwiftFormat 補足

- SwiftLint / SwiftFormat は Mint で管理する（`Mintfile` にバージョンを固定）
- カスタムルールは `.swiftlint.yml` / `.swiftformat` で管理する

## 2. 実装パターン集

### 2.1 View パターン

```swift
struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            content
                .task {
                    await viewModel.loadItems()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.error {
            ErrorView(error: error) {
                Task { await viewModel.loadItems() }
            }
        } else if viewModel.items.isEmpty {
            EmptyStateView(message: "データがありません")
        } else {
            itemList
        }
    }
}
```

### 2.2 ViewModel パターン

```swift
@Observable
final class HomeViewModel {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    private(set) var error: AppError?

    private let repository: any ItemRepositoryProtocol

    init(repository: any ItemRepositoryProtocol = ItemRepository()) {
        self.repository = repository
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await repository.fetchItems()
            error = nil
        } catch {
            self.error = AppError(error)
        }
    }
}
```

### 2.3 Repository パターン

```swift
// Protocol
protocol ItemRepositoryProtocol: Sendable {
    func fetchItems() async throws -> [Item]
    func createItem(_ item: Item) async throws -> Item
}

// 具象実装
final class ItemRepository: ItemRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchItems() async throws -> [Item] {
        try await apiClient.request(ItemsEndpoint.list)
    }
}

// Mock（テスト用）
final class MockItemRepository: ItemRepositoryProtocol {
    var stubbedItems: [Item] = []
    var stubbedError: Error?

    func fetchItems() async throws -> [Item] {
        if let error = stubbedError { throw error }
        return stubbedItems
    }

    func createItem(_ item: Item) async throws -> Item {
        if let error = stubbedError { throw error }
        return item
    }
}
```

### 2.4 Model パターン

```swift
struct Item: Codable, Sendable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date
}
```

### 2.5 DI パターン（EnvironmentKey）

```swift
private struct ItemRepositoryKey: EnvironmentKey {
    static let defaultValue: any ItemRepositoryProtocol = ItemRepository()
}

extension EnvironmentValues {
    var itemRepository: any ItemRepositoryProtocol {
        get { self[ItemRepositoryKey.self] }
        set { self[ItemRepositoryKey.self] = newValue }
    }
}
```

### 2.6 Navigation パターン（Route enum）

```swift
enum AppRoute: Hashable {
    case home
    case detail(itemID: String)
    case settings
}
```

## 3. 禁止パターン

| 禁止 API | 理由 | 代替 |
|---|---|---|
| `ObservableObject` / `@Published` | レガシー API | `@Observable` マクロ |
| `@StateObject` | レガシー API | `@State` |
| `@ObservedObject` | レガシー API | `@Bindable` |
| `@EnvironmentObject` | レガシー API | `@Environment` |
| `DispatchQueue` | GCD はレガシー | Swift Concurrency（`async/await`） |
| `force unwrap`（`!`） | クラッシュリスク | `guard let` / `if let` / `??` |
| `force cast`（`as!`） | クラッシュリスク | `as?` + guard |

## 4. Git ワークフロー

### 4.1 ブランチ戦略

| ブランチ | 用途 |
|---|---|
| `main` | リリース可能な状態を維持 |
| `feat/<feature-name>` | 新機能開発 |
| `fix/<bug-name>` | バグ修正 |
| `refactor/<target>` | リファクタリング |

### 4.2 Conventional Commits

```
feat: ユーザー一覧画面を追加
fix: ホーム画面のクラッシュを修正
refactor: ItemRepository を Protocol 化
test: HomeViewModel のユニットテストを追加
docs: アーキテクチャ設計書を更新
```

### 4.3 PR テンプレート

```markdown
## 概要
<!-- 変更内容を 1-2 文で -->

## 変更内容
- [ ] 変更点 1
- [ ] 変更点 2

## テスト
- [ ] ユニットテスト追加 / 更新
- [ ] 手動テスト実施

## スクリーンショット
<!-- UI 変更がある場合 -->
```

## 5. テストガイドライン

### 5.1 テスト命名規則

```
<メソッド名>_<条件>_<期待結果>
```

例: `loadItems_success_updatesItems`, `loadItems_networkError_setsError`

### 5.2 テスト構造（AAA パターン）

```swift
@Test
func loadItems_success_updatesItems() async {
    // Arrange
    let mockRepository = MockItemRepository()
    mockRepository.stubbedItems = [Item.mock]
    let viewModel = HomeViewModel(repository: mockRepository)

    // Act
    await viewModel.loadItems()

    // Assert
    #expect(viewModel.items.count == 1)
    #expect(viewModel.error == nil)
}
```

### 5.3 カバレッジ基準

| 対象 | 目標 |
|---|---|
| ViewModel | 80% 以上 |
| Repository | 70% 以上 |
| Model | バリデーションロジックがある場合のみ |
| View | UI テストで補完（必須ではない） |
```
