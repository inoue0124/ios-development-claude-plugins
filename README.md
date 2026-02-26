# iOS Claude Plugins

iOS チーム開発を包括的にサポートする Claude Code プラグインストア。

コードレビュー、規約統一、テスト文化の定着、オンボーディングといったチーム開発の課題を解決し、AI によるコード品質の向上を実現する。

## 設計方針

- **スキルは細粒度** — 単一責務の atomic なスキルとして設計
- **全て skills で統一** — ワークフロー（複数スキルの組み合わせ）も skill として定義。`disable-model-invocation: true` でユーザー起動のみに制限
- **重い処理は subagent 化** — ビルド・テスト実行・全体スキャンなどコンテキストを圧迫する処理は隔離実行
- **MCP 推奨 + CLI フォールバック** — MCP サーバーの利用を推奨。MCP が利用できない環境では CLI（xcodebuild, swift, gh 等）にフォールバック
- **SwiftUI + MVVM** — アーキテクチャ規約は SwiftUI + MVVM をベースに設計

## プラグイン一覧

### Tier 1: 日常の開発サイクルで毎日使うもの

| # | プラグイン | 概要 |
|---|---|---|
| 1 | [ios-architecture](plugins/ios-architecture/) | MVVM 構造チェック・レイヤー依存検査・DI 提案 |
| 2 | [team-conventions](plugins/team-conventions/) | コーディング規約・命名規則の自動検査・強制 |
| 3 | [swift-code-quality](plugins/swift-code-quality/) | SwiftLint / SwiftFormat による静的解析・構文チェック |
| 4 | [swift-testing](plugins/swift-testing/) | テスト生成・実行・カバレッジ分析 |
| 5 | [github-workflow](plugins/github-workflow/) | 構造化 Issue 作成・差分解析 PR 作成 |
| 6 | [code-review-assist](plugins/code-review-assist/) | PR 差分分析・レビューコメント生成・影響範囲特定 |

### Tier 2: プロジェクト構築・配信フェーズで使うもの

| # | プラグイン | 概要 |
|---|---|---|
| 7 | [ios-onboarding](plugins/ios-onboarding/) | プロジェクト構造解説・用語集生成・変更要約 |
| 8 | [feature-module-gen](plugins/feature-module-gen/) | SwiftUI + MVVM Feature Module 雛形一式生成 |
| 9 | [ios-distribution](plugins/ios-distribution/) | アーカイブビルド・TestFlight アップロード自動化 |
| 10 | [feature-implementation](plugins/feature-implementation/) | 要件定義・詳細設計・タスクリストによるスペック駆動フィーチャー実装 |

各プラグインの詳細（スキル一覧・subagent・hooks）は各ディレクトリの README.md を参照。

## インストール

### マーケットプレイスから一括追加

```bash
/plugin marketplace add inoue0124/ios-claude-plugins
```

### 個別プラグインのインストール

```bash
/plugin install ios-architecture
/plugin install team-conventions
/plugin install swift-code-quality
/plugin install swift-testing
/plugin install github-workflow
/plugin install code-review-assist
/plugin install ios-onboarding
/plugin install feature-module-gen
/plugin install ios-distribution
/plugin install feature-implementation
```

### 推奨 MCP サーバー

本プラグインストアは以下の MCP サーバーとの併用を推奨する。MCP が利用できない環境では各スキルが CLI にフォールバックする。

| MCP サーバー | 用途 | インストール |
|---|---|---|
| [XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) | ビルド・テスト実行・シミュレータ操作・デバッグ・UI 自動化 | `claude mcp add XcodeBuildMCP -- npx -y xcodebuildmcp@latest mcp` |
| [xcodeproj-mcp-server](https://github.com/giginet/xcodeproj-mcp-server) | Xcode プロジェクトファイル操作（ファイル追加・ターゲット管理・ビルド設定・SPM 依存管理） | `claude mcp add xcodeproj -- docker run --pull=always --rm -i -v $PWD:/workspace ghcr.io/giginet/xcodeproj-mcp-server:latest /workspace` |

**XcodeBuildMCP** はビルド・テスト・シミュレータといった「実行系」を、**xcodeproj-mcp-server** はファイル追加・ターゲット作成・ビルド設定変更といった「プロジェクト構造操作」を担う。両方を導入することで、プラグインの全機能を最大限に活用できる。

### 前提条件

| ツール | 用途 | 必須 |
|---|---|---|
| Xcode | ビルド・テスト実行（xcodebuild） | 必須 |
| SwiftLint | コード品質チェック | 必須 |
| SwiftFormat | コードフォーマット | 必須 |
| gh CLI | GitHub issue / PR 操作 | 必須 |
| Node.js 18+ | XcodeBuildMCP の実行 | 推奨 |
| Docker | xcodeproj-mcp-server の実行 | 推奨 |
| xcrun altool | TestFlight アップロード | ios-distribution 利用時 |

## ライセンス

MIT
