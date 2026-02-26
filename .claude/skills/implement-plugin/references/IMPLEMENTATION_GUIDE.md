# プラグイン実装ガイド

## ディレクトリ構造

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

## plugin.json

```json
{
  "name": "<plugin-name>",
  "version": "0.1.0",
  "description": "<日本語の説明>",
  "skills": "./skills/",
  "agents": ["./agents/<agent-name>.md"],
  "hooks": ["./hooks/hooks.json"]
}
```

- skills, agents, hooks は実際に存在するもののみ記載する（存在しないフィールドは省略する）
- description は README.md のプラグイン説明文を使う

## SKILL.md

### frontmatter

```yaml
---
name: <skill-name>
description: <トリガーキーワードを含む説明文>
---
```

- `name`, `description` は必須
- 読み取り・分析・提案系 → `disable-model-invocation` を省略（デフォルト false）
- ワークフロー・副作用系 → `disable-model-invocation: true` を明記
- `argument-hint` はユーザー引数を受け取るスキルのみ

### 本文の書き方

- 日本語で記述する。コード例・コマンド例は英語のまま
- MCP 推奨 + CLI フォールバックのパターンを記述する（該当する場合）
- description にはトリガーキーワードを含め、自動活性化を促す
- 詳細な仕様やパターン例は references/ に分離する（Progressive Disclosure）

### disable-model-invocation の判断基準

| スキルの性質 | 設定 | 理由 |
|---|---|---|
| 読み取り・分析・提案 | 省略（false） | Claude が文脈に応じて自動発火 |
| 複数スキルの組み合わせワークフロー | `true` | ユーザーが `/skill-name` で明示実行 |
| 外部に副作用がある操作 | `true` | 意図しない実行を防止 |

## agent.md（subagent）

### frontmatter

```yaml
---
name: <agent-name>
description: <説明文>
tools: <ツールリスト>
model: sonnet
---
```

- `name`, `description`, `tools`, `model` は必須
- MCP にアクセスできないため CLI ツールのみ指定する
- model は処理の重さに応じて選択（全体スキャン系 → sonnet、軽量処理 → haiku）

### 本文の書き方

- プロンプトにスコープ（何をして何をしないか）を明確に記述する
- 出力形式を指定して結果をパースしやすくする

## hooks.json（hooks がある場合）

- 有効な JSON 形式で記述する
- 参照するスクリプトファイルも合わせて作成する

## 品質基準

- CLAUDE.md の必須ルールに全て準拠していること
- README.md のスキル一覧と実ファイルが一致していること
- 全ファイルが kebab-case・64 文字以内の命名規則に従っていること
- `/validate-plugin` が通る状態であること
