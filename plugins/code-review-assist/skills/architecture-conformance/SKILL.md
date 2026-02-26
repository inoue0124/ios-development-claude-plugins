---
name: architecture-conformance
description: 変更が MVVM / レイヤー規約に沿っているか検査する。アーキテクチャ適合、MVVM 準拠、レイヤー違反、設計規約、構造チェックで自動適用。
---

# アーキテクチャ適合チェック

PR の変更差分に対し、チームの MVVM / レイヤー規約に準拠しているかを検査する。
プロジェクト全体のスキャンではなく、変更されたファイルに絞った軽量な検査を行う。

## ツール使用方針

- PR 差分の取得は `gh` CLI を使用する（`gh pr diff`）
- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 入力

- PR 番号またはブランチ名が指定された場合はそれを使用する
- 指定がない場合はカレントブランチの差分（`git diff main...HEAD`）を対象にする

## 検査項目

### 1. MVVM パターン準拠

- View が ViewModel を直接生成していないか（DI で注入すべき）
- View 内にビジネスロジック（計算・条件分岐・データ変換）が含まれていないか
- ViewModel が `@Observable` マクロを使用しているか（`ObservableObject` は非推奨）
- ViewModel が `import SwiftUI` していないか
- Model がプレゼンテーション層のロジックを含んでいないか

### 2. レイヤー依存方向

許可される依存方向:

```
View → ViewModel → UseCase / Repository → Model / Entity
```

- 下位層から上位層への依存を検出する
- ViewModel → View、Model → ViewModel 等の逆方向依存を報告する

### 3. DI パターン

- 具象クラスを直接インスタンス化していないか
- コンストラクタ注入が使われているか
- Protocol 経由の抽象化がされているか

### 4. Swift 6.2 Observation 準拠

- `ObservableObject` / `@Published` の新規使用を検出
- `@StateObject` / `@ObservedObject` / `@EnvironmentObject` の新規使用を検出
- `@Observable` / `@State` / `@Bindable` / `@Environment` の使用を推奨

### 5. Concurrency 安全性

- `Sendable` 準拠が適切か
- actor 分離が正しいか
- `@MainActor` が必要な箇所に付与されているか

## 検査手法

1. 差分からファイル一覧を取得する
2. 各 `.swift` ファイルのパスからレイヤーを推定する（`Views/`, `ViewModels/`, `Models/`, `Repositories/`, `UseCases/` 等）
3. ディレクトリ名からレイヤーを推定できないファイルは「Other」として分類しスキップする
4. 変更箇所の `import` 文・型参照から依存先を特定する
5. 依存方向・パターンの違反を検出する

## 出力

```
## アーキテクチャ適合チェック結果

### サマリー
- 検査ファイル数: N
- 違反数: N（MVVM: N, レイヤー依存: N, DI: N, Observation: N, Concurrency: N）

### MVVM 準拠: PASS / FAIL
- [VIOLATION] <ファイル>:<行番号> - <違反内容>
- [提案] <改善案>

### レイヤー依存方向: PASS / FAIL
- [VIOLATION] <ファイル>:<行番号> - <下位層> が <上位層> に依存しています
- [提案] <改善案>

### DI パターン: PASS / FAIL
- [VIOLATION] <ファイル>:<行番号> - <具象クラス> を直接インスタンス化しています
- [提案] Protocol 抽象化 + コンストラクタ注入

### Observation 準拠: PASS / FAIL
- [VIOLATION] <ファイル>:<行番号> - <旧 API> の新規使用を検出
- [提案] <新 API> への移行

### Concurrency 安全性: PASS / FAIL
- [VIOLATION] <ファイル>:<行番号> - <違反内容>
- [提案] <改善案>
```
