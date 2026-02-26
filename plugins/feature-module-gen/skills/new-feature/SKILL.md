---
name: new-feature
description: 対話的に Feature Module 一式を生成するワークフロー。feature-scaffold・view-gen・viewmodel-gen・repository-gen・usecase-gen と module-generator サブエージェントを組み合わせて実行する
disable-model-invocation: true
---

# Feature Module 一式生成ワークフロー

> このスキルは `/new-feature` で明示的に実行します。自動活性化されません。

対話的に Feature Module の構成を決定し、一式を生成するワークフロー。
個別スキル（feature-scaffold, view-gen, viewmodel-gen, repository-gen, usecase-gen）と
module-generator サブエージェントを組み合わせて実行する。

## ツール使用方針

- ファイル生成は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `mkdir -p` / `cat` / `swiftc -typecheck` 等の CLI にフォールバックする
- module-generator サブエージェントは CLI のみで動作する

## 実行フロー

### Step 1: ヒアリング

ユーザーに以下の情報を確認する。

| 項目 | 必須 | デフォルト |
|---|---|---|
| Feature 名（例: `UserProfile`） | 必須 | - |
| 出力ディレクトリ | 任意 | `Sources/<Feature名>Feature/` |
| UseCase の有無 | 任意 | あり |
| Repository の有無 | 任意 | あり |
| 追加の画面（子 View）の有無 | 任意 | なし |
| SPM Package.swift への追加 | 任意 | あり（既存の Package.swift がある場合） |

### Step 2: ファイル生成（subagent）

module-generator サブエージェントを起動し、以下を実行する。

1. ディレクトリ構造の作成
2. 各ファイルの生成（feature-scaffold に準拠したテンプレート）
3. Package.swift への target 追加（SPM プロジェクトの場合）
4. 生成ファイルの構文検証

### Step 3: 個別スキルによる検証

生成されたファイルに対し、以下のスキルで品質を確認する。

1. **view-gen** の規約に準拠しているか
2. **viewmodel-gen** の規約に準拠しているか
3. **repository-gen** の規約に準拠しているか
4. **usecase-gen** の規約に準拠しているか

### Step 4: 結果レポート

生成結果を報告し、次のアクションを提案する。

## 出力

```
## Feature Module 生成結果: <Feature名>Feature

### 生成ファイル一覧
- Views/<Feature名>View.swift
- ViewModels/<Feature名>ViewModel.swift
- Repositories/<Feature名>RepositoryProtocol.swift
- Repositories/<Feature名>Repository.swift
- UseCases/<Feature名>UseCase.swift
- DI/<Feature名>Dependency.swift

### 構文検証: PASS / FAIL
- <ファイル名>: OK / NG（エラー内容）

### Package.swift: 更新済み / スキップ

### 次のアクション
- [ ] 生成された TODO コメントを実装に置き換える
- [ ] ユニットテストを作成する（/unit-test-gen を推奨）
- [ ] MVVM 準拠を確認する（/mvvm-check を推奨）
```
