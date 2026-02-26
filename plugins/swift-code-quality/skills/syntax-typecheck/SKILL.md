---
name: syntax-typecheck
description: swiftc -typecheck による軽量構文・型チェックを実行する。フルビルドなしに構文エラー・型エラーを早期検出。「構文チェック」「型チェック」「typecheck」「コンパイルエラー」「構文エラー」で自動適用。
---

# 軽量構文・型チェック

`swiftc -typecheck` を使用して、フルビルドなしに構文エラーと型エラーを検出する。
ビルド時間を待たずにコードの基本的な正しさを確認できる。

## ツール使用方針

- XcodeBuildMCP が利用可能な場合は MCP 経由でビルドチェックを実行する
- MCP が利用できない場合は `swiftc -typecheck` を CLI で直接実行する

```bash
# CLI フォールバック: 単一ファイルの構文・型チェック
swiftc -typecheck <ファイルパス>

# CLI フォールバック: SDK を指定してチェック（iOS 向け）
swiftc -typecheck -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) -target arm64-apple-ios17.0-simulator <ファイルパス>

# CLI フォールバック: 複数ファイルのチェック
swiftc -typecheck <ファイル1> <ファイル2> ...
```

## 実行手順

### 1. 対象ファイルの特定

引数で指定されたファイル、または `git diff` の変更ファイルから `.swift` ファイルを特定する。

### 2. SDK の特定

プロジェクトのターゲット SDK を特定する。

```bash
# iOS シミュレータ SDK のパスを取得
xcrun --show-sdk-path --sdk iphonesimulator
```

### 3. typecheck 実行

```bash
swiftc -typecheck \
  -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  -target arm64-apple-ios17.0-simulator \
  <対象ファイル>
```

### 4. エラー解析

コンパイラ出力を解析し、以下に分類する。

| 種別 | 説明 |
|---|---|
| `error` | 構文エラー・型エラー（ビルド不可） |
| `warning` | コンパイラ警告（ビルドは可能） |
| `note` | 補足情報 |

### 5. 修正提案

検出されたエラーに対して修正案を提示する。

## 注意事項

- `swiftc -typecheck` は単一ファイルまたは少数ファイルの検査に適している
- モジュール間依存がある場合、import しているモジュールのビルドが必要な場合がある
- フレームワーク依存が多い場合は XcodeBuildMCP または `xcodebuild` の使用を検討する

## 出力

```
## 構文・型チェック結果: <ファイル名>

### サマリー
- Error: N 件
- Warning: N 件

### エラー一覧
- [ERROR] <ファイル>:<行番号>:<列番号> - <エラーメッセージ>
  [提案] <修正案>

- [WARN]  <ファイル>:<行番号>:<列番号> - <警告メッセージ>

### 結果
- PASS: 構文・型エラーなし / FAIL: N 件のエラーを検出
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
