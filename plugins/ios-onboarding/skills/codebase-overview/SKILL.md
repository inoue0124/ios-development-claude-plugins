---
name: codebase-overview
description: プロジェクト構造の概要を自動生成する。ディレクトリ構成・モジュール一覧・使用技術スタックを整理して新メンバーに提示。「プロジェクト構造」「概要」「構成」「オンボーディング」「全体像」で自動適用。
---

# プロジェクト構造の概要生成

プロジェクトのディレクトリ構造・モジュール構成・使用技術スタックを自動的に読み取り、新メンバーが最初に把握すべき全体像を生成する。

## ツール使用方針

- ファイル・ディレクトリの読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Glob / Grep ツールで直接読み取る
- `Package.swift` の解析は xcodeproj-mcp-server を優先し、CLI フォールバックでは Read で直接読み取る

## 分析手順

1. プロジェクトルートのディレクトリ構成を Glob で走査する
2. `Package.swift` / `.xcodeproj` / `.xcworkspace` を読み取り、プロジェクト種別を判定する
3. SPM の場合は `Package.swift` からターゲット一覧を抽出する
4. 主要なディレクトリの役割をパス名から推定する（`Sources/`, `Views/`, `ViewModels/` 等）
5. 使用技術スタック（SwiftUI / UIKit / Combine / Swift Concurrency 等）を `import` 文から推定する
6. 結果を構造化して出力する

## 出力形式

```
## プロジェクト概要

### 基本情報
- プロジェクト種別: <SPM / Xcode Project / Workspace>
- Swift バージョン: <Package.swift の swift-tools-version または推定>
- UI フレームワーク: <SwiftUI / UIKit / 混合>

### ディレクトリ構成
<主要ディレクトリのツリー表示と各ディレクトリの役割>

### モジュール一覧
| モジュール名 | 種別 | 概要 |
|---|---|---|
| <名前> | <Library / Executable / Test> | <推定される役割> |

### 使用技術スタック
- UI: SwiftUI
- アーキテクチャ: MVVM
- 状態管理: @Observable (Observation フレームワーク)
- 非同期処理: Swift Concurrency (async/await)
- ネットワーク: <URLSession / Alamofire 等>
- DI: <手動 / Swinject 等>
- その他: <検出されたフレームワーク>

### 新メンバーが最初に見るべきファイル
1. <ファイルパス> - <理由>
2. <ファイルパス> - <理由>
3. <ファイルパス> - <理由>
```

## 対象の特定

- 引数でプロジェクトルートが指定された場合はそのパスを使用する
- 指定がない場合はカレントディレクトリをプロジェクトルートとする
