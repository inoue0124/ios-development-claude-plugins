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

### スキルの種別

| 表記 | 意味 | `disable-model-invocation` |
|---|---|---|
| skill | Claude が文脈に応じて自動で発火する | `false`（デフォルト） |
| skill (manual) | ユーザーが `/skill-name` で明示的に実行する。ワークフローや副作用を伴う操作 | `true` |

### Tier 1: 日常の開発サイクルで毎日使うもの

#### 1. `ios-architecture` — アーキテクチャガード

MVVM パターンの構造チェック・レイヤー間の依存方向検査・DI パターンの提案を行う。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | mvvm-check | View / ViewModel / Model 分離の検査 |
| skill | layer-dependency-check | レイヤー間の依存方向チェック |
| skill | di-pattern-suggest | Dependency Injection パターンの提案 |
| skill | protocol-oriented-check | Protocol 指向設計の推奨・改善提案 |
| skill | concurrency-check | Swift Concurrency の安全性検査（Swift 6.2+） |
| subagent | architecture-scanner | 全モジュールの依存関係分析 |
| skill (manual) | arch-audit | アーキテクチャ全体監査ワークフロー |

#### 2. `team-conventions` — 規約エンフォーサー

チームのコーディング規約・命名規則・ブランチ運用ルールを自動で検査・強制する。
hooks でコード生成前に規約を注入し、最初から規約通りに書く。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | naming-check | Swift 命名規則（API Design Guidelines 準拠）チェック |
| skill | file-structure-check | ファイル配置がチーム規約に沿っているか検査 |
| skill | commit-message-lint | コミットメッセージ形式チェック |
| skill | branch-naming-check | ブランチ命名規則の検証 |
| skill | pr-description-gen | PR テンプレートに基づく説明文の自動生成 |
| subagent | convention-scanner | プロジェクト全体の規約準拠スキャン |
| skill (manual) | convention-check | 変更ファイルに対する規約チェック一括ワークフロー |
| hooks | UserPromptSubmit | コード生成時に規約をコンテキスト注入 |

#### 3. `swift-code-quality` — コード品質ガード

SwiftLint / SwiftFormat による静的解析と軽量な構文チェックで、フルビルドなしにコード品質を担保する。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | swift-lint | SwiftLint 実行 + 違反の自動修正 |
| skill | swift-format | SwiftFormat 実行 |
| skill | syntax-typecheck | `swiftc -typecheck` による軽量構文チェック |
| skill | complexity-analysis | 循環的複雑度・関数行数の分析 |
| skill | dead-code-detect | 未使用コード・未使用 import の検出 |
| skill | type-safety-check | force unwrap / force cast の検出 + 安全な書き換え提案 |
| subagent | lint-scanner | プロジェクト全体の lint 一括スキャン |
| skill (manual) | quality-check | lint + format + typecheck 一括ワークフロー |

#### 4. `swift-testing` — テスト生成・実行

ユニットテスト・UI テストの生成からテスト実行・カバレッジ分析まで、テストのライフサイクル全体をサポートする。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | unit-test-gen | 対象コードからユニットテスト生成 |
| skill | ui-test-gen | SwiftUI 画面から XCUITest 生成 |
| skill | mock-gen | Protocol 準拠のモック / スタブ自動生成 |
| skill | test-pattern-suggest | テスト対象に適切なテストパターンを提案 |
| skill | coverage-gap-detect | テスト未カバーのパスを特定 |
| subagent | test-runner | テスト実行（xcodebuild test）+ 結果パース |
| subagent | coverage-reporter | カバレッジ収集 + レポート生成 |
| skill (manual) | test-gen | テスト生成 → 実行 → カバレッジ一括ワークフロー |

#### 5. `github-workflow` — Issue / PR 管理

構造化された issue 作成と、差分解析に基づく PR 作成でチームのタスク管理を標準化する。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill (manual) | issue-create | 構造化された issue 作成 |
| skill | issue-triage | ラベル・優先度・アサイン提案 |
| skill (manual) | pr-create | 差分解析 + 説明文生成 + PR 作成 |
| skill | pr-checklist | セルフレビューチェックリスト |
| skill (manual) | pr-link-issues | PR と issue の紐付け |

#### 6. `code-review-assist` — コードレビュー支援

