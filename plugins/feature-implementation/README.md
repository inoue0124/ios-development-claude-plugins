# feature-implementation — スペック駆動フィーチャー実装

要件定義書・詳細設計書・タスクリストを先に作成し、スペック駆動でフィーチャーを実装する。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | requirements-gen | 要件定義書の生成（機能要件・非機能要件・受け入れ条件） |
| skill | design-gen | 詳細設計書の生成（MVVM 設計・モジュール構成・API 設計） |
| skill | task-gen | 詳細設計書からタスクリストを生成 |
| skill (manual) | implement-feature | 仕様策定 → 承認 → タスク実装の一気通貫ワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| codebase-scanner | 既存プロジェクト構造を走査し、設計の前提情報を収集 |
