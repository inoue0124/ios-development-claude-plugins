---
name: issue-implement
description: GitHub issue 番号を指定して、ブランチ作成・実装・PR 作成を一気通貫で実行する。issue の規模を自動判断し、小規模は直接実装、大規模はスペック駆動で実装する。「issue 実装」「issue 対応」「issue-implement」で起動。
disable-model-invocation: true
argument-hint: "<issue-number>"
---

# Issue 起点の実装ワークフロー

> このスキルは `/issue-implement <issue-number>` で明示的に実行します。Git 操作・GitHub PR 作成の副作用があるため、自動活性化されません。

GitHub issue の内容を読み取り、ブランチ作成 → 実装 → PR 作成までを行う。
issue の規模に応じてスペック駆動（大規模）または直接実装（小規模）を自動判断する。

## ツール使用方針

- `gh` CLI を使用して issue の取得・PR 作成を行う
- 既存コードの読み取りは xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は CLI にフォールバックする

## 実行フロー

### Step 1: Issue 情報の取得

```bash
gh issue view <issue-number> --json title,body,labels,assignees
```

issue のタイトル・本文・ラベルを取得し、内容を把握する。

### Step 2: 規模判断

issue の内容から実装規模を判断する。

| 規模 | 条件 | フロー |
|---|---|---|
| 小規模 | バグ修正、設定変更、1-2 ファイルの修正 | → Step 3 → Step 4 → Step 6 → Step 8 |
| 大規模 | 新機能追加、複数モジュールにまたがる変更 | → Step 3 → Step 4 → Step 5 → Step 6 → Step 7 → Step 8 |

判断基準:
- ラベルに `bug` がある → 小規模（原則）
- ラベルに `feature` / `enhancement` がある → 大規模（原則）
- 本文に複数の受け入れ条件・画面言及がある → 大規模
- 不明な場合はユーザーに確認する

**ユーザーに規模判断の結果を提示し、承認を得る。**

### Step 3: プロジェクトスペック参照

`docs/` 配下にプロジェクトスペック（`/init-project-spec` で生成）が存在する場合、以下を読み取り設計・実装の前提情報として活用する。

| ファイル | 参照内容 |
|---|---|
| `docs/product-requirements.md` | ユーザーストーリー・機能要件・非機能要件 |
| `docs/functional-design.md` | 画面一覧・データモデル・API 仕様 |
| `docs/architecture.md` | レイヤー設計・DI 戦略・ナビゲーション設計・テスト戦略 |
| `docs/repository-structure.md` | ディレクトリ構成・ファイル命名規則 |
| `docs/development-guidelines.md` | 実装パターン・禁止パターン・コーディング規約 |
| `docs/glossary.md` | ドメイン用語 → コード命名のマッピング |

存在しないファイルはスキップする（警告は出さない）。

### Step 4: ワークツリー作成

issue のラベル・内容に基づき、**ワークツリーを作成して隔離された環境で作業する**。

ワークツリー名は `<prefix>/<issue-number>-<description>` 形式で生成する。

| ラベル / 種別 | プレフィックス |
|---|---|
| bug | `fix/` |
| feature / enhancement | `feat/` |
| refactor | `refactor/` |
| その他 | `feat/` |

`<description>` は issue タイトルから kebab-case で生成する（英語、30 文字以内）。

ユーザーに「ワークツリーを作成します」と伝え、EnterWorktree ツールでワークツリーを作成する。

### Step 5: スペック駆動設計（大規模のみ）

issue の内容と Step 3 で取得したプロジェクトスペックを入力として、以下を順に実行する。
特に `docs/architecture.md` のレイヤー設計・DI 戦略・ナビゲーション設計に準拠すること。

1. **要件定義書の作成**（requirements-gen 相当）
   - issue の本文を要件のベースとして活用する
   - 不足情報があればユーザーにヒアリングする
   - `docs/features/<feature-name>/REQUIREMENTS.md` に出力
   - **ユーザー承認を待つ**

2. **詳細設計書の作成**（design-gen 相当）
   - `docs/features/<feature-name>/DESIGN.md` に出力
   - **ユーザー承認を待つ**

3. **タスクリスト生成**（task-gen 相当）
   - `docs/features/<feature-name>/TASKS.md` に出力
   - **ユーザー承認を待つ**

### Step 6: 実装

#### 小規模の場合

1. issue の内容に基づき修正を実装する
2. 構文検証を行う
3. 関連するテストがあれば実行する

#### 大規模の場合

TASKS.md のタスクを順番に実装する（implement-feature の Step 6 と同様）。

1. 未完了タスクを取得する
2. コードを生成する
3. 構文検証を行う
4. タスクを完了に更新する
5. 次の未完了タスクへ進む

### Step 7: テスト（大規模のみ）

全タスク完了後、以下を確認する。

1. 全ファイルの構文検証
2. ユニットテストの実行
3. REQUIREMENTS.md の受け入れ条件との照合

### Step 8: コミット・PR 作成

```bash
# 変更をコミット（Conventional Commits 形式）
git add <files>
git commit -m "<type>(scope): <subject> (#<issue-number>)"

# リモートに push
git push -u origin <branch-name>

# PR 作成（issue をリンク）
gh pr create \
  --title "<type>(scope): <subject>" \
  --body "## 概要
<変更の概要>

## 変更内容
<変更点のリスト>

Closes #<issue-number>"
```

## 出力形式

```
## Issue 実装結果: #<issue-number>

### Issue
- タイトル: <タイトル>
- 規模: 小規模 / 大規模

### ブランチ
- <branch-name>

### ドキュメント（大規模のみ）
- docs/features/<feature-name>/REQUIREMENTS.md
- docs/features/<feature-name>/DESIGN.md
- docs/features/<feature-name>/TASKS.md

### 実装ファイル
- <生成・変更したファイルの一覧>

### PR
- URL: <PR URL>

### 次のアクション
- [ ] PR をレビューする
- [ ] CI の結果を確認する
```
