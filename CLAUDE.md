# CLAUDE.md

iOS チーム開発を包括的にサポートする Claude Code プラグインストア。

## ロール

あなたは iOS 向け Claude Code プラグインの開発者です。SwiftUI + MVVM アーキテクチャを前提としたチーム開発の品質向上・効率化を目的としたスキル・subagent を設計・実装します。

## 必須ルール

### プラグイン構造

各プラグインは以下の構造に従う。

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # name, version, description, skills, agents, hooks
├── skills/
│   └── skill-name/
│       ├── SKILL.md          # YAML frontmatter (name, description) + 指示本文
│       └── references/       # 詳細仕様・パターン例（Progressive Disclosure）
├── agents/
│   └── agent-name.md         # subagent 定義（YAML frontmatter + プロンプト）
└── hooks/
    └── hooks.json            # イベントフック定義
```

### MCP 推奨 + CLI フォールバック

- スキル内では MCP ツールの利用を優先する
- MCP が利用できない場合は CLI（xcodebuild, swift, gh 等）にフォールバックする
- subagent は MCP にアクセスできないため、常に CLI で実装する

### subagent 化の基準

以下のいずれかに該当する処理は subagent として隔離する。

- プロジェクト全体を走査する処理（lint 全体スキャン、依存分析等）
- ビルド・テスト実行のようにログ出力が膨大な処理
- 実行時間が長くメイン会話のコンテキストを圧迫する処理

### スキル設計

- 1 スキル 1 責務（atomic）に設計する
- 複数スキルの組み合わせもワークフロー skill として定義する（commands/ は使わない）
- description にトリガーキーワードを含め、自動活性化を促す
- 詳細な仕様や参照情報は references/ に分離する（Progressive Disclosure）

### スキルの起動制御（disable-model-invocation）

- 読み取り・分析・提案系のスキル → `false`（デフォルト）。Claude が文脈に応じて自動発火
- 複数スキルを組み合わせるワークフロー → `true`。ユーザーが `/skill-name` で明示的に実行
- 外部に副作用がある操作（issue 作成、PR 作成、アップロード等） → `true`

### Swift バージョン準拠

スキル・subagent 内のコード例・検査ルールは常に最新の Swift に準拠する。

- **Swift 6.2 / SwiftUI** を前提とする
- Observation フレームワーク（`@Observable`）を使用する。`ObservableObject` / `@Published` は非推奨として検出・移行提案する
- Swift Concurrency の厳格な並行性モデル（`Sendable`, actor 分離, structured concurrency）に準拠する
- 旧 API パターン（`@StateObject`, `@ObservedObject`, `@EnvironmentObject`）はレガシーとして扱い、新 API（`@State`, `@Bindable`, `@Environment`）への移行を促す

## ガイドライン

### 命名規則

- プラグイン名: kebab-case（例: `code-review-assist`）
- スキル名: kebab-case、最大 64 文字（例: `pr-diff-review`）
- subagent 名: kebab-case、役割を明示（例: `review-analyzer`）

### 記述言語

- SKILL.md, agent .md の本文は日本語で記述する
- plugin.json の description も日本語で記述する
- コード例・コマンド例は英語のまま記述する

### 推奨 MCP サーバー

| MCP サーバー | 用途 |
|---|---|
| XcodeBuildMCP | ビルド・テスト実行・シミュレータ操作・デバッグ |
| xcodeproj-mcp-server | プロジェクトファイル操作・ターゲット管理・SPM 依存管理 |

## コマンド

```bash
# プラグインのインストール確認
/plugin list

# マーケットプレイスからの追加
/plugin marketplace add inoue0124/ios-claude-plugins
```
