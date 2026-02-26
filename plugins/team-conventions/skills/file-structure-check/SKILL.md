---
name: file-structure-check
description: ファイル配置がチーム規約に沿っているか検査する。ディレクトリ構成、レイヤー分離、ファイル名とクラス名の一致を検出。「ファイル配置」「ディレクトリ構成」「ファイル構造」「フォルダ構成」で自動適用。
---

# ファイル配置チェック

プロジェクトのファイル配置がチームの規約に沿っているかを検査する。
検査ルールの詳細は -> **references/FILE_STRUCTURE_RULES.md** を参照。

## ツール使用方針

- ファイル一覧の取得は xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Glob / Read ツールで直接ファイルを走査する

## 検査項目

### 1. ディレクトリ構成

SwiftUI + MVVM プロジェクトの標準ディレクトリ構成に準拠しているか検査する。

```
Sources/
├── App/                    # アプリエントリーポイント
│   └── <App名>App.swift
├── Features/               # 機能モジュール
│   └── <Feature名>/
│       ├── Views/          # SwiftUI View
│       ├── ViewModels/     # ViewModel（@Observable）
│       ├── Models/         # ドメインモデル
│       ├── Repositories/   # データアクセス
│       └── UseCases/       # ビジネスロジック
├── Shared/                 # 共通コンポーネント
│   ├── Extensions/
│   ├── Components/         # 再利用可能な UI コンポーネント
│   └── Utilities/
└── Infrastructure/         # 基盤層
    ├── Network/
    ├── Persistence/
    └── DI/
```

### 2. ファイル名とクラス名の一致

- `.swift` ファイル名がファイル内の主要な型名と一致しているか
- 1 ファイルに複数の public 型が定義されていないか（例外: ネストした型は許可）

### 3. レイヤー配置の整合性

- View ファイル（`*View.swift`）が `Views/` ディレクトリに配置されているか
- ViewModel ファイル（`*ViewModel.swift`）が `ViewModels/` ディレクトリに配置されているか
- Repository ファイル（`*Repository.swift`）が `Repositories/` ディレクトリに配置されているか
- Protocol ファイルが適切なディレクトリに配置されているか

### 4. Feature Module の完全性

- Feature ディレクトリに必要なサブディレクトリが揃っているか
- View に対応する ViewModel が存在するか（1:1 対応の推奨）

### 5. Swift 6.2 固有のチェック

- `@Observable` クラスが `ViewModels/` ディレクトリに配置されているか
- actor が `Infrastructure/` または適切なレイヤーに配置されているか

## 出力

```
## ファイル配置チェック結果

- ディレクトリ構成: PASS / WARN (N 件)
- ファイル名一致: PASS / WARN (N 件)
- レイヤー配置: PASS / WARN (N 件)
- Feature 完全性: PASS / WARN (N 件)

### 指摘事項
- [WARN] <ファイルパス> - <指摘内容>
- [提案] <推奨される配置先>
```

## 検査対象の特定

- 引数でディレクトリパスが指定された場合はそのディレクトリを検査する
- 指定がない場合は `git diff` の変更ファイルの配置を対象にする
