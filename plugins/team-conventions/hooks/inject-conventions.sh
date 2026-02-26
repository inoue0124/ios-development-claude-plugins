#!/bin/bash
# コード生成時にチームの規約をコンテキストとして注入する
# UserPromptSubmit フックで実行される

CONVENTIONS=$(cat <<'CONVENTIONS_EOF'
## チーム規約コンテキスト（自動注入）

コードを生成・修正する際は以下の規約に従ってください。

### 命名規則
- 型名: UpperCamelCase（struct, class, enum, protocol, actor）
- メソッド名・変数名: lowerCamelCase
- Boolean: is / has / can / should プレフィックス
- Protocol: -able / -ible / -ing サフィックス または名詞
- ファイル名: 主要型名と一致させる

### SwiftUI + MVVM 構成
- View → ViewModel → UseCase / Repository → Model の依存方向
- @Observable マクロを使用する（ObservableObject は非推奨）
- @State でオーナーシップを持つ（@StateObject は非推奨）
- @Bindable で双方向バインディング（@ObservedObject は非推奨）
- @Environment で環境値注入（@EnvironmentObject は非推奨）

### ファイル配置
- View は Views/ ディレクトリに配置
- ViewModel は ViewModels/ ディレクトリに配置
- 1 ファイル 1 型を原則とする

### Swift Concurrency（Swift 6.2）
- Sendable 準拠を徹底する
- @MainActor を UI 更新に適用する
- 構造化された並行性（async let / TaskGroup）を優先する
CONVENTIONS_EOF
)

echo "$CONVENTIONS"
