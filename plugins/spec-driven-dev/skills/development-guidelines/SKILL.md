---
name: development-guidelines
description: 既存ドキュメントを元に開発ガイドライン（docs/development-guidelines.md）を作成する。「開発ガイドライン」「development guidelines」「コーディング規約」「実装パターン」「禁止パターン」で自動適用。
disable-model-invocation: true
---

# 開発ガイドライン作成

既存ドキュメントとプロジェクトの CLAUDE.md を元に、開発ガイドライン（`docs/development-guidelines.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 入力

- `docs/product-requirements.md`（必須）
- `docs/architecture.md`（必須）
- `docs/repository-structure.md`（必須）
- プロジェクトの `CLAUDE.md`（存在する場合）

## 前提条件

- 上記 3 つの docs ファイルが全て存在すること
- いずれかが存在しない場合はエラーメッセージを出して終了する

## 位置づけ

`CLAUDE.md` の規約を詳細化・補足する位置づけ。CLAUDE.md の内容と矛盾しないこと。

## 実行手順

### 1. 入力ドキュメントの読み取り

- 上記 docs ファイルを Read ツールで読み取る
- プロジェクトの `CLAUDE.md` が存在する場合は読み取り、既存規約を把握する

### 2. 開発ガイドラインの生成

references/TEMPLATE.md に従い、以下のセクションを生成する。

1. **コーディング規約** — 命名規則・ファイル構成・アクセスコントロール・SwiftLint / SwiftFormat ルールの補足
2. **実装パターン集** — View / ViewModel / Repository / Model / DI / Navigation のコードテンプレート
3. **禁止パターン** — 使ってはいけない API とその理由・代替手段
4. **Git ワークフロー** — ブランチ戦略・Conventional Commits・PR テンプレート
5. **テストガイドライン** — テスト命名規則・Mock の作り方・カバレッジ基準

### 3. CLAUDE.md との整合性確認

以下を確認する:
- `@Observable` を推奨し、`ObservableObject` を禁止パターンに含めていること
- `@State` / `@Bindable` / `@Environment` を推奨していること
- Swift Concurrency への準拠を求めていること
- `CLAUDE.md` の規約に矛盾する記述がないこと

### 4. 出力

`docs/development-guidelines.md` にファイルを書き込む。

## 出力形式

```
## 開発ガイドライン生成結果

### 出力ファイル
- docs/development-guidelines.md

### サマリー
- コーディング規約: X 項目
- 実装パターン: X パターン
- 禁止パターン: X 項目

### 次のアクション
- [ ] /glossary-gen で用語集を作成する
```
