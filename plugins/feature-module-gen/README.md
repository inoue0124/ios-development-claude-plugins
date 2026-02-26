# feature-module-gen — Feature Module 生成

SwiftUI + MVVM の Feature Module 雛形を一式生成し、SPM パッケージへの組み込みまで行う。新機能開発の立ち上げ。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | feature-scaffold | Feature Module 雛形（View / ViewModel / Repository / DI）一式生成 |
| skill | view-gen | SwiftUI View 生成（チーム規約準拠） |
| skill | viewmodel-gen | ViewModel 生成（@Observable ベース） |
| skill | repository-gen | Repository + Protocol 生成 |
| skill | usecase-gen | UseCase 生成 |
| skill (manual) | new-feature | 対話的に Feature Module 一式生成ワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| module-generator | モジュール一式生成 + Package.swift 更新 + 構文検証 |
