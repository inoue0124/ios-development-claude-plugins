---
name: functional-design
description: プロダクト要求定義書を元に機能設計書（docs/functional-design.md）を作成する。「機能設計」「functional design」「画面設計」「画面仕様」「データモデル」「API 仕様」で自動適用。
disable-model-invocation: true
---

# 機能設計書作成

プロダクト要求定義書（`docs/product-requirements.md`）を元に、機能設計書（`docs/functional-design.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 入力

- `docs/product-requirements.md`（必須）

## 前提条件

- `docs/product-requirements.md` が存在すること
- 存在しない場合は「`docs/product-requirements.md` が見つかりません。先に `/prd-writing` を実行してください。」とエラーを出して終了する

## 実行手順

### 1. PRD の読み取り

- `docs/product-requirements.md` を Read ツールで読み取る
- ユーザーストーリーと受け入れ条件を全て抽出する

### 2. 機能設計書の生成

references/TEMPLATE.md に従い、以下のセクションを生成する。

1. **画面一覧** — 画面名・概要・主要コンポーネントの表
2. **画面詳細仕様** — 画面ごとに以下を記述:
   - レイアウト構成（コンポーネント階層）
   - 状態一覧（state / binding / computed）
   - ユーザーインタラクション（アクション → 結果）
   - エラー状態とその表示
3. **画面遷移仕様** — Mermaid state diagram で遷移を定義。遷移トリガーと渡すパラメータ
4. **データモデル一覧** — エンティティ名・プロパティ・型・制約。エンティティ間の関連図
5. **API インターフェース仕様** — エンドポイントごとのリクエスト / レスポンス定義（型名まで）
6. **共通コンポーネント** — 再利用可能な UI コンポーネントの仕様

### 3. 網羅性の確認

PRD のユーザーストーリーと受け入れ条件が全て機能設計書で網羅されていることを確認する。

### 4. 出力

`docs/functional-design.md` にファイルを書き込む。

## 出力形式

```
## 機能設計書生成結果

### 出力ファイル
- docs/functional-design.md

### サマリー
- 画面数: X
- データモデル数: X
- API エンドポイント数: X
- 共通コンポーネント数: X

### 次のアクション
- [ ] /architecture-design でアーキテクチャ設計書を作成する
```
