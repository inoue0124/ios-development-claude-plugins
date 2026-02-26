---
name: swift-format
description: SwiftFormat を実行して Swift コードのフォーマットを統一する。「SwiftFormat」「フォーマット」「コード整形」「インデント」「スタイル統一」で自動適用。
---

# SwiftFormat 実行

指定されたファイルまたは変更差分に対して SwiftFormat を実行し、コードスタイルを統一する。

## ツール使用方針

- XcodeBuildMCP が利用可能な場合は MCP 経由で SwiftFormat を実行する
- MCP が利用できない場合は CLI で直接実行する

```bash
# CLI フォールバック: フォーマット実行（ドライラン）
swiftformat --lint <ファイルまたはディレクトリ>

# CLI フォールバック: フォーマット適用
swiftformat <ファイルまたはディレクトリ>
```

## 実行手順

### 1. SwiftFormat の存在確認

```bash
which swiftformat || echo "SwiftFormat が見つかりません。`brew install swiftformat` でインストールしてください。"
```

### 2. 設定ファイルの確認

プロジェクトルートに `.swiftformat` が存在するか確認する。存在する場合はその設定を使用する。

### 3. ドライラン（差分確認）

まずドライランでフォーマット差分を確認する。

```bash
# フォーマット違反の検出（変更は行わない）
swiftformat --lint <対象パス>

# 差分プレビュー
swiftformat --dryrun <対象パス>
```

### 4. フォーマット適用

ユーザーの承認後、フォーマットを適用する。

```bash
swiftformat <対象パス>
```

## 主要なフォーマットルール

| ルール | 内容 |
|---|---|
| `indent` | インデントの統一（スペース 4 つ） |
| `trailingCommas` | 末尾カンマの追加 |
| `redundantSelf` | 冗長な `self.` の除去 |
| `redundantReturn` | 単一式の `return` 省略 |
| `braces` | 波括弧のスタイル統一 |
| `blankLinesAtEndOfScope` | スコープ末尾の空行除去 |
| `consecutiveSpaces` | 連続スペースの正規化 |
| `trailingSpace` | 行末空白の除去 |
| `wrapArguments` | 引数の折り返しルール |
| `sortImports` | import 文のソート |

## 出力

```
## SwiftFormat 結果: <対象パス>

### サマリー
- フォーマット差分があるファイル: N 件
- 適用されたルール: N 種類

### 差分プレビュー
<ファイル名>:
  - <行番号>: <適用ルール> — <変更内容の概要>

### アクション
- フォーマットを適用するには `swiftformat <対象パス>` を実行してください
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
