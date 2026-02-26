# SwiftLint ルール詳細

## 重要度の高いルール

### Error レベル（必ず修正すべき）

| ルール | 説明 | 例 |
|---|---|---|
| `force_cast` | 強制キャスト（`as!`）の使用禁止 | `let x = y as! String` |
| `force_unwrapping` | 強制アンラップ（`!`）の使用禁止 | `let x = optional!` |
| `force_try` | 強制 try（`try!`）の使用禁止 | `let x = try! decode()` |
| `unused_closure_parameter` | クロージャの未使用パラメータ | `{ x, y in return y }` |
| `class_delegate_protocol` | delegate protocol が class-only でない | `protocol Delegate {}` |

### Warning レベル（推奨修正）

| ルール | 説明 | 例 |
|---|---|---|
| `line_length` | 行の長さ制限超過 | デフォルト: warning 120, error 200 |
| `function_body_length` | 関数の行数制限超過 | デフォルト: warning 40, error 100 |
| `type_body_length` | 型の行数制限超過 | デフォルト: warning 200, error 350 |
| `file_length` | ファイルの行数制限超過 | デフォルト: warning 400, error 1000 |
| `cyclomatic_complexity` | 循環的複雑度の超過 | デフォルト: warning 10, error 20 |
| `trailing_whitespace` | 行末の空白 | 自動修正可能 |
| `vertical_whitespace` | 連続する空行 | 自動修正可能 |

## 自動修正可能なルール

以下のルールは `swiftlint lint --fix` で自動修正できる。

- `trailing_whitespace` — 行末空白の除去
- `trailing_newline` — ファイル末尾の改行
- `trailing_semicolon` — 末尾セミコロンの除去
- `opening_brace` — 開き波括弧の位置
- `closing_brace` — 閉じ波括弧の位置
- `comma` — カンマ後のスペース
- `colon` — コロン後のスペース
- `return_arrow_whitespace` — 戻り値アロー前後のスペース
- `vertical_whitespace` — 連続空行の正規化
- `redundant_optional_initialization` — `= nil` の冗長な初期化
- `redundant_void_return` — `-> Void` の冗長な戻り値型

## Swift 6.2 関連のカスタムルール

`.swiftlint.yml` に以下のカスタムルールを追加することを推奨する。

```yaml
custom_rules:
  observable_object_deprecated:
    name: "ObservableObject Deprecated"
    regex: ":\\s*ObservableObject"
    message: "ObservableObject は非推奨です。@Observable マクロを使用してください。"
    severity: warning
  published_deprecated:
    name: "@Published Deprecated"
    regex: "@Published"
    message: "@Published は非推奨です。@Observable マクロを使用してください。"
    severity: warning
  state_object_deprecated:
    name: "@StateObject Deprecated"
    regex: "@StateObject"
    message: "@StateObject は非推奨です。@State を使用してください。"
    severity: warning
  observed_object_deprecated:
    name: "@ObservedObject Deprecated"
    regex: "@ObservedObject"
    message: "@ObservedObject は非推奨です。@Bindable または直接参照を使用してください。"
    severity: warning
  environment_object_deprecated:
    name: "@EnvironmentObject Deprecated"
    regex: "@EnvironmentObject"
    message: "@EnvironmentObject は非推奨です。@Environment を使用してください。"
    severity: warning
```
