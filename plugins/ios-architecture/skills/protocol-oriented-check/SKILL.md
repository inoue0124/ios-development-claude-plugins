---
name: protocol-oriented-check
description: Protocol 指向設計の推奨・改善提案を行う。Protocol 準拠、デフォルト実装、型消去、Protocol 分離の原則を検査。「Protocol」「インターフェース」「抽象化」「設計原則」で自動適用。
---

# Protocol 指向設計チェック

Swift の Protocol 指向プログラミングの観点からコードを分析し、改善提案を行う。

## 検査項目

### 1. Protocol 分離の原則（ISP）

- 1 つの Protocol に過剰な要件が定義されていないか
- クライアントが使わないメソッドの実装を強制されていないか
- 責務ごとに Protocol が分離されているか

### 2. Protocol 活用の推奨

- 具象クラスに直接依存している箇所で Protocol 抽出を推奨
- テスト対象のクラスが Protocol に準拠していないケースの検出
- Repository / Service 層が Protocol を持っているか

### 3. デフォルト実装の適切性

- Protocol Extension でのデフォルト実装が過剰でないか
- デフォルト実装が準拠型の振る舞いを意図せず隠蔽していないか

### 4. 関連型（associatedtype）と型消去

- `associatedtype` の使用が適切か
- 型消去（AnyXxx）が必要な場面で適用されているか
- `some` / `any` キーワードの使い分けが正しいか（Swift 5.7+）

## 出力

```
## Protocol 指向設計チェック結果

### ISP 違反: N 件
- [WARN] <Protocol名> が N 個の要件を持っています。分離を検討してください

### Protocol 抽出の推奨: N 件
- [提案] <クラス名> に Protocol を導入するとテスタビリティが向上します

### デフォルト実装: PASS / WARN
### 型消去 / Existential: PASS / WARN
```
