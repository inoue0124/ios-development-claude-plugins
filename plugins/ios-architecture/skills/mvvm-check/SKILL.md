---
name: mvvm-check
description: SwiftUI の MVVM パターン準拠を検査する。View と ViewModel の分離、責務の混在、ビジネスロジックの配置を検出。「MVVM 準拠」「ViewModel 分離」「ビジネスロジック混在」「@Observable」で自動適用。
---

# MVVM パターン検査

指定されたファイルまたは変更差分に対し、SwiftUI + MVVM の分離が正しく行われているかを検査する。
検査ルールの詳細は → **references/MVVM_RULES.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 検査項目

### View 層

- View が ViewModel を直接生成していないか（DI で注入すべき）
- View 内にビジネスロジック（計算・条件分岐・データ変換）が含まれていないか
- View が Repository / Service 層に直接依存していないか
- `@State` がビジネスロジックの状態管理に使われていないか（UI 状態のみ許可）

### ViewModel 層

- ViewModel が `@Observable` マクロを使用しているか（`ObservableObject` は非推奨）
- ViewModel が View（SwiftUI）フレームワークに依存していないか（`import SwiftUI` の禁止）
- ViewModel が他の ViewModel を直接参照していないか

### Model 層

- Model がプレゼンテーション層のロジックを含んでいないか
- Model が View / ViewModel に依存していないか

### レガシーパターンの検出

- `ObservableObject` / `@Published` の使用を検出し `@Observable` への移行を提案
- `@StateObject` / `@ObservedObject` の使用を検出し `@State` / `@Bindable` への移行を提案
- `@EnvironmentObject` の使用を検出し `@Environment` への移行を提案

## 出力

```
## MVVM 検査結果: <ファイル名>

- View 層: PASS / WARN (N 件)
- ViewModel 層: PASS / WARN (N 件)
- Model 層: PASS / WARN (N 件)
- レガシーパターン: PASS / WARN (N 件)

### 指摘事項
- [WARN] <ファイル>:<行番号> - <指摘内容>
- [提案] <改善案>
```

## 検査対象の特定

- 引数でファイルパスが指定された場合はそのファイルを検査する
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを対象にする
