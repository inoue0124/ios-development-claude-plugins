---
name: swift-lint
description: SwiftLint を実行して Swift コードの品質違反を検出・自動修正する。「SwiftLint」「lint」「コーディング規約」「スタイル違反」「自動修正」で自動適用。
---

# SwiftLint 実行 + 自動修正

指定されたファイルまたは変更差分に対して SwiftLint を実行し、コーディング規約違反を検出する。
自動修正可能な違反は `--fix` オプションで修正を提案する。
検出ルールの詳細は → **references/SWIFTLINT_RULES.md** を参照。

## ツール使用方針

- XcodeBuildMCP が利用可能な場合は MCP 経由で SwiftLint を実行する
- MCP が利用できない場合は CLI で直接実行する

```bash
# CLI フォールバック: lint 実行
swiftlint lint --path <ファイルまたはディレクトリ> --reporter json

# CLI フォールバック: 自動修正
swiftlint lint --fix --path <ファイルまたはディレクトリ>
```

## 実行手順

### 1. SwiftLint の存在確認

```bash
which swiftlint || echo "SwiftLint が見つかりません。`brew install swiftlint` でインストールしてください。"
```

### 2. 設定ファイルの確認

プロジェクトルートに `.swiftlint.yml` が存在するか確認する。存在する場合はその設定を使用する。

### 3. lint 実行

```bash
# JSON 形式で結果を取得
swiftlint lint --path <対象パス> --reporter json
```

### 4. 結果の解析

JSON 出力から以下を集計する。

- `error` レベルの違反数
- `warning` レベルの違反数
- ルールごとの違反数

### 5. 自動修正の提案

自動修正可能な違反がある場合、ユーザーに修正の実行を提案する。

```bash
swiftlint lint --fix --path <対象パス>
```

## 出力

```
## SwiftLint 結果: <対象パス>

### サマリー
- Error: N 件
- Warning: N 件
- 自動修正可能: N 件

### 違反一覧
- [ERROR] <ファイル>:<行番号>:<列番号> - <ルール名>: <説明>
- [WARN]  <ファイル>:<行番号>:<列番号> - <ルール名>: <説明>

### 頻出ルール TOP 5
1. <ルール名>: N 件
2. <ルール名>: N 件
...

### 自動修正
- 自動修正可能な違反が N 件あります。`swiftlint lint --fix` で修正できます。
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
