---
name: naming-check
description: Swift 命名規則（API Design Guidelines 準拠）をチェックする。型名・メソッド名・変数名・プロパティ名の命名が規約に沿っているか検査。「命名規則」「naming」「API Design Guidelines」「変数名」「メソッド名」で自動適用。
---

# Swift 命名規則チェック

指定されたファイルまたは変更差分に対し、Swift API Design Guidelines に準拠した命名規則が守られているかを検査する。
検査ルールの詳細は -> **references/NAMING_RULES.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 検査項目

### 型名（Type Names）

- `struct`, `class`, `enum`, `protocol`, `actor` は UpperCamelCase であること
- Protocol は `-ing`, `-able`, `-ible` のサフィックス、または名詞で命名すること（`Equatable`, `Collection`, `UserProviding` 等）
- 型名がその役割を明確に表していること（`Manager`, `Helper`, `Utility` など曖昧な名前の検出）

### メソッド名（Method Names）

- lowerCamelCase であること
- 副作用のないメソッドは名詞句で命名すること（`distance(to:)` 等）
- 副作用のあるメソッドは動詞の命令形で命名すること（`append(_:)`, `sort()` 等）
- mutating / nonmutating ペアの命名規則: `-ed`, `-ing` サフィックス（`sorted()` / `sort()`）
- Boolean を返すメソッドは `is`, `has`, `can`, `should` で始まること

### 変数名・プロパティ名（Variable / Property Names）

- lowerCamelCase であること
- Boolean プロパティは `is`, `has`, `can`, `should` で始まること
- 略語の使用が適切か（一般的な略語: `url`, `id`, `html` は許可。不明瞭な略語は禁止）
- 一文字変数（`x`, `i` 等）はクロージャやループのスコープに限定すること

### 引数ラベル（Argument Labels）

- 前置詞ベースのラベルが適切に使われているか（`move(to:)`, `fade(from:)` 等）
- 型情報を繰り返していないか（NG: `func add(element: Element)` -> OK: `func add(_: Element)`）
- 第一引数が文の一部として自然に読めるか

### Swift 6.2 固有の規約

- `@Observable` クラスには `ViewModel` サフィックスを付けること（ViewModel の場合）
- actor 名は保護するリソースを明示すること（`DatabaseActor`, `NetworkActor` 等）
- `@MainActor` 付きの型はその旨がわかる配置・命名であること

## 出力

```
## 命名規則チェック結果: <ファイル名>

- 型名: PASS / WARN (N 件)
- メソッド名: PASS / WARN (N 件)
- 変数名・プロパティ名: PASS / WARN (N 件)
- 引数ラベル: PASS / WARN (N 件)

### 指摘事項
- [WARN] <ファイル>:<行番号> - <指摘内容>
- [提案] <改善案>
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
