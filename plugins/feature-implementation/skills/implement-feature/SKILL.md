---
name: implement-feature
description: 仕様策定から実装までの一気通貫ワークフロー。requirements-gen・design-gen・task-gen と codebase-scanner サブエージェントを組み合わせて実行する
disable-model-invocation: true
---

# フィーチャー実装ワークフロー

> このスキルは `/implement-feature` で明示的に実行します。自動活性化されません。

要件定義書の作成から実装完了まで、スペック駆動でフィーチャーを実装するワークフロー。
個別スキル（requirements-gen, design-gen, task-gen）と
codebase-scanner サブエージェントを組み合わせて実行する。

## ツール使用方針

- 既存コードの読み取りは xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は CLI にフォールバックする
- codebase-scanner サブエージェントは CLI のみで動作する

## 実行フロー

### Step 1: ヒアリング

ユーザーに以下の情報を確認する。

| 項目 | 必須 | デフォルト |
|---|---|---|
| フィーチャー名（例: `UserProfile`） | 必須 | - |
| 概要・背景 | 必須 | - |
| 参考情報（画面デザイン、API 仕様等） | 任意 | なし |

### Step 2: プロジェクトスペック参照 + プロジェクト分析

#### 2-1. プロジェクトスペックの読み取り

`docs/` 配下にプロジェクトスペック（`/init-project-spec` で生成）が存在する場合、以下を読み取り設計の前提情報として活用する。

| ファイル | 参照内容 |
|---|---|
| `docs/product-requirements.md` | ユーザーストーリー・機能要件・非機能要件 |
| `docs/functional-design.md` | 画面一覧・データモデル・API 仕様 |
| `docs/architecture.md` | レイヤー設計・DI 戦略・ナビゲーション設計・テスト戦略 |
| `docs/repository-structure.md` | ディレクトリ構成・ファイル命名規則 |
| `docs/development-guidelines.md` | 実装パターン・禁止パターン・コーディング規約 |
| `docs/glossary.md` | ドメイン用語 → コード命名のマッピング |

存在しないファイルはスキップする（警告は出さない）。

#### 2-2. プロジェクト分析（subagent）

codebase-scanner サブエージェントを起動し、既存プロジェクトの構造を把握する。

- ディレクトリ構成・モジュール構成
- 既存の MVVM パターン
- DI の実装方式
- ナビゲーションの実装方式
- 共通ユーティリティ・コンポーネント

### Step 3: 要件定義書の作成

requirements-gen スキルに基づき REQUIREMENTS.md を生成する。

```
docs/features/<feature-name>/REQUIREMENTS.md
```

**ユーザー承認を待つ。** 承認後、次のステップへ進む。

### Step 4: 詳細設計書の作成

design-gen スキルに基づき DESIGN.md を生成する。
Step 2 のプロジェクトスペックとプロジェクト分析結果を反映し、既存コードとの整合性を確保する。
特に `docs/architecture.md` のレイヤー設計・DI 戦略・ナビゲーション設計に準拠すること。

```
docs/features/<feature-name>/DESIGN.md
```

**ユーザー承認を待つ。** 承認後、次のステップへ進む。

### Step 5: タスクリスト生成

task-gen スキルに基づき TASKS.md を生成する。

```
docs/features/<feature-name>/TASKS.md
```

**ユーザー承認を待つ。** 承認後、次のステップへ進む。

### Step 6: タスク実装

TASKS.md のタスクを順番に実装する。

1. タスクリストの先頭から未完了タスク（`- [ ]`）を取得する
2. 対象ファイルの実装内容に従いコードを生成する
3. 構文検証を行う
   - MCP: XcodeBuildMCP の `swift_typecheck`
   - CLI: `swift build --target <TargetName>`（SPM プロジェクト）。単一ファイルの簡易確認には `swiftc -typecheck` を補助的に使用
4. タスクを完了に更新する（`- [x]`）
5. 次の未完了タスクへ進む

各タスク完了時にユーザーに進捗を報告する。

### Step 7: 最終確認

全タスク完了後、以下を確認する。

1. 全ファイルの構文検証
2. TASKS.md の全タスクがチェック済みであること
3. REQUIREMENTS.md の受け入れ条件との照合

## ドキュメント配置先

```
docs/features/<feature-name>/
├── REQUIREMENTS.md    # 要件定義書
├── DESIGN.md          # 詳細設計書
└── TASKS.md           # タスクリスト（チェックボックス付き）
```

## 出力形式

```
## フィーチャー実装結果: <フィーチャー名>

### ドキュメント
- docs/features/<feature-name>/REQUIREMENTS.md
- docs/features/<feature-name>/DESIGN.md
- docs/features/<feature-name>/TASKS.md

### 実装ファイル
- <生成・変更したファイルの一覧>

### タスク進捗
- 完了: X / X タスク

### 構文検証: PASS / FAIL

### 次のアクション
- [ ] ユニットテストを作成する（/unit-test-gen を推奨）
- [ ] MVVM 準拠を確認する（/mvvm-check を推奨）
- [ ] PR を作成する（/pr-create を推奨）
```
