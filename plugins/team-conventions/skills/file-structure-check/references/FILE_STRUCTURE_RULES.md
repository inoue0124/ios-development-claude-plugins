# ファイル配置ルール詳細

## 標準ディレクトリ構成

### Feature Module の構成

各 Feature は独立したディレクトリで、以下の構成を持つ。

```
Features/<Feature名>/
├── Views/
│   ├── <Feature名>View.swift        # メイン画面
│   ├── <Feature名>DetailView.swift  # 詳細画面（あれば）
│   └── Components/                   # Feature 固有コンポーネント
│       └── <Component名>.swift
├── ViewModels/
│   ├── <Feature名>ViewModel.swift
│   └── <Feature名>DetailViewModel.swift
├── Models/
│   ├── <モデル名>.swift
│   └── <DTO名>.swift
├── Repositories/
│   ├── <Feature名>Repository.swift
│   └── <Feature名>RepositoryProtocol.swift
└── UseCases/
    └── <UseCase名>.swift
```

### Shared ディレクトリの構成

Feature をまたぐ共通コンポーネントを配置する。

```
Shared/
├── Extensions/
│   └── <型名>+<拡張内容>.swift      # 例: String+Validation.swift
├── Components/
│   └── <Component名>.swift           # 再利用可能な UI コンポーネント
├── Utilities/
│   └── <Utility名>.swift
├── Protocols/
│   └── <Protocol名>.swift            # 共通 Protocol
└── Models/
    └── <共通モデル名>.swift
```

### Infrastructure ディレクトリの構成

外部システムとの接続やアプリ基盤の実装を配置する。

```
Infrastructure/
├── Network/
│   ├── APIClient.swift
│   ├── Endpoint.swift
│   └── NetworkError.swift
├── Persistence/
│   ├── CoreDataStack.swift
│   └── UserDefaultsStore.swift
└── DI/
    └── DependencyContainer.swift
```

## ファイル名の規約

### 基本ルール

| ファイル種別 | 命名パターン | 例 |
|---|---|---|
| View | `<名前>View.swift` | `UserListView.swift` |
| ViewModel | `<名前>ViewModel.swift` | `UserListViewModel.swift` |
| Model | `<名前>.swift` | `User.swift` |
| Repository | `<名前>Repository.swift` | `UserRepository.swift` |
| Protocol | `<名前>Protocol.swift` または `<名前>ing.swift` | `UserRepositoryProtocol.swift` |
| UseCase | `<名前>UseCase.swift` | `FetchUsersUseCase.swift` |
| Extension | `<型名>+<内容>.swift` | `String+Validation.swift` |
| Actor | `<名前>Actor.swift` | `DatabaseActor.swift` |

### 1 ファイル 1 型の原則

- 各 `.swift` ファイルには主要な型を 1 つだけ定義する
- ネストした型（inner class/struct/enum）は許可
- Protocol とそのデフォルト実装の Extension は同一ファイルに記述可

### 例外的に複数型を許可するケース

- Protocol + そのデフォルト Extension
- enum + その associated value に使う struct
- 小さなヘルパー型（private スコープに限る）

## View と ViewModel の対応

### 1:1 対応の推奨

各 View には対応する ViewModel を用意する。

```swift
// UserListView.swift
struct UserListView: View {
    @State private var viewModel = UserListViewModel()
}

// UserListViewModel.swift
@Observable
class UserListViewModel {
    var users: [User] = []
    var isLoading = false
}
```

### 例外

- 純粋な表示のみの View（`EmptyStateView` 等）は ViewModel 不要
- 共通 UI コンポーネント（`LoadingIndicator` 等）は ViewModel 不要
- Settings や About 等の静的画面は状態がなければ ViewModel 不要

## SPM マルチモジュール構成

SPM でモジュール分割している場合の構成例。

```
Package.swift
Sources/
├── AppModule/              # アプリ本体
├── FeatureHome/            # Home 機能
├── FeatureSettings/        # 設定機能
├── SharedUI/               # 共通 UI
├── Domain/                 # ドメインモデル + UseCase
├── DataAccess/             # Repository 実装
└── Infrastructure/         # 基盤
```

各モジュール内は Feature Module と同じ構成を適用する。
