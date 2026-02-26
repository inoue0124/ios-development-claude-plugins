---
name: pr-link-issues
description: PR と関連する issue を紐付ける。コミットメッセージや差分から関連 issue を自動検出し、PR に closing reference を追加。「issue 紐付け」「PR リンク」「closes」「関連 issue」で起動。
disable-model-invocation: true
---

# PR と Issue の紐付け

> このスキルは `/pr-link-issues` で明示的に実行します。GitHub の PR を更新する副作用があるため、自動活性化されません。

PR に関連する issue を検出し、closing reference（`closes #N`）で紐付ける。

## ツール使用方針

- `gh` CLI を使用して PR・issue の情報取得・更新を行う
- `git` コマンドでコミット履歴を取得する

## 実行フロー

### Step 1: PR 情報の取得

```bash
# 現在のブランチに紐づく PR を取得
gh pr view --json number,title,body,commits

# ブランチ名の取得
git branch --show-current
```

### Step 2: 関連 issue の自動検出

以下の情報源から関連する issue を検出する。

#### ブランチ名からの検出

ブランチ名に issue 番号が含まれている場合に検出する。

- `feature/123-add-login` → `#123`
- `fix/issue-456` → `#456`
- `feat/#789-user-profile` → `#789`

#### コミットメッセージからの検出

```bash
git log --oneline main...HEAD
```

コミットメッセージ内の `#N` パターンを検出する。

#### PR 本文からの検出

既に PR 本文に記載されている issue 参照を抽出する。

### Step 3: 候補 issue の確認

検出された issue が実在し、open 状態であるかを確認する。

```bash
# 各候補 issue の存在・状態確認
gh issue view <issue-number> --json number,title,state
```

### Step 4: 紐付けの実行

ユーザーに紐付け対象を確認した後、PR の本文を更新する。

```bash
# PR 本文に closing reference を追加
gh pr edit <pr-number> --body "<更新後の本文>"
```

## 出力

```
## PR-Issue 紐付け結果

### PR: #<pr-number> <PR タイトル>

### 検出された関連 issue
| issue | タイトル | 検出元 | 状態 |
|---|---|---|---|
| #<number> | <タイトル> | ブランチ名 / コミット / PR 本文 | open / closed |

### 紐付け済み
- closes #<number> — <タイトル>

### 更新内容
- PR 本文に closing reference を追加しました
```

## 対象の特定

- 引数で PR 番号が指定された場合はその PR を対象にする
- 指定がない場合は現在のブランチの PR を対象にする
- PR が存在しない場合はエラーメッセージを表示する
