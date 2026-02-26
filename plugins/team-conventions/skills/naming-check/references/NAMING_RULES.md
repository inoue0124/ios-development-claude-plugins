# 命名規則詳細（Swift API Design Guidelines 準拠）

## 基本原則

Swift API Design Guidelines に基づき、以下の原則を適用する。

### 明瞭さが最優先（Clarity at the point of use）

- 名前は使用箇所で曖昧さなく意味が伝わること
- 簡潔さよりも明瞭さを優先する

### 使用箇所で自然な英語として読めること

```swift
// OK: 自然な英語として読める
x.insert(y, at: z)          // "x, insert y at z"
x.subViews(in: rect)        // "x's subviews in rect"
x.fade(from: firstView, to: secondView)

// NG: 不自然
x.insert(y, position: z)
x.subViews(rect)
x.fade(firstView, secondView)
```

## 型名の規約

### UpperCamelCase

```swift
// OK
struct UserProfile { }
class NetworkClient { }
enum PaymentStatus { }
protocol DataProviding { }
actor DatabaseActor { }

// NG
struct userProfile { }   // lowerCamelCase
class network_client { } // snake_case
```

### Protocol の命名

| パターン | 用途 | 例 |
|---|---|---|
| `-able` / `-ible` | 能力を表す | `Equatable`, `Codable`, `Sendable` |
| `-ing` / `-ive` | 振る舞いを表す | `UserProviding`, `DataLoading` |
| 名詞 | データ型としての役割 | `Collection`, `Sequence` |

### 曖昧な型名の検出

以下のサフィックスは具体性が低いため、より適切な名前への変更を推奨する。

| 曖昧な名前 | 推奨 |
|---|---|
| `UserManager` | `UserRepository`, `UserService`, `UserStore` |
| `DataHelper` | 具体的な責務を表す名前 |
| `Utility` / `Utils` | Extension または具体的な型名 |
| `Handler` | `Delegate`, `Processor`, `Responder` 等 |

## メソッド名の規約

### 副作用に基づく命名

| 副作用 | 命名パターン | 例 |
|---|---|---|
| なし（値を返す） | 名詞句 | `x.distance(to: y)`, `x.successor()` |
| あり（状態を変更） | 動詞の命令形 | `x.sort()`, `x.append(y)` |

### mutating / nonmutating ペア

| mutating | nonmutating | ルール |
|---|---|---|
| `sort()` | `sorted()` | `-ed` サフィックス |
| `reverse()` | `reversed()` | `-ed` サフィックス |
| `formUnion(_:)` | `union(_:)` | `form-` プレフィックス（動詞が `-ed` で不自然な場合） |

### Boolean を返すメソッド / プロパティ

```swift
// OK: is / has / can / should プレフィックス
var isEmpty: Bool
var hasContent: Bool
func canPerformAction() -> Bool
var shouldRefresh: Bool

// NG: プレフィックスなし
var empty: Bool
var content: Bool
func performAction() -> Bool
```

## 変数名・プロパティ名の規約

### lowerCamelCase

```swift
// OK
let userName: String
var isLoading: Bool
private var itemCount: Int

// NG
let user_name: String   // snake_case
var IsLoading: Bool     // UpperCamelCase
private var ItemCount: Int
```

### 略語のルール

| 略語 | 扱い | 例 |
|---|---|---|
| `URL`, `ID`, `HTML`, `JSON`, `API` | 全大文字（型名先頭）/ 全小文字（それ以外） | `urlString`, `userID`, `HTMLParser` |
| プロジェクト固有の略語 | 禁止（フルスペルで記述） | NG: `svcMgr` -> OK: `serviceManager` |

### 一文字変数の許容範囲

```swift
// OK: ループやクロージャ内の短スコープ
for i in 0..<count { }
numbers.map { $0 * 2 }
items.filter { item in item.isActive }

// NG: クラスプロパティやメソッド引数
var x: Int = 0
func process(d: Data) { }
```

## 引数ラベルの規約

### 型情報の重複を避ける

```swift
// NG: 型情報の重複
func add(element: Element)
func remove(item: Item)

// OK: ラベルを省略または前置詞を使用
func add(_ element: Element)
func remove(_ item: Item)
func remove(at index: Int)
```

### 前置詞ベースのラベル

```swift
// OK: 前置詞で関係性を明示
func move(to point: CGPoint)
func convert(from source: Encoding)
func insert(_ element: Element, at index: Int)

// NG: 前置詞が不適切
func move(point: CGPoint)
func convert(source: Encoding)
```

## ファイル名の規約

- ファイル名は主要な型名と一致させる（`UserViewModel.swift` には `UserViewModel` を定義）
- Extension ファイルは `型名+拡張内容.swift` 形式（`String+Validation.swift`）
- Protocol ファイルは Protocol 名と一致させる（`UserProviding.swift`）
