# swift-code-quality — コード品質ガード

SwiftLint / SwiftFormat による静的解析と軽量な構文チェックで、フルビルドなしにコード品質を担保する。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | swift-lint | SwiftLint 実行 + 違反の自動修正 |
| skill | swift-format | SwiftFormat 実行 |
| skill | syntax-typecheck | `swiftc -typecheck` による軽量構文チェック |
| skill | complexity-analysis | 循環的複雑度・関数行数の分析 |
| skill | dead-code-detect | 未使用コード・未使用 import の検出 |
| skill | type-safety-check | force unwrap / force cast の検出 + 安全な書き換え提案 |
| skill (manual) | quality-check | lint + format + typecheck 一括ワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| lint-scanner | プロジェクト全体の lint 一括スキャン |
