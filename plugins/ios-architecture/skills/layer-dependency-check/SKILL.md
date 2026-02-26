---
name: layer-dependency-check
description: レイヤー間の依存方向をチェックする。上位層から下位層への依存方向違反、循環依存を検出。「依存方向違反」「循環依存」「モジュール依存」「レイヤー違反」で自動適用。
---

# レイヤー間依存方向チェック

Swift ファイルの import 文とクラス参照を解析し、レイヤー間の依存方向が正しいかを検査する。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## レイヤー定義

上位から下位への依存のみを許可する。

```
View → ViewModel → UseCase / Repository → Model / Entity
```

### 許可される依存

- View → ViewModel
- ViewModel → UseCase, Repository（Protocol 経由）
- UseCase → Repository（Protocol 経由）
- Repository → Model / Entity
- 全レイヤー → 共通ユーティリティ

### 禁止される依存

- Model → ViewModel, View
- ViewModel → View
- Repository → ViewModel, View
- UseCase → View, ViewModel

## 検査手法

1. ファイルパスからレイヤーを推定する（`Views/`, `ViewModels/`, `Models/`, `Repositories/`, `UseCases/` 等）
2. ディレクトリ名からレイヤーを推定できないファイルは「Other」に分類しチェックをスキップする。スキップしたファイルは出力の「統計」セクションに一覧表示する
3. `import` 文と型参照から依存先を特定する
4. 依存方向が上記ルールに違反していないかチェックする
5. 循環依存がないかチェックする

## 出力

```
## レイヤー依存チェック結果

- 依存方向違反: N 件
- 循環依存: N 件

### 違反一覧
- [VIOLATION] <ファイル>:<行番号> - <下位層> が <上位層> に依存しています
- [提案] <違反の種類に応じた改善案（DIP 適用、Protocol 導入、依存の除去等）>

### 統計
- レイヤー推定: View N, ViewModel N, Model N, Repository N, UseCase N, Other N（スキップ）
```
