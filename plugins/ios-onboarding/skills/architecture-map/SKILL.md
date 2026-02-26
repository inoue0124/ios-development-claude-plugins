---
name: architecture-map
description: アーキテクチャ構造をテキスト図で可視化する。レイヤー構成・データフロー・依存方向を図示。「アーキテクチャ図」「構造図」「レイヤー図」「データフロー」「可視化」で自動適用。
---

# アーキテクチャマップ

プロジェクトのアーキテクチャ構造をテキストベースの図で可視化し、レイヤー構成・データフロー・依存方向を一目で把握できるようにする。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Glob / Grep ツールで直接ファイルを読み取る

## 分析手順

1. プロジェクトのディレクトリ構造から、採用されているアーキテクチャパターンを推定する
2. レイヤー（View / ViewModel / Model / Repository / UseCase / Service 等）を特定する
3. 各レイヤーに属するファイル・型を分類する
4. レイヤー間の依存方向を `import` 文と型参照から分析する
5. データフロー（ユーザー操作 → View → ViewModel → UseCase → Repository → API）を推定する
6. テキストベースのアーキテクチャ図を生成する

## 出力形式

```
## アーキテクチャマップ

### アーキテクチャパターン
<MVVM / Clean Architecture / TCA 等の推定結果と根拠>

### レイヤー構成図

┌─────────────────────────────────────┐
│              View 層                 │
│  SwiftUI Views                      │
│  @State viewModel / @Bindable       │
├─────────────────────────────────────┤
│           ViewModel 層               │
│  @Observable / @MainActor           │
│  UI ロジック・状態管理               │
├─────────────────────────────────────┤
│          UseCase / Service 層        │
│  ビジネスロジック                     │
├─────────────────────────────────────┤
│          Repository 層               │
│  データアクセスの抽象化              │
│  Protocol 経由で依存                │
├─────────────────────────────────────┤
│          Model / Entity 層           │
│  ドメインモデル・DTO                 │
└─────────────────────────────────────┘

### データフロー

ユーザー操作
  → View (SwiftUI)
    → ViewModel (@Observable)
      → UseCase
        → Repository (Protocol)
          → APIClient / LocalStore
            → 外部 API / DB

### 依存方向

View → ViewModel → UseCase → Repository → Model
         ↓
      Protocol で抽象化（DIP）

### 主要コンポーネント対応表

| レイヤー | 代表的な型 | ファイルパス |
|---|---|---|
| View | <型名> | <パス> |
| ViewModel | <型名> | <パス> |
| UseCase | <型名> | <パス> |
| Repository | <型名> | <パス> |
| Model | <型名> | <パス> |
```

## 対象の特定

- 引数で特定の Feature モジュールが指定された場合はそのモジュールのアーキテクチャ図を生成する
- 指定がない場合はプロジェクト全体のアーキテクチャ図を生成する
