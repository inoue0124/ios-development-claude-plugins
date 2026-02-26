---
name: arch-audit
description: アーキテクチャ全体監査ワークフロー。MVVM チェック・レイヤー依存・DI・Protocol 設計を一括で監査する
disable-model-invocation: true
---

# アーキテクチャ全体監査

> このスキルは `/arch-audit` で明示的に実行します。自動活性化されません。

プロジェクト全体のアーキテクチャを包括的に監査するワークフロー。
個別スキル（mvvm-check, layer-dependency-check, di-pattern-suggest, protocol-oriented-check）と
architecture-scanner サブエージェントを組み合わせて実行する。

## 実行フロー

### Step 1: 全体スキャン（subagent）

architecture-scanner サブエージェントを起動し、プロジェクト全体の依存関係を分析する。
結果としてモジュール依存マップと違反の概要を受け取る。

### Step 2: 個別スキルの実行

全体スキャンで検出された問題ファイルに対し、以下のスキルを順次実行する。

1. **mvvm-check** — MVVM パターン準拠の検査
2. **layer-dependency-check** — レイヤー間依存方向の検査
3. **di-pattern-suggest** — DI パターンの提案
4. **protocol-oriented-check** — Protocol 指向設計の検査

### Step 3: 総合レポート生成

全スキルの結果を統合し、優先度付きの改善リストを生成する。

## 判定基準

| 項目 | PASS | FAIL |
|---|---|---|
| MVVM 準拠 | 違反 0 件 | 違反 1 件以上 |
| レイヤー依存 | 方向違反・循環依存 0 件 | 1 件以上 |
| DI パターン | 直接インスタンス化 0 件 | 1 件以上 |
| Protocol 設計 | ISP 違反 0 件 | 1 件以上 |

## 出力

```
## アーキテクチャ監査レポート

### サマリー
- 検査ファイル数: N
- 違反数: N（Critical: N, Warning: N, Info: N）

### モジュール依存マップ
（architecture-scanner の結果）

### MVVM 準拠: PASS / FAIL
### レイヤー依存: PASS / FAIL
### DI パターン: PASS / FAIL
### Protocol 設計: PASS / FAIL

### 改善推奨リスト（優先度順）
1. [Critical] ...
2. [Warning] ...
```
