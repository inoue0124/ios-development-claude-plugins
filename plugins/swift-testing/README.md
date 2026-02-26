# swift-testing — テスト生成・実行

ユニットテスト・UI テストの生成からテスト実行・カバレッジ分析まで、テストのライフサイクル全体をサポートする。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | unit-test-gen | 対象コードからユニットテスト生成 |
| skill | ui-test-gen | SwiftUI 画面から XCUITest 生成 |
| skill | mock-gen | Protocol 準拠のモック / スタブ自動生成 |
| skill | test-pattern-suggest | テスト対象に適切なテストパターンを提案 |
| skill | coverage-gap-detect | テスト未カバーのパスを特定 |
| skill (manual) | test-gen | テスト生成 → 実行 → カバレッジ一括ワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| test-runner | テスト実行（xcodebuild test）+ 結果パース |
| coverage-reporter | カバレッジ収集 + レポート生成 |
