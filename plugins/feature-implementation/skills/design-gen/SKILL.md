---
name: design-gen
description: フィーチャーの詳細設計書を生成する。MVVM レイヤー構成・モジュール設計・API 連携・ナビゲーション設計を DESIGN.md として出力する。「詳細設計」「設計書」「design」「アーキテクチャ設計」「モジュール設計」で自動適用。
---

# 詳細設計書生成

要件定義書（REQUIREMENTS.md）をもとに、SwiftUI + MVVM アーキテクチャに準拠した詳細設計書（DESIGN.md）を生成する。
ドキュメントテンプレートの詳細は → **references/DESIGN_TEMPLATE.md** を参照。

## ツール使用方針

- 既存コードの読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep / Glob ツールで直接ファイルを読み取る
- 既存プロジェクト構造の走査が必要な場合は codebase-scanner サブエージェントを活用する

## 入力

- **フィーチャー名**（例: `UserProfile`）
- **要件定義書**（`docs/features/<feature-name>/REQUIREMENTS.md`）
- **追加コンテキスト**（任意: 既存コードの参照、チーム規約）

## 前提条件

- 要件定義書（REQUIREMENTS.md）が存在すること
- 存在しない場合は requirements-gen スキルの実行を先に案内する

## 実行手順

### 1. 要件定義書の読み込み

`docs/features/<feature-name>/REQUIREMENTS.md` を Read ツールで読み取る。

### 2. 既存プロジェクトの分析

codebase-scanner サブエージェントまたは直接ファイル読み取りで以下を確認する。

- 既存のモジュール構成（SPM パッケージ / ディレクトリ構造）
- 既存の DI パターン
- ナビゲーションの実装方針（NavigationStack / Router パターン等）
- 共通コンポーネント・ユーティリティ

### 3. 詳細設計書の生成

要件と既存コードの分析結果をもとに DESIGN.md を生成する。テンプレートは references/DESIGN_TEMPLATE.md に従う。

### 4. 出力

生成した DESIGN.md の内容をユーザーに提示し、確認を得てからファイルに書き込む。
配置先はユーザーの iOS プロジェクト内とする。

```
docs/features/<feature-name>/DESIGN.md
```

## Swift 6.2 / SwiftUI 設計基準

設計書では以下の基準に準拠する。

### ViewModel

- `@Observable class` で宣言する（`ObservableObject` / `@Published` は使わない）
- Repository は Protocol 経由でコンストラクタ注入する
- `Sendable` 準拠を考慮する

### View

- ViewModel は `@State` で保持する（`@StateObject` は使わない）
- DI は `@Environment` で注入する（`@EnvironmentObject` は使わない）
- `@Bindable` でバインディングを取得する

### Model / Repository

- Protocol と具象実装を分離する
- `async throws` でメソッドを定義する
- `Sendable` に準拠する

### ナビゲーション

- `NavigationStack` + `navigationDestination` を使用する
- 型安全なルーティングを設計する

## 出力形式

```
## 詳細設計書生成結果

### 出力ファイル
- docs/features/<feature-name>/DESIGN.md

### 設計サマリー
- View コンポーネント: X 個
- ViewModel: X 個
- Repository: X 個
- UseCase: X 個

### 次のアクション
- [ ] 詳細設計書の内容を確認・承認する
- [ ] タスクリストを生成する（/task-gen を推奨）
```
