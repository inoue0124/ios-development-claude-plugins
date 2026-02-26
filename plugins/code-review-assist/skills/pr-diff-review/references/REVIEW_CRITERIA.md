# レビュー基準詳細（Swift 6.2 / SwiftUI）

## 重要度の判定基準

| 重要度 | 基準 | 例 |
|---|---|---|
| Critical | バグ・クラッシュ・データ損失のリスクがある | force unwrap、データ競合、メモリリーク |
| Warning | 品質・保守性に影響する | 命名不適切、責務の混在、テスト不足 |
| Info | より良い書き方の提案 | パフォーマンス最適化、Swift 6.2 新機能の活用 |

## Swift 6.2 レビュー基準

### Observation フレームワーク

| パターン | 判定 | 指摘内容 |
|---|---|---|
| `ObservableObject` の使用 | Warning | `@Observable` への移行を提案 |
| `@Published` の使用 | Warning | `@Observable` では不要。移行を提案 |
| `@StateObject` の使用 | Warning | `@State` への移行を提案 |
| `@ObservedObject` の使用 | Warning | 直接参照 or `@Bindable` への移行を提案 |
| `@EnvironmentObject` の使用 | Warning | `@Environment` への移行を提案 |

### Concurrency

| パターン | 判定 | 指摘内容 |
|---|---|---|
| `@unchecked Sendable` | Warning | ロックによる保護の確認を求める |
| `nonisolated(unsafe)` | Warning | 安全性の根拠を求める |
| `Task.detached` の使用 | Info | 本当に必要か確認を求める |
| `Task { }` の乱用 | Warning | `async let` / `TaskGroup` の代替を提案 |
| `DispatchQueue` の使用 | Warning | Swift Concurrency への移行を提案 |

### エラーハンドリング

| パターン | 判定 | 指摘内容 |
|---|---|---|
| `try!` の使用 | Critical | クラッシュリスク。`do-catch` または `try?` + デフォルト値 |
| `try?` で結果を無視 | Warning | エラーの握り潰し。ログ出力またはハンドリングを提案 |
| 空の `catch` ブロック | Warning | エラーの握り潰し。ログ出力を提案 |
| `fatalError` の本番コード使用 | Critical | クラッシュリスク。適切なエラーハンドリングを提案 |

### メモリ管理

| パターン | 判定 | 指摘内容 |
|---|---|---|
| クロージャ内で `self` を強参照 | Warning | `[weak self]` の使用を提案 |
| delegate が `strong` 参照 | Critical | 循環参照。`weak` に変更を提案 |
| `NotificationCenter` の未解除 | Warning | `deinit` での解除を提案 |

## MVVM レビュー基準

### View 層

- View 内にビジネスロジック（計算・条件分岐・データ変換）が含まれていないか
- View が Repository / Service 層に直接依存していないか
- `@State` がビジネスロジックの状態管理に使われていないか（UI 状態のみ許可）

### ViewModel 層

- `import SwiftUI` していないか
- 他の ViewModel を直接参照していないか
- `@MainActor` が付与されているか（UI バインドされたプロパティの更新を含む場合）

### Model 層

- プレゼンテーションロジックを含んでいないか
- View / ViewModel を import していないか
