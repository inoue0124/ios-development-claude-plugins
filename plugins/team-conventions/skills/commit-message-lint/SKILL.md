---
name: commit-message-lint
description: コミットメッセージが Conventional Commits 形式に準拠しているかチェックする。type、scope、description の形式を検査。「コミットメッセージ」「commit message」「conventional commits」「コミット形式」で自動適用。
---

# コミットメッセージ形式チェック

コミットメッセージが Conventional Commits 形式に準拠しているかを検査する。

## ツール使用方針

- `git log` コマンドでコミット履歴を取得して検査する
- MCP は使用しない（git CLI のみ）

## Conventional Commits 形式

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### type（必須）

| type | 用途 |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | コードの意味に影響しない変更（空白、フォーマット等） |
| `refactor` | バグ修正でも機能追加でもないコード変更 |
| `perf` | パフォーマンス改善 |
| `test` | テストの追加・修正 |
| `build` | ビルドシステム・外部依存の変更 |
| `ci` | CI 設定の変更 |
| `chore` | その他の変更（src / test に影響しない） |

### scope（任意）

- 変更の影響範囲をカッコ内に記述する
- Feature 名やモジュール名を使用する（例: `feat(auth):`, `fix(payment):`）

### description（必須）

- 先頭は小文字で始める
- 末尾にピリオドを付けない
- 命令形で記述する（英語の場合: `add`, `fix`, `update` 等）
- 日本語の場合も体言止めまたは動詞で終わる

## 検査項目

### 1. 形式チェック

- `<type>: <description>` または `<type>(<scope>): <description>` の形式に合致するか
- type が許可リストに含まれるか
- description が空でないか
- 1行目が 72 文字以内か

### 2. 本文チェック

- 1行目と本文の間に空行があるか（本文がある場合）
- 本文の各行が 100 文字以内か

### 3. Breaking Change

- `BREAKING CHANGE:` フッターの形式が正しいか
- type に `!` が付与されている場合のフッター対応

## 出力

```
## コミットメッセージ検査結果

### 検査対象
- コミット数: N

### 結果
- 形式準拠: N / N (XX%)
- 違反: N 件

### 違反一覧
- [WARN] <commit hash> - "<メッセージ>" - <指摘内容>
- [提案] <修正例>
```

## 検査対象の特定

- 引数でコミット範囲が指定された場合はその範囲を検査する（例: `HEAD~5..HEAD`）
- 指定がない場合は直近 10 コミットを対象にする
