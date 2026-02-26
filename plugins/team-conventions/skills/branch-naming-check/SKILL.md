---
name: branch-naming-check
description: ブランチ命名規則が規約に準拠しているか検証する。プレフィックス、kebab-case、Issue 番号の紐付けを検査。「ブランチ名」「branch naming」「ブランチ命名」「ブランチ規約」で自動適用。
---

# ブランチ命名規則チェック

現在のブランチ名がチームの命名規則に準拠しているかを検査する。

## ツール使用方針

- `git branch` / `git rev-parse` コマンドでブランチ情報を取得する
- MCP は使用しない（git CLI のみ）

## ブランチ命名規約

### 形式

```
<prefix>/<description>
```

または Issue 番号付き:

```
<prefix>/<issue-number>-<description>
```

### 許可されるプレフィックス

| プレフィックス | 用途 | 例 |
|---|---|---|
| `feat` | 新機能開発 | `feat/user-authentication` |
| `fix` | バグ修正 | `fix/login-crash` |
| `hotfix` | 緊急バグ修正 | `hotfix/payment-failure` |
| `refactor` | リファクタリング | `refactor/network-layer` |
| `docs` | ドキュメント | `docs/api-reference` |
| `test` | テスト追加・修正 | `test/user-repository` |
| `chore` | その他作業 | `chore/update-dependencies` |
| `release` | リリース準備 | `release/1.2.0` |

### description 部分のルール

- kebab-case で記述する（小文字 + ハイフン区切り）
- 英語で記述する
- 簡潔かつ変更内容が伝わる名前にする
- 50 文字以内を推奨

## 検査項目

### 1. プレフィックスの検証

- 許可リストに含まれるプレフィックスか
- `/` で区切られているか

### 2. description の検証

- kebab-case であるか（大文字・アンダースコア・スペースを含まない）
- description が空でないか
- 全体の長さが適切か（推奨 50 文字以内）

### 3. 保護ブランチのチェック

- `main`, `master`, `develop` で直接作業していないか

### 4. Issue 番号の紐付け（推奨）

- `feat/42-user-auth` のように Issue 番号がブランチ名に含まれているか（推奨、必須ではない）

## 出力

```
## ブランチ命名チェック結果

- ブランチ名: <ブランチ名>
- プレフィックス: PASS / WARN
- description: PASS / WARN
- 保護ブランチ: PASS / WARN

### 指摘事項
- [WARN] <指摘内容>
- [提案] <推奨されるブランチ名>
```

## 検査対象の特定

- 引数でブランチ名が指定された場合はそのブランチを検査する
- 指定がない場合は現在のブランチ（`git rev-parse --abbrev-ref HEAD`）を対象にする
