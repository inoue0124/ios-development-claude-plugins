---
name: prd-writing
description: docs/ideas/ を元にプロダクト要求定義書（docs/product-requirements.md）を作成する。「PRD」「プロダクト要求」「要求定義」「product requirements」「アイデア具体化」で自動適用。
disable-model-invocation: true
---

# プロダクト要求定義書（PRD）作成

`docs/ideas/` 配下のアイデアメモを元に、プロダクト要求定義書（`docs/product-requirements.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 対象プロジェクトの前提

| 項目 | 値 |
|---|---|
| 言語 | Swift 6.2 |
| UI | SwiftUI |
| アーキテクチャ | MVVM（View → ViewModel → Repository → Model） |
| 状態管理 | `@Observable`（Observation フレームワーク） |
| 並行処理 | Swift Concurrency（async/await, Sendable） |

## 入力

- `docs/ideas/` 配下のファイル群

## 実行手順

### 1. アイデアの読み取り

- `docs/ideas/` 配下の全ファイルを Read ツールで読み取る
- `docs/ideas/` が空または存在しない場合、ユーザーにヒアリングしてアイデアを引き出す

### 2. PRD の生成

references/TEMPLATE.md に従い、以下のセクションを生成する。

1. **プロダクト概要** — アプリの目的、ターゲットユーザー、解決する課題
2. **ユーザーストーリー一覧** — 「〜として、〜したい、なぜなら〜」形式。MoSCoW 優先度付き
3. **画面フロー** — Mermaid 図で画面遷移を可視化
4. **機能要件** — 画面ごとの入力・処理・出力
5. **非機能要件** — パフォーマンス、アクセシビリティ、オフライン対応、セキュリティ、ローカライゼーション
6. **外部依存** — API エンドポイント（メソッド・パス・概要）、サードパーティ SDK
7. **受け入れ条件** — 具体的・検証可能な条件。検証方法を明記
8. **成功指標** — KPI（定量的な目標値）
9. **スコープ外** — 明示的に含めない項目

### 3. ユーザー承認

- 生成した PRD の内容をユーザーに提示し「この内容でよいですか？」と確認を求める
- ユーザーがフィードバックを返した場合、修正して再度確認を求める
- **承認されるまで `docs/product-requirements.md` に書き込まない**

### 4. 出力

承認後、`docs/product-requirements.md` にファイルを書き込む。

## 出力形式

```
## PRD 生成結果

### 出力ファイル
- docs/product-requirements.md

### サマリー
- ユーザーストーリー: X 件（Must: X / Should: X / Could: X）
- 機能要件: X 件
- 非機能要件: X 件
- 受け入れ条件: X 件

### 次のアクション
- [ ] /functional-design で機能設計書を作成する
```
