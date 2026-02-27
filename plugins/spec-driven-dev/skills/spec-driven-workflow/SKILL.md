---
name: spec-driven-workflow
description: スペック駆動開発の一気通貫ワークフロー。prd-writing・functional-design・architecture-design・repository-structure・development-guidelines・glossary-gen を順番に実行する
disable-model-invocation: true
---

# スペック駆動開発ワークフロー

> このスキルは `/spec-driven-workflow` で明示的に実行します。自動活性化されません。

6 つの atomic スキルを順番に実行し、`docs/` 配下にプロジェクトスペック一式を生成する。
Step 1（PRD）のみユーザー承認を挟み、Step 2〜6 は前ステップの出力を入力として自動的に生成する。

## 対象プロジェクトの前提

| 項目 | 値 |
|---|---|
| 言語 | Swift 6.2 |
| UI | SwiftUI |
| アーキテクチャ | MVVM（View → ViewModel → Repository → Model） |
| 状態管理 | `@Observable`（Observation フレームワーク） |
| 並行処理 | Swift Concurrency（async/await, Sendable） |
| プロジェクト生成 | XcodeGen（`project.yml`） |
| Lint / Format | SwiftLint / SwiftFormat（Mint 管理） |

## 出力先

```
docs/
├── ideas/                      # ユーザーが事前に置くアイデアメモ（入力）
├── product-requirements.md     # Step 1 で生成
├── functional-design.md        # Step 2 で生成
├── architecture.md             # Step 3 で生成
├── repository-structure.md     # Step 4 で生成
├── development-guidelines.md   # Step 5 で生成
└── glossary.md                 # Step 6 で生成
```

## 実行フロー

### Step 1: プロダクト要求定義書（PRD）

prd-writing スキルに基づき `docs/product-requirements.md` を生成する。

1. `docs/ideas/` 配下のファイルを全て読み取る
2. `docs/ideas/` が空または存在しない場合、ユーザーにヒアリングしてアイデアを引き出す
3. references/TEMPLATE.md に従い PRD を生成する
4. **ユーザー承認を待つ。** 承認後、`docs/product-requirements.md` に書き込む

生成内容:
- プロダクト概要（目的・ターゲットユーザー・課題）
- ユーザーストーリー一覧（MoSCoW 優先度付き）
- 画面フロー（Mermaid 図）
- 機能要件（画面ごとの入力・処理・出力）
- 非機能要件（パフォーマンス・アクセシビリティ等）
- 外部依存（API エンドポイント・サードパーティ SDK）
- 受け入れ条件（検証方法付き）
- 成功指標（KPI）
- スコープ外

### Step 2: 機能設計書

functional-design スキルに基づき `docs/functional-design.md` を生成する。

入力: `docs/product-requirements.md`

生成内容:
- 画面一覧（画面名・概要・主要コンポーネント）
- 画面詳細仕様（レイアウト・状態・インタラクション・エラー状態）
- 画面遷移仕様（Mermaid state diagram）
- データモデル一覧（エンティティ・プロパティ・型・制約）
- API インターフェース仕様（リクエスト / レスポンス定義）
- 共通コンポーネント仕様

PRD のユーザーストーリーと受け入れ条件を全て網羅すること。

### Step 3: アーキテクチャ設計書

architecture-design スキルに基づき `docs/architecture.md` を生成する。

入力: `docs/product-requirements.md`, `docs/functional-design.md`, `CLAUDE.md`

生成内容:
- アーキテクチャ概要（レイヤー図・各レイヤーの責務）
- 技術スタック（選定理由付き）
- レイヤー設計（View / ViewModel / Repository / Model）
- DI 戦略（`@Environment` + `EnvironmentKey`）
- ナビゲーション設計（`NavigationStack` + Route enum）
- エラーハンドリング方針
- データフロー図（Mermaid sequence diagram）
- テスト戦略

`CLAUDE.md` の規約と矛盾しないこと。

### Step 4: リポジトリ構造定義書

repository-structure スキルに基づき `docs/repository-structure.md` を生成する。

入力: `docs/product-requirements.md`, `docs/functional-design.md`, `docs/architecture.md`

生成内容:
- ディレクトリツリー（全ファイルに 1 行コメント付き）
- Feature Module 一覧
- XcodeGen 設定（`project.yml`）
- ファイル命名規則

既存の `project.yml` がある場合は差分を明示する。

### Step 5: 開発ガイドライン

development-guidelines スキルに基づき `docs/development-guidelines.md` を生成する。

入力: `docs/product-requirements.md`, `docs/architecture.md`, `docs/repository-structure.md`, `CLAUDE.md`

生成内容:
- コーディング規約（命名規則・ファイル構成・アクセスコントロール）
- 実装パターン集（View / ViewModel / Repository / Model / DI / Navigation）
- 禁止パターン（`ObservableObject`, `@StateObject`, `@EnvironmentObject`, `DispatchQueue` 等）
- Git ワークフロー（ブランチ戦略・Conventional Commits・PR テンプレート）
- テストガイドライン（命名規則・Mock・カバレッジ基準）

`CLAUDE.md` の規約を詳細化・補足する位置づけ。矛盾しないこと。

### Step 6: 用語集

glossary-gen スキルに基づき `docs/glossary.md` を生成する。

入力: `docs/` 配下の全ドキュメント（Step 1〜5 の出力）

生成内容:
- ドメイン用語（日本語 / 英語 / 定義 / コード上の命名）
- 技術用語（プロジェクトでの意味）
- 略語（正式名称）
- 命名マッピング（ドメイン概念 → View / ViewModel / Repository / Model）

## エラーハンドリング

- 必要な入力ドキュメントが存在しない場合、「`docs/xxx.md` が見つかりません。先に `/yyy` を実行してください。」とエラーを出して終了する
- 一部のドキュメントが欠けている場合は、存在するドキュメントのみを使って生成する（ただし警告を出す）

## 出力規約

- 全ドキュメントは日本語で記述する
- Mermaid 図を積極的に使う（画面遷移、データフロー、レイヤー図）
- コード例は Swift で記述し、プロジェクトの規約（Swift 6.2, `@Observable` 等）に準拠する
- 各ドキュメントの冒頭に生成日時とステータス（Draft / Approved）を記載する

## 出力形式

```
## スペック駆動開発 完了

### 生成ドキュメント
- [x] docs/product-requirements.md（Approved）
- [x] docs/functional-design.md
- [x] docs/architecture.md
- [x] docs/repository-structure.md
- [x] docs/development-guidelines.md
- [x] docs/glossary.md

### 次のアクション
- [ ] 各ドキュメントの内容を確認する
- [ ] /implement-feature でフィーチャー実装を開始する
```
