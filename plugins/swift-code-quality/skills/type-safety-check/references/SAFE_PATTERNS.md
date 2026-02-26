# 安全な書き換えパターン集

## Force Unwrap の代替パターン

### 1. guard let（早期リターン）

最も推奨されるパターン。関数の冒頭で nil チェックを行い、後続の処理で安全に使える。

```swift
// Before
func processUser() {
    let name = user.name!
    print(name)
}

// After
func processUser() {
    guard let name = user.name else {
        // nil の場合の処理（return, throw, fatalError 等）
        return
    }
    print(name)
}
```

### 2. if let（条件分岐）

nil の場合と非 nil の場合で異なる処理を行う場合。

```swift
// Before
let url = URL(string: urlString)!

// After
if let url = URL(string: urlString) {
    // URL が有効な場合
    openURL(url)
} else {
    // URL が無効な場合
    showError("無効な URL です")
}
```

### 3. nil 合体演算子（`??`）

デフォルト値がある場合。

```swift
// Before
let name = user.name!

// After
let name = user.name ?? "Unknown"
```

### 4. Optional Chaining

プロパティアクセスの連鎖でいずれかが nil の可能性がある場合。

```swift
// Before
let street = user.address!.street!

// After
let street = user.address?.street  // String? を返す
```

### 5. map / flatMap

オプショナル値を変換する場合。

```swift
// Before
let uppercased = user.name!.uppercased()

// After
let uppercased = user.name.map { $0.uppercased() }  // String?
```

## Force Cast の代替パターン

### 1. as?（条件付きキャスト）+ guard

```swift
// Before
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell

// After
guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCell else {
    assertionFailure("CustomCell のデキューに失敗しました")
    return UITableViewCell()
}
```

### 2. ジェネリクスによる型安全

```swift
// Before
func decode(_ data: Data) -> Any {
    return try! JSONDecoder().decode(Model.self, from: data)
}
let model = decode(data) as! Model

// After
func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    return try JSONDecoder().decode(type, from: data)
}
let model = try decode(Model.self, from: data)
```

## Force Try の代替パターン

### 1. do-catch

エラーを適切にハンドリングする場合。

```swift
// Before
let data = try! JSONEncoder().encode(model)

// After
do {
    let data = try JSONEncoder().encode(model)
    send(data)
} catch {
    logger.error("エンコードに失敗: \(error)")
}
```

### 2. try?（オプショナル try）

エラーの詳細が不要で、失敗時は nil で十分な場合。

```swift
// Before
let data = try! JSONEncoder().encode(model)

// After
guard let data = try? JSONEncoder().encode(model) else {
    return
}
```

### 3. Result 型

非同期処理や結果を伝搬する場合。

```swift
// Before
func fetchData() -> Data {
    return try! URLSession.shared.data(from: url)
}

// After
func fetchData() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

## IUO（暗黙的アンラップオプショナル）の代替

### 1. コンストラクタ注入

```swift
// Before
class ViewController {
    var viewModel: UserViewModel!

    func configure(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
}

// After（SwiftUI + DI）
struct UserView: View {
    @State private var viewModel: UserViewModel

    init(viewModel: UserViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
}
```

### 2. lazy 初期化

```swift
// Before
var formatter: DateFormatter!

// After
lazy var formatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()
```

## 許容されるケース

以下のケースでは force unwrap / force cast が許容される場合がある。

| ケース | 理由 |
|---|---|
| `@IBOutlet weak var label: UILabel!` | Interface Builder との接続で慣例的に使用 |
| テストコード内の `!` | テスト失敗として検出される |
| `fatalError` 直前の `!` | 意図的なクラッシュ |
| コンパイル時に確定する値 | `URL(string: "https://example.com")!` 等 |
