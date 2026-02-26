---
name: glossary-gen
description: 全ドキュメントから用語を抽出し用語集（docs/glossary.md）を作成する。「用語集」「glossary」「ドメイン用語」「技術用語」「略語」「命名マッピング」で自動適用。
disable-model-invocation: true
---

# 用語集作成

`docs/` 配下の全ドキュメント（Step 1〜5 の出力）をスキャンし、用語集（`docs/glossary.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 入力

- `docs/` 配下の全ドキュメント（Step 1〜5 の出力）

## 前提条件

- `docs/` 配下に少なくとも 1 つのドキュメントが存在すること
- 存在しない場合はエラーメッセージを出して終了する
- 一部のドキュメントが欠けている場合は、存在するドキュメントのみを使って生成する（ただし警告を出す）

## 実行手順

### 1. ドキュメントの読み取り

以下のファイルを Read ツールで読み取る（存在するもののみ）。

- `docs/product-requirements.md`
- `docs/functional-design.md`
- `docs/architecture.md`
- `docs/repository-structure.md`
- `docs/development-guidelines.md`

### 2. 用語の抽出

全ドキュメントをスキャンし、以下のカテゴリに分類して用語を抽出する。

1. **ドメイン用語** — ビジネスドメイン固有の用語
2. **技術用語** — プロジェクトで使う技術用語とその文脈での意味
3. **略語** — 略語とその正式名称
4. **命名マッピング** — ドメイン用語 → コード上の命名（クラス名・変数名）の対応表

### 3. 用語集の生成

references/TEMPLATE.md に従い、用語集を生成する。

### 4. 出力

`docs/glossary.md` にファイルを書き込む。

## 出力形式

```
## 用語集生成結果

### 出力ファイル
- docs/glossary.md

### サマリー
- ドメイン用語: X 件
- 技術用語: X 件
- 略語: X 件
- 命名マッピング: X 件

### ワークフロー完了
全 6 ステップのスペック駆動開発ドキュメントが完成しました。
- [ ] docs/product-requirements.md
- [ ] docs/functional-design.md
- [ ] docs/architecture.md
- [ ] docs/repository-structure.md
- [ ] docs/development-guidelines.md
- [ ] docs/glossary.md
```
