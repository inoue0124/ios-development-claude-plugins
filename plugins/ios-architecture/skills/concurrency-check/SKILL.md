---
name: concurrency-check
description: Swift Concurrency の安全性を検査する。Swift 6.2 以降の厳格な並行性チェックに準拠しているかを検出。「Sendable」「actor」「MainActor」「async/await」「データ競合」「concurrency」で自動適用。
---

# Swift Concurrency 検査

Swift 6.2 以降の厳格な並行性モデルに準拠しているかを検査し、データ競合の潜在リスクを検出する。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 検査項目

### 1. Sendable 準拠

- 並行コンテキストをまたぐ型が `Sendable` に準拠しているか
- `@unchecked Sendable` の使用箇所と妥当性（ロックによる保護が実装されているか）
- `nonisolated(unsafe)` の使用箇所と妥当性（本当に安全か根拠があるか）
- クロージャの `@Sendable` アノテーションが適切か

### 2. Actor 分離

- 共有ミュータブル状態が actor で保護されているか
- `@MainActor` が UI 更新を伴うコード（ViewModel の `@Published` 更新等）に付与されているか
- actor 境界をまたぐ不要な `await` が発生していないか（過剰な actor hop）
- `nonisolated` の使用が適切か（actor 内で分離不要なメソッドに限定されているか）
- グローバル変数・静的プロパティが適切に分離されているか（`@MainActor` または `nonisolated(unsafe)`）

### 3. 構造化された並行性（Structured Concurrency）

- `Task { }` の非構造化タスクが乱用されていないか（`TaskGroup` / `async let` で代替可能か）
- `Task.detached` の使用が本当に必要か（actor コンテキストの意図的な離脱か）
- タスクキャンセルへの対応（`Task.checkCancellation()` / `Task.isCancelled`）が適切か
- `withTaskGroup` / `withThrowingTaskGroup` での子タスクのエラーハンドリング

### 4. async/await パターン

- コールバックベースの API が `withCheckedContinuation` / `withCheckedThrowingContinuation` で適切にブリッジされているか
- continuation の resume が正確に 1 回呼ばれることが保証されているか（漏れ・二重呼び出し）
- `AsyncSequence` / `AsyncStream` の活用が適切か（`for await` パターン）

### 5. Swift 6.2 固有の検査

- `sending` パラメータの活用（リージョンベース分離で Sendable 制約を緩和できる箇所）
- caller-side isolation の恩恵を受けられるメソッドに `nonisolated` が不要に付与されていないか
- `@concurrent` 関数属性の適切な使用

## 出力

```
## Swift Concurrency 検査結果: <ファイル名>

### Sendable 準拠: PASS / WARN (N 件)
- [WARN] <ファイル>:<行番号> - <型名> が Sendable に準拠していません
- [WARN] <ファイル>:<行番号> - @unchecked Sendable の使用。ロックによる保護を確認してください

### Actor 分離: PASS / WARN (N 件)
- [WARN] <ファイル>:<行番号> - @MainActor が必要です（@Published の更新を含むため）
- [WARN] <ファイル>:<行番号> - グローバル変数に actor 分離がありません

### 構造化された並行性: PASS / WARN (N 件)
- [WARN] <ファイル>:<行番号> - Task { } を async let で置き換えられます
- [WARN] <ファイル>:<行番号> - タスクキャンセルへの対応がありません

### async/await パターン: PASS / WARN (N 件)
- [WARN] <ファイル>:<行番号> - continuation の resume が保証されていない可能性があります

### Swift 6.2 最適化: INFO (N 件)
- [INFO] <ファイル>:<行番号> - sending パラメータの導入で Sendable 制約を緩和できます

### 指摘事項
- [提案] <改善案とコード例>
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
