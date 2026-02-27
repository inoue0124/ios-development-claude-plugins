# リポジトリ構造定義書テンプレート

以下のテンプレートに従って `docs/repository-structure.md` を生成する。

---

```markdown
# リポジトリ構造定義書

> 生成日時: YYYY-MM-DD
> ステータス: Draft
> 入力: docs/product-requirements.md, docs/functional-design.md, docs/architecture.md

## 1. ディレクトリツリー

```
ProjectRoot/
├── project.yml                          # XcodeGen プロジェクト定義
├── Mintfile                             # SwiftLint / SwiftFormat バージョン管理
├── .swiftlint.yml                       # SwiftLint ルール
├── .swiftformat                         # SwiftFormat ルール
├── fastlane/
│   └── Fastfile                         # CI/CD レーン定義
├── docs/
│   ├── ideas/                           # アイデアメモ
│   ├── product-requirements.md          # プロダクト要求定義書
│   ├── functional-design.md             # 機能設計書
│   ├── architecture.md                  # アーキテクチャ設計書
│   ├── repository-structure.md          # リポジトリ構造定義書（本ドキュメント）
│   ├── development-guidelines.md        # 開発ガイドライン
│   └── glossary.md                      # 用語集
├── Sources/
│   ├── App/
│   │   ├── App.swift                    # @main エントリポイント
│   │   ├── ContentView.swift            # ルートナビゲーション
│   │   └── DI/
│   │       └── EnvironmentKeys.swift    # 全 EnvironmentKey 定義
│   ├── Features/
│   │   └── <FeatureName>/
│   │       ├── View/
│   │       │   ├── <FeatureName>View.swift
│   │       │   └── Components/
│   │       │       └── <ComponentName>.swift
│   │       ├── ViewModel/
│   │       │   └── <FeatureName>ViewModel.swift
│   │       ├── Model/
│   │       │   └── <ModelName>.swift
│   │       └── Repository/
│   │           ├── <FeatureName>RepositoryProtocol.swift
│   │           └── <FeatureName>Repository.swift
│   └── Shared/
│       ├── Components/                  # 共通 UI コンポーネント
│       │   ├── ErrorView.swift
│       │   ├── LoadingView.swift
│       │   └── EmptyStateView.swift
│       ├── Extensions/                  # Swift 拡張
│       ├── Networking/                  # API クライアント
│       │   ├── APIClient.swift
│       │   ├── Endpoint.swift
│       │   └── NetworkError.swift
│       └── Error/
│           └── AppError.swift           # アプリ共通エラー型
└── Tests/
    └── <FeatureName>/
        ├── <FeatureName>ViewModelTests.swift
        └── Mock<FeatureName>Repository.swift
```

## 2. Feature Module 一覧

| # | Feature | 画面 | Model | Repository |
|---|---|---|---|---|
| 1 | Home | HomeView | Item | ItemRepository |
| 2 | Detail | DetailView | - | - |
| 3 | Settings | SettingsView | UserSettings | SettingsRepository |

## 3. XcodeGen 設定（project.yml）

```yaml
name: ProjectName
options:
  minimumXcodeGenVersion: "2.38"
  deploymentTarget:
    iOS: "17.0"

targets:
  ProjectName:
    type: application
    platform: iOS
    sources:
      - path: Sources
    settings:
      SWIFT_VERSION: "6.2"
      SWIFT_STRICT_CONCURRENCY: complete
    dependencies: []

  ProjectNameTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: Tests
    dependencies:
      - target: ProjectName
```

## 4. ファイル命名規則

| レイヤー | パターン | 例 |
|---|---|---|
| View | `<Feature>View.swift` | `HomeView.swift` |
| ViewModel | `<Feature>ViewModel.swift` | `HomeViewModel.swift` |
| Model | `<ModelName>.swift` | `Item.swift` |
| Repository Protocol | `<Feature>RepositoryProtocol.swift` | `ItemRepositoryProtocol.swift` |
| Repository 実装 | `<Feature>Repository.swift` | `ItemRepository.swift` |
| Mock | `Mock<Feature>Repository.swift` | `MockItemRepository.swift` |
| テスト | `<Feature>ViewModelTests.swift` | `HomeViewModelTests.swift` |
| 共通コンポーネント | `<ComponentName>.swift` | `ErrorView.swift` |
```
