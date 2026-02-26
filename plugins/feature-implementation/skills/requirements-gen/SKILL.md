---
name: requirements-gen
description: フィーチャーの要件定義書を生成する。機能要件・非機能要件・受け入れ条件を整理し REQUIREMENTS.md として出力する。「要件定義」「要件」「requirements」「ユーザーストーリー」「受け入れ条件」で自動適用。
---

# 要件定義書生成

フィーチャーの概要をヒアリングし、要件定義書（REQUIREMENTS.md）を生成する。
ドキュメントテンプレートの詳細は → **references/REQUIREMENTS_TEMPLATE.md** を参照。

## ツール使用方針

- 既存コードの読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep / Glob ツールで直接ファイルを読み取る
- 既存プロジェクト構造の把握が必要な場合は codebase-scanner サブエージェントを活用する

## 入力

- **フィーチャー名**（例: `UserProfile`）
- **概要・背景**（自然言語による説明）
- **追加コンテキスト**（任意: 参考画面、API 仕様、既存機能との関連）

## 実行手順

### 1. 既存プロジェクトの確認

- プロジェクトのディレクトリ構造を Glob で確認する
- 関連する既存機能のコードを Grep で調査する
- API クライアントや Model の既存実装を把握する

### 2. ヒアリング

ユーザーに以下を確認する。

| 項目 | 必須 | 説明 |
|---|---|---|
| 機能の概要 | 必須 | 何を実現するか |
| 対象ユーザー | 任意 | 誰が使うか |
| 画面フロー | 任意 | 画面遷移の概要 |
| 外部 API | 任意 | 利用する API エンドポイント |
| 非機能要件 | 任意 | パフォーマンス・オフライン対応等 |

### 3. 要件定義書の生成

ヒアリング結果をもとに REQUIREMENTS.md を生成する。テンプレートは references/REQUIREMENTS_TEMPLATE.md に従う。

### 4. 出力

生成した REQUIREMENTS.md の内容をユーザーに提示し、確認を得てからファイルに書き込む。
配置先はユーザーの iOS プロジェクト内 `docs/features/<feature-name>/` とする。

```
docs/features/<feature-name>/REQUIREMENTS.md
```

## 出力形式

```
## 要件定義書生成結果

### 出力ファイル
- docs/features/<feature-name>/REQUIREMENTS.md

### 要件サマリー
- 機能要件: X 件
- 非機能要件: X 件
- 受け入れ条件: X 件

### 次のアクション
- [ ] 要件定義書の内容を確認・承認する
- [ ] 詳細設計書を作成する（/design-gen を推奨）
```
