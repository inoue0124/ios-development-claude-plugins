---
name: feature-scaffold
description: Feature Module の雛形（View / ViewModel / Repository / DI）一式を生成する。「Feature Module」「雛形生成」「スキャフォールド」「scaffold」「新機能モジュール」で自動適用。
---

# Feature Module 雛形生成

指定された Feature 名をもとに、SwiftUI + MVVM アーキテクチャに準拠した Feature Module の雛形ファイル一式を生成する。

## ツール使用方針

- ファイル作成・プロジェクトへの追加は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `mkdir -p` / `cat` / `swift build` 等の CLI にフォールバックする

## 入力

- **Feature 名**（例: `UserProfile`）
- **出力ディレクトリ**（省略時はプロジェクトルートの `Sources/` を推定）
- **オプション**: UseCase の有無、Repository の有無

## 生成ファイル一覧

Feature 名が `UserProfile` の場合:

```
Sources/UserProfileFeature/
├── Views/
│   └── UserProfileView.swift
├── ViewModels/
│   └── UserProfileViewModel.swift
├── Repositories/
│   ├── UserProfileRepositoryProtocol.swift
│   └── UserProfileRepository.swift
├── UseCases/
│   └── UserProfileUseCase.swift
└── DI/
    └── UserProfileDependency.swift
```

## 生成テンプレート

各ファイルの生成時は以下のルールに従う。詳細なテンプレートは → **references/TEMPLATES.md** を参照。

### View（SwiftUI）

- `import SwiftUI` を使用する
- ViewModel は `@State` で保持する（`@StateObject` は使わない）
- DI は `@Environment` で注入する（`@EnvironmentObject` は使わない）
- body はプレースホルダーの `Text` を配置する

### ViewModel（@Observable）

- `@Observable class` で宣言する（`ObservableObject` / `@Published` は使わない）
- `import Foundation` のみ（`import SwiftUI` は禁止）
- Repository は Protocol 経由でコンストラクタ注入する
- エラーハンドリング用の `var errorMessage: String?` を含める
- ローディング状態用の `var isLoading: Bool` を含める

### Repository + Protocol

- Protocol と具象クラスを別ファイルに分離する
- メソッドは `async throws` で定義する
- `Sendable` に準拠する

### UseCase

- 単一責務の `execute` メソッドを持つ
- Repository を Protocol 経由で注入する
- `Sendable` に準拠する

### DI（Dependency Container）

- Protocol ベースの依存解決を提供する
- `@Environment` での注入に対応する

## 生成後の確認

1. 生成したファイルが Swift の構文として正しいか検証する
   - MCP: XcodeBuildMCP の `swift_typecheck` を使用
   - CLI フォールバック: `swiftc -typecheck <ファイル>` を実行
2. 既存の Package.swift があれば target の追加を提案する
