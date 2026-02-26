---
name: viewmodel-gen
description: ViewModel ファイルを生成する。@Observable ベースで Input/Output パターンに対応。「ViewModel 生成」「@Observable」「ViewModel 作成」で自動適用。
---

# ViewModel 生成

指定された ViewModel 名・責務に基づき、`@Observable` ベースの ViewModel ファイルを生成する。

## ツール使用方針

- ファイル作成・プロジェクトへの追加は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `cat` / `swiftc -typecheck` 等の CLI にフォールバックする

## 入力

- **ViewModel 名**（例: `UserProfileViewModel`）
- **責務の説明**（省略可。指定された場合はプロパティ・メソッドを調整する）
- **出力先ディレクトリ**（省略時は `ViewModels/` を推定）

## 生成ルール

### 基本テンプレート

```swift
import Foundation

@Observable
class <ViewModelName> {
    // MARK: - State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let repository: <RepositoryProtocolName>

    // MARK: - Init

    init(repository: <RepositoryProtocolName>) {
        self.repository = repository
    }

    // MARK: - Actions

    func fetch() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // TODO: データ取得処理
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 規約

- `@Observable class` で宣言する（`ObservableObject` / `@Published` は使わない）
- `import Foundation` のみ（`import SwiftUI` は禁止）
- 依存は Protocol 経由でコンストラクタ注入する
- `isLoading` と `errorMessage` を標準のステートプロパティとして含める
- 非同期メソッドは `async` / `async throws` で定義する
- 他の ViewModel を直接参照しない（Protocol 経由で必要なデータのみ注入する）
- UI 更新が必要なプロパティは `@MainActor` で保護する

### Input / Output パターン（オプション）

責務が複雑な ViewModel では Input / Output の分離を適用できる。

```swift
@Observable
class <ViewModelName> {
    // MARK: - Output (State)

    var items: [Item] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Input (Actions)

    func onAppear() async { ... }
    func onRefresh() async { ... }
    func onItemTapped(_ item: Item) { ... }
}
```

詳細なパターン例は → **references/VIEWMODEL_PATTERNS.md** を参照。

## 生成後の確認

- 生成したファイルが Swift の構文として正しいか検証する
  - MCP: XcodeBuildMCP の `swift_typecheck` を使用
  - CLI フォールバック: `swiftc -typecheck <ファイル>` を実行
