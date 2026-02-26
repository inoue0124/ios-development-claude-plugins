# タスクリストテンプレート

以下の構成に従い TASKS.md を生成する。

---

```markdown
# <フィーチャー名> — タスクリスト

> 詳細設計書: [DESIGN.md](./DESIGN.md)
> 要件定義書: [REQUIREMENTS.md](./REQUIREMENTS.md)

## 進捗サマリー

| レイヤー | タスク数 | 完了 |
|---|---|---|
| Model | X | 0 |
| Repository | X | 0 |
| UseCase | X | 0 |
| ViewModel | X | 0 |
| View | X | 0 |
| Navigation | X | 0 |
| DI | X | 0 |
| Test | X | 0 |
| **合計** | **X** | **0** |

## Phase 1: Model 層

- [ ] **T-1**: `<モデル名>` モデルの定義
  - ファイル: `Sources/<フィーチャー名>Feature/Models/<モデル名>.swift`
  - 内容: `Codable`, `Sendable`, `Identifiable` に準拠したデータモデルを定義する
  - 依存: なし

- [ ] **T-2**: `<モデル名>` のレスポンスモデル定義
  - ファイル: `Sources/<フィーチャー名>Feature/Models/<モデル名>Response.swift`
  - 内容: API レスポンスのデコード用モデルを定義する
  - 依存: T-1

## Phase 2: Repository 層

- [ ] **T-3**: `<フィーチャー名>RepositoryProtocol` の定義
  - ファイル: `Sources/<フィーチャー名>Feature/Repositories/<フィーチャー名>RepositoryProtocol.swift`
  - 内容: Repository の Protocol を定義する（`async throws` メソッド、`Sendable` 準拠）
  - 依存: T-1

- [ ] **T-4**: `<フィーチャー名>Repository` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/Repositories/<フィーチャー名>Repository.swift`
  - 内容: API クライアントを使用した具象実装を作成する
  - 依存: T-3

- [ ] **T-5**: `<フィーチャー名>RepositoryMock` の実装
  - ファイル: `Tests/<フィーチャー名>FeatureTests/Mocks/<フィーチャー名>RepositoryMock.swift`
  - 内容: テスト・プレビュー用のモック実装を作成する
  - 依存: T-3

## Phase 3: UseCase 層

- [ ] **T-6**: `Fetch<フィーチャー名>UseCase` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/UseCases/Fetch<フィーチャー名>UseCase.swift`
  - 内容: Protocol + 具象実装。単一責務の `execute` メソッド
  - 依存: T-3

## Phase 4: ViewModel 層

- [ ] **T-7**: `<フィーチャー名>ViewModel` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/ViewModels/<フィーチャー名>ViewModel.swift`
  - 内容: `@Observable class` で状態管理。Repository をコンストラクタ注入
  - 依存: T-3, T-6

## Phase 5: View 層

- [ ] **T-8**: `<フィーチャー名>View` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/Views/<フィーチャー名>View.swift`
  - 内容: メイン画面の SwiftUI View。ViewModel は `@State` で保持
  - 依存: T-7

- [ ] **T-9**: 共通コンポーネントの実装
  - ファイル: `Sources/<フィーチャー名>Feature/Views/Components/<コンポーネント名>.swift`
  - 内容: 再利用可能な UI コンポーネント
  - 依存: なし

## Phase 6: ナビゲーション

- [ ] **T-10**: `<フィーチャー名>Router` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/Navigation/<フィーチャー名>Router.swift`
  - 内容: 画面遷移の定義（`NavigationStack` + `navigationDestination`）
  - 依存: T-8

## Phase 7: DI

- [ ] **T-11**: `<フィーチャー名>Dependency` の実装
  - ファイル: `Sources/<フィーチャー名>Feature/DI/<フィーチャー名>Dependency.swift`
  - 内容: 依存解決コンテナ + `@Environment` 対応
  - 依存: T-4, T-7

## Phase 8: テスト

- [ ] **T-12**: `<フィーチャー名>ViewModel` のユニットテスト
  - ファイル: `Tests/<フィーチャー名>FeatureTests/<フィーチャー名>ViewModelTests.swift`
  - 内容: Swift Testing フレームワークで ViewModel のテストを作成
  - 依存: T-5, T-7

- [ ] **T-13**: `Fetch<フィーチャー名>UseCase` のユニットテスト
  - ファイル: `Tests/<フィーチャー名>FeatureTests/Fetch<フィーチャー名>UseCaseTests.swift`
  - 内容: UseCase のテストを作成
  - 依存: T-5, T-6
```

---

## テンプレート使用時の注意

- タスク番号は通し番号（T-1, T-2, ...）で付与する
- Phase の順序は依存関係に基づく（下位レイヤーから上位レイヤーへ）
- 各タスクには必ず「ファイル」「内容」「依存」を記載する
- 依存タスクが完了していないタスクは着手しない
- フィーチャーに応じてタスクを追加・削除する（テンプレートは最小構成）
- テスト用のモック実装は Repository 層フェーズで作成する（テストフェーズではない）
