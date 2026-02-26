# 複雑度判定基準

## 循環的複雑度（Cyclomatic Complexity）

Thomas McCabe が提唱したコードの複雑さの指標。
関数内の独立した実行パスの数を表す。

### 判定基準

| 複雑度 | 判定 | 説明 |
|---|---|---|
| 1-5 | 低 | シンプルで理解しやすい |
| 6-10 | 良好 | 許容範囲。テストケースが管理可能 |
| 11-20 | 注意 | 複雑。リファクタリングを検討 |
| 21-50 | 危険 | 非常に複雑。テストが困難。分割を強く推奨 |
| 51+ | 極めて危険 | 即座にリファクタリングが必要 |

### 計測ルール

分岐を構成する以下のキーワード・演算子を検出してカウントする。

```swift
// 各 +1
if condition { }
else if condition { }
guard condition else { }
for item in collection { }
while condition { }
repeat { } while condition
switch value {
    case .a:    // +1
    case .b:    // +1
    default:    // +1
}
condition ? a : b  // +1
condition1 && condition2  // +1
condition1 || condition2  // +1
do { } catch { }  // catch ごとに +1
```

## 関数行数

### 判定基準

| 行数 | 判定 | 説明 |
|---|---|---|
| 1-20 | 低 | 簡潔で理解しやすい |
| 21-40 | 良好 | 許容範囲 |
| 41-100 | 注意 | 長い。分割を検討 |
| 101+ | 危険 | 非常に長い。分割を強く推奨 |

## 型の行数

### 判定基準

| 行数 | 判定 | 説明 |
|---|---|---|
| 1-100 | 低 | 適切なサイズ |
| 101-200 | 良好 | 許容範囲 |
| 201-350 | 注意 | 大きい。責務の分割を検討 |
| 351+ | 危険 | 非常に大きい。Single Responsibility Principle 違反の可能性 |

## ファイル行数

### 判定基準

| 行数 | 判定 | 説明 |
|---|---|---|
| 1-200 | 低 | 適切なサイズ |
| 201-400 | 良好 | 許容範囲 |
| 401-1000 | 注意 | 大きい。ファイル分割を検討 |
| 1001+ | 危険 | 非常に大きい。分割を強く推奨 |

## リファクタリング戦略

### 複雑度が高い場合

1. **Extract Method** — 条件分岐のブロックを別メソッドに抽出する
2. **Replace Conditional with Polymorphism** — switch/if 分岐を Protocol + 具象型に置き換える
3. **Guard Clause** — 早期リターンで if のネストを減らす
4. **Strategy Pattern** — 分岐ごとの処理を Strategy に分離する

### 行数が多い場合

1. **Extract Method** — 論理的なまとまりを別メソッドに抽出する
2. **Extract Type** — 関連するプロパティとメソッドを別の型に分離する
3. **Compose Method** — メソッドを同じ抽象レベルのステップに分解する
