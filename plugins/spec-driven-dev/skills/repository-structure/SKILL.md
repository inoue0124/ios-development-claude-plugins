---
name: repository-structure
description: 既存ドキュメントを元にリポジトリ構造定義書（docs/repository-structure.md）を作成する。「リポジトリ構造」「repository structure」「ディレクトリ構成」「フォルダ構成」「project.yml」で自動適用。
disable-model-invocation: true
---

# リポジトリ構造定義書作成

既存ドキュメントを元に、リポジトリ構造定義書（`docs/repository-structure.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 入力

- `docs/product-requirements.md`（必須）
- `docs/functional-design.md`（必須）
- `docs/architecture.md`（必須）
- 既存の `project.yml`（存在する場合）

## 前提条件

- 上記 3 つの docs ファイルが全て存在すること
- いずれかが存在しない場合はエラーメッセージを出して終了する

## 実行手順

### 1. 入力ドキュメントの読み取り

- `docs/product-requirements.md`, `docs/functional-design.md`, `docs/architecture.md` を Read ツールで読み取る
- 既存の `project.yml` が存在する場合は読み取り、現在の構成を把握する

### 2. Feature Module の列挙

機能設計書の画面一覧とデータモデルから、必要な Feature Module を全て列挙する。

### 3. リポジトリ構造定義書の生成

references/TEMPLATE.md に従い、以下のセクションを生成する。

1. **ディレクトリツリー** — 全ファイル・フォルダを tree 形式で表示。各ファイルに 1 行コメント
2. **XcodeGen 設定** — `project.yml` に追加すべき targets / sources / dependencies
3. **ファイル命名規則** — 各レイヤーの命名パターン一覧

### 4. 既存構成との差分

既存の `project.yml` がある場合、現在の構成との差分を明示する。

### 5. 出力

`docs/repository-structure.md` にファイルを書き込む。

## 出力形式

```
## リポジトリ構造定義書生成結果

### 出力ファイル
- docs/repository-structure.md

### サマリー
- Feature Module 数: X
- 総ファイル数: X
- 新規追加ディレクトリ数: X

### 次のアクション
- [ ] /development-guidelines で開発ガイドラインを作成する
```
