---
name: add-plugin
description: 新しいプラグインをゼロから設計し、リポジトリに追加する
argument-hint: "[plugin-name]"
disable-model-invocation: true
---

# プラグイン追加

新しいプラグインをゼロから設計し、リポジトリに追加するワークフロー。
ヒアリング → 設計承認 → ファイル生成 → 検証 → Issue 作成 & PR 作成の順に進行する。

## フロー概要

```
Step 1: ヒアリング（プラグインの目的・スコープを対話で決定）
  ↓
Step 2: スキル・subagent・hooks の構成を設計し、ユーザー承認を得る
  ↓
Step 3: ルート README.md にプラグイン情報を追加
Step 4: marketplace.json にエントリを追加
Step 5: プラグインディレクトリ・ファイル一式を生成（IMPLEMENTATION_GUIDE.md 準拠）
  ↓
Step 6: /validate-plugin で構造検証（FAIL → 修正 → 再検証）
  ↓
Step 7: Issue 作成 + コミット + PR 作成
```

## Step 1: ヒアリング

$ARGUMENTS にプラグイン名が指定されている場合はそれを使用する。指定されていない場合はユーザーに確認する。

以下の情報を対話で収集する。

| 項目 | 内容 | 例 |
|---|---|---|
| プラグイン名 | kebab-case | `accessibility-check` |
| 概要・目的 | 1-2 文の説明 | アクセシビリティ検査・VoiceOver 対応チェック |
| 対象 Tier | Tier 1（日常）/ Tier 2（構築・配信） | Tier 2 |
| 解決する課題 | このプラグインが必要な理由 | アクセシビリティ対応が属人化している |

既に README.md に記載されているプラグイン名と重複する場合はエラーとし、`/implement-plugin` の利用を促す。

## Step 2: 設計

CLAUDE.md の設計ルールに基づき、以下を設計する。

### 設計項目

1. **atomic スキル**: 単一責務のスキルを列挙する
2. **ワークフロースキル**: 複数スキルの組み合わせ（`disable-model-invocation: true`）
3. **subagent**: プロジェクト全体走査・ビルド・テスト実行などの重い処理がある場合のみ設計する
4. **hooks**: 自動実行が必要なイベントフックがある場合のみ設計する

### 設計判断の基準

- 読み取り・分析・提案系 → atomic スキル（自動発火）
- 複数スキルの組み合わせ → ワークフロースキル（手動起動）
- 外部副作用あり → 手動起動（`disable-model-invocation: true`）
- 重い処理（全体スキャン、ビルド、テスト） → subagent に隔離

### ユーザー承認

設計結果を以下のテーブル形式で提示し、承認を得る。

```
## プラグイン設計: <plugin-name>

### スキル一覧

| スキル名 | 種別 | 内容 | 起動 |
|---|---|---|---|
| check-xxx | atomic | XXX を検査する | 自動 |
| fix-xxx | atomic | XXX を修正する | 自動 |
| run-xxx | workflow | 検査→修正→レポートの一括実行 | 手動 |

### subagent

| subagent 名 | 内容 | model |
|---|---|---|
| xxx-scanner | プロジェクト全体を走査して XXX を検出 | sonnet |

### hooks

なし（または hooks の内容）
```

承認が得られるまで設計を修正する。承認後、Step 3 に進む。

## Step 3: README.md にプラグイン情報を追加

ルートの README.md にある対象 Tier のプラグイン一覧テーブルに新しいエントリを追加する。

- 番号は既存の最大番号 + 1
- 概要は Step 1 で決定した説明文を使用する
- リンクは `plugins/<plugin-name>/` 形式

## Step 4: marketplace.json にエントリを追加

`.claude-plugin/marketplace.json` の `plugins` 配列に新しいエントリを追加する。

```json
{
  "name": "<plugin-name>",
  "description": "<概要>",
  "version": "0.1.0",
  "source": "./plugins/<plugin-name>",
  "category": "development",
  "tags": ["ios", "swift", ...]
}
```

- category は内容に応じて `development` または `workflow` を選択する
- tags は関連するキーワードを 4-8 個設定する

## Step 5: プラグインディレクトリ・ファイル一式を生成

IMPLEMENTATION_GUIDE.md に準拠して以下のファイルを生成する。

### ディレクトリ構造

```
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       └── references/       # 必要に応じて
├── agents/
│   └── <agent-name>.md       # subagent がある場合
└── hooks/
    └── hooks.json             # hooks がある場合
```

### plugin.json

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<日本語の説明>",
  "skills": "./skills/",
  "agents": ["./agents/<agent-name>.md"]
}
```

- skills, agents, hooks は実際に存在するもののみ記載する
- agents がない場合は `agents` フィールド自体を省略する
- hooks がない場合は `hooks` フィールド自体を省略する

### SKILL.md

- YAML frontmatter に `name`, `description` を必須で含める
- `disable-model-invocation` は設計判断に基づき設定する
- 本文は日本語、コード例は英語
- description にはトリガーキーワードを含める

### agent.md（subagent がある場合）

- YAML frontmatter に `name`, `description`, `tools`, `model` を必須で含める
- MCP にアクセスできないため CLI ツールのみ使用する
- model は処理の重さに応じて選択する（全体スキャン → sonnet、軽量処理 → haiku）

## Step 6: 構造検証

`/validate-plugin` を実行し、生成したプラグインの構造を検証する。

- **PASS**: Step 7 に進む
- **FAIL**: 指摘内容を修正し、再度検証を実行する

PASS になるまでこのステップを繰り返す。

## Step 7: Issue 作成 + コミット + PR 作成

### Issue 作成

```bash
gh issue create \
  --title "feat: <plugin-name> プラグインの実装" \
  --label "plugin" \
  --body "<Step 2 の設計内容を Issue テンプレートに沿って記述>"
```

### コミット + PR 作成

1. フィーチャーブランチを作成する: `feat/<plugin-name>`
2. 変更ファイルをステージング・コミットする
3. `gh pr create` で PR を作成し、`closes #N` で Issue を紐付ける

## 注意

- 既存プラグイン名と重複する場合は処理を中止し、`/implement-plugin` を案内する
- 各ステップで問題が発生した場合はユーザーに状況を報告し、対応を相談する
- CLAUDE.md の必須ルール（命名規則、Swift 6.2 準拠、MCP 推奨 + CLI フォールバック等）を全て遵守する
