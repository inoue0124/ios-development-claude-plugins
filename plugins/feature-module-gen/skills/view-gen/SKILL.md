---
name: view-gen
description: SwiftUI View ファイルを生成する。チーム規約に準拠した View テンプレートを出力。「View 生成」「SwiftUI View」「画面作成」「UI 生成」で自動適用。
---

# SwiftUI View 生成

指定された画面名・用途に基づき、チーム規約に準拠した SwiftUI View ファイルを生成する。

## ツール使用方針

- ファイル作成・プロジェクトへの追加は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `cat` / `swiftc -typecheck` 等の CLI にフォールバックする

## 入力

- **View 名**（例: `UserProfileView`）
- **用途の説明**（省略可。指定された場合は body の内容を調整する）
- **出力先ディレクトリ**（省略時は `Views/` を推定）

## 生成ルール

### 基本構造

```swift
import SwiftUI

struct <ViewName>: View {
    @State private var viewModel: <ViewModelName>

    init(viewModel: <ViewModelName>) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Text("Hello, <ViewName>")
    }
}

#Preview {
    <ViewName>(viewModel: <ViewModelName>())
}
```

### 規約

- ViewModel は `@State` で保持する（`@StateObject` は使わない）
- `@EnvironmentObject` は使わず `@Environment` で環境値を注入する
- body 内にビジネスロジックを記述しない（ViewModel に委譲する）
- `#Preview` マクロでプレビューを定義する（旧 `PreviewProvider` は使わない）
- View が Repository / Service に直接依存しない

### バインディングが必要な場合

子 View で ViewModel のプロパティに書き込む場合は `@Bindable` を使用する。

```swift
struct <ChildViewName>: View {
    @Bindable var viewModel: <ViewModelName>

    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

詳細なパターン例は → **references/VIEW_PATTERNS.md** を参照。

## 生成後の確認

- 生成したファイルが Swift の構文として正しいか検証する
  - MCP: XcodeBuildMCP の `swift_typecheck` を使用
  - CLI フォールバック: `swiftc -typecheck <ファイル>` を実行
