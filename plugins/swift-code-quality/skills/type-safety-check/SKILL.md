---
name: type-safety-check
description: force unwrap / force cast を検出し、安全な書き換えパターンを提案する。「force unwrap」「強制アンラップ」「as!」「try!」「型安全」「オプショナル」で自動適用。
---

# Force Unwrap / Force Cast 検出 + 安全な書き換え提案

指定されたファイル内の force unwrap（`!`）、force cast（`as!`）、force try（`try!`）を検出し、
安全な代替パターンを提案する。
書き換えパターンの詳細は → **references/SAFE_PATTERNS.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 検出項目

### 1. Force Unwrap（`!`）

オプショナル値の強制アンラップを検出する。

```swift
// NG: force unwrap
let name = user.name!
let url = URL(string: urlString)!

// OK: 安全なアンラップ
guard let name = user.name else { return }
guard let url = URL(string: urlString) else {
    fatalError("Invalid URL: \(urlString)")  // 開発時のみ許容
}
```

**除外対象:**

- `@IBOutlet` の `!` （Interface Builder との接続で慣例的に使用）
- テストコード内の `XCTUnwrap` 代替としての `!`

### 2. Force Cast（`as!`）

強制キャストを検出する。

```swift
// NG: force cast
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell

// OK: 条件付きキャスト
guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomCell else {
    return UITableViewCell()
}
```

### 3. Force Try（`try!`）

強制 try を検出する。

```swift
// NG: force try
let data = try! JSONEncoder().encode(model)

// OK: do-catch
do {
    let data = try JSONEncoder().encode(model)
} catch {
    // エラーハンドリング
}

// OK: try? でオプショナル
let data = try? JSONEncoder().encode(model)
```

### 4. 暗黙的アンラップオプショナル（`!` 型宣言）

プロパティ宣言での暗黙的アンラップオプショナル（IUO）を検出する。

```swift
// NG: IUO
var viewModel: UserViewModel!

// OK: 通常のオプショナルまたは非オプショナル
var viewModel: UserViewModel?
let viewModel: UserViewModel  // DI で注入
```

**除外対象:**

- `@IBOutlet` の IUO（Interface Builder との接続で慣例的に使用）

## 危険度の判定

| パターン | 危険度 | 理由 |
|---|---|---|
| `as!` | 高 | 型不一致で即クラッシュ |
| `try!` | 高 | 例外で即クラッシュ |
| `!` (force unwrap) | 中-高 | nil で即クラッシュ |
| `var x: Type!` (IUO) | 中 | アクセス時に nil でクラッシュ |

## 出力

```
## 型安全チェック結果: <ファイル名>

### サマリー
- Force unwrap: N 件
- Force cast: N 件
- Force try: N 件
- IUO 宣言: N 件

### 検出一覧
- [WARN] <ファイル>:<行番号> - force unwrap: `<コード>`
  [提案] guard let / if let で安全にアンラップしてください
  修正例:
    guard let value = <式> else { return }

- [WARN] <ファイル>:<行番号> - force cast: `<コード>`
  [提案] as? で条件付きキャストに変更してください
  修正例:
    guard let value = <式> as? <型> else { return }

- [WARN] <ファイル>:<行番号> - force try: `<コード>`
  [提案] do-catch または try? を使用してください
  修正例:
    do { let value = try <式> } catch { /* エラー処理 */ }
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