PR の差分を分析し、レビューコメントの生成・アーキテクチャ適合チェック・影響範囲の特定を行う。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | pr-diff-review | PR 差分を読んでレビューコメント生成 |
| skill | architecture-conformance | 変更が MVVM / レイヤー規約に沿っているか検査 |
| skill | impact-analysis | 変更の影響範囲を特定（依存先・呼び出し元） |
| skill | review-comment-draft | 指摘コメントを「理由 + 提案」形式で下書き |
| subagent | review-analyzer | PR 全体を包括分析（大規模差分の隔離実行） |
| skill (manual) | pr-review | 上記を組み合わせた包括レビューワークフロー |

### Tier 2: プロジェクト構築・配信フェーズで使うもの

#### 7. `ios-onboarding` — オンボーディング支援

プロジェクト構造の自動解説・用語集生成・最近の変更要約で、新メンバーの立ち上がりを加速する。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | codebase-overview | プロジェクト構造の概要を自動生成 |
| skill | module-guide | 各 SPM モジュールの責務と依存関係を解説 |
| skill | architecture-map | アーキテクチャ構造をテキスト図で可視化 |
| skill | glossary-gen | プロジェクト固有の用語集を生成 |
| skill | recent-changes-summary | 直近のコミットから「今何が起きているか」を要約 |
| subagent | codebase-analyzer | プロジェクト全体を走査して構造分析 |
| skill (manual) | onboard | 新メンバー向けガイド一式生成ワークフロー |

#### 8. `feature-module-gen` — Feature Module 生成

SwiftUI + MVVM の Feature Module 雛形を一式生成し、SPM パッケージへの組み込みまで行う。新機能開発の立ち上げ。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | feature-scaffold | Feature Module 雛形（View / ViewModel / Repository / DI）一式生成 |
| skill | view-gen | SwiftUI View 生成（チーム規約準拠） |
| skill | viewmodel-gen | ViewModel 生成（Input / Output, @Published 等） |
| skill | repository-gen | Repository + Protocol 生成 |
| skill | usecase-gen | UseCase 生成 |
| subagent | module-generator | モジュール一式生成 + Package.swift 更新 + 構文検証 |
| skill (manual) | new-feature | 対話的に Feature Module 一式生成ワークフロー |

#### 9. `ios-distribution` — TestFlight 配信・署名

アーカイブビルドから TestFlight アップロードまでの配信フローを自動化する。

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | signing-check | 署名・プロビジョニング確認 |
| skill (manual) | build-archive | IPA 生成 |
| skill (manual) | testflight-upload | archive + upload（xcodebuild + xcrun altool） |
| subagent | archive-runner | アーカイブ + アップロード（隔離実行） |

## subagent 一覧

| subagent | 所属プラグイン | 隔離理由 |
|---|---|---|
| architecture-scanner | ios-architecture | 依存関係の全体分析 |
| convention-scanner | team-conventions | プロジェクト全体の規約スキャン |
| lint-scanner | swift-code-quality | 全体 lint 一括スキャン |
| test-runner | swift-testing | テスト実行 + ログパース |
| coverage-reporter | swift-testing | カバレッジ収集 + レポート |
| review-analyzer | code-review-assist | 大規模 PR 差分の全体分析 |
| codebase-analyzer | ios-onboarding | 全体構造の走査 + 分析 |
| module-generator | feature-module-gen | モジュール一式生成 + 構文検証 |
| archive-runner | ios-distribution | アーカイブ + アップロード |

## ディレクトリ構成

```
ios-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json          # マーケットプレイス定義
├── plugins/
│   ├── ios-architecture/          # 1. 設計ガード
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── skills/
│   │   │   ├── mvvm-check/
│   │   │   │   └── SKILL.md
│   │   │   ├── layer-dependency-check/
│   │   │   ├── di-pattern-suggest/
│   │   │   ├── protocol-oriented-check/
│   │   │   └── arch-audit/        # workflow (manual)
│   │   └── agents/
│   │       └── architecture-scanner.md
│   ├── team-conventions/          # 2. 規約エンフォース
│   ├── swift-code-quality/        # 3. 品質チェック
│   ├── swift-testing/             # 4. テスト
│   ├── github-workflow/           # 5. Issue / PR
│   ├── code-review-assist/        # 6. レビュー
│   ├── ios-onboarding/            # 7. オンボーディング
│   ├── feature-module-gen/        # 8. モジュール生成
│   └── ios-distribution/          # 9. 配信
├── CLAUDE.md
└── README.md
```

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
