---
name: architecture-design
description: 既存ドキュメントを元にアーキテクチャ設計書（docs/architecture.md）を作成する。「アーキテクチャ設計」「architecture design」「レイヤー設計」「DI 設計」「ナビゲーション設計」で自動適用。
disable-model-invocation: true
---

# アーキテクチャ設計書作成

プロダクト要求定義書と機能設計書を元に、アーキテクチャ設計書（`docs/architecture.md`）を作成する。
テンプレートの詳細は → **references/TEMPLATE.md** を参照。

## 入力

- `docs/product-requirements.md`（必須）
- `docs/functional-design.md`（必須）
- プロジェクトの `CLAUDE.md`（存在する場合）

## 前提条件

- `docs/product-requirements.md` と `docs/functional-design.md` が存在すること
- いずれかが存在しない場合はエラーメッセージを出して終了する

## 技術スタック前提

| 項目 | 値 |
|---|---|
| 言語 | Swift 6.2 |
| UI | SwiftUI |
| 状態管理 | `@Observable`（Observation フレームワーク） |
| 並行処理 | Swift Concurrency（async/await, Sendable, actor） |
| DI | `@Environment` + `EnvironmentKey` パターン |
| ナビゲーション | `NavigationStack` + Route enum |
| プロジェクト生成 | XcodeGen（`project.yml`） |

## 実行手順

### 1. 入力ドキュメントの読み取り

- `docs/product-requirements.md` を Read ツールで読み取る
- `docs/functional-design.md` を Read ツールで読み取る
- プロジェクトの `CLAUDE.md` が存在する場合は読み取り、既存規約を把握する

### 2. アーキテクチャ設計書の生成

references/TEMPLATE.md に従い、以下のセクションを生成する。

1. **アーキテクチャ概要** — レイヤー図と各レイヤーの責務
2. **技術スタック** — 選定技術とその理由
3. **レイヤー設計** — View / ViewModel / Repository / Model 各層の設計方針
4. **DI 戦略** — `@Environment` + `EnvironmentKey` パターン
5. **ナビゲーション設計** — `NavigationStack` + Route enum
6. **エラーハンドリング方針** — エラー分類と UI 表現
7. **データフロー図** — Mermaid sequence diagram
8. **テスト戦略** — ユニットテスト方針・Mock の作り方

### 3. 規約との整合性確認

`CLAUDE.md` の内容と矛盾がないことを確認する。特に以下をチェック:

- `@Observable` を使用し、`ObservableObject` を使っていないこと
- `@State` / `@Bindable` / `@Environment` を使用していること
- Swift Concurrency（`Sendable`, actor 分離）に準拠していること

### 4. 出力

`docs/architecture.md` にファイルを書き込む。

## 出力形式

```
## アーキテクチャ設計書生成結果

### 出力ファイル
- docs/architecture.md

### サマリー
- レイヤー数: 4（View / ViewModel / Repository / Model）
- DI パターン: @Environment + EnvironmentKey
- ナビゲーション: NavigationStack + Route enum

### 次のアクション
- [ ] /repository-structure でリポジトリ構造定義書を作成する
```
