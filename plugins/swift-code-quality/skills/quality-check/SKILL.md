---
name: quality-check
description: lint + format + typecheck を一括実行するコード品質チェックワークフロー
disable-model-invocation: true
---

# コード品質チェック一括ワークフロー

> このスキルは `/quality-check` で明示的に実行します。自動活性化されません。

SwiftLint、SwiftFormat、構文・型チェックを一括で実行し、コード品質を包括的に検査するワークフロー。
個別スキル（swift-lint, swift-format, syntax-typecheck, complexity-analysis, type-safety-check）と
lint-scanner サブエージェントを組み合わせて実行する。

## 実行フロー

### Step 1: 対象ファイルの特定

引数でファイルパスが指定された場合はそのファイルを対象にする。
指定がない場合は `git diff` の変更ファイルから `.swift` ファイルを特定する。

対象ファイルが多数（10 ファイル以上）の場合は lint-scanner サブエージェントに委譲する。

### Step 2: SwiftLint 実行

**swift-lint** スキルを使用して、コーディング規約違反を検出する。

- Error / Warning の集計
- 自動修正可能な違反の特定

### Step 3: SwiftFormat チェック

**swift-format** スキルを使用して、フォーマット差分を検出する。

- フォーマット違反の検出
- 差分のプレビュー

### Step 4: 構文・型チェック

**syntax-typecheck** スキルを使用して、構文エラーと型エラーを検出する。

- `swiftc -typecheck` の実行
- エラー / 警告の分類

### Step 5: 複雑度分析

**complexity-analysis** スキルを使用して、循環的複雑度と関数行数を分析する。

- 複雑度の高い関数の特定
- リファクタリング対象の優先順位付け

### Step 6: 型安全チェック

**type-safety-check** スキルを使用して、force unwrap / force cast を検出する。

- 安全な代替パターンの提案

### Step 7: 総合レポート生成

全スキルの結果を統合し、優先度付きの品質レポートを生成する。

## 判定基準

| 項目 | PASS | FAIL |
|---|---|---|
| SwiftLint | Error 0 件 | Error 1 件以上 |
| SwiftFormat | フォーマット差分 0 件 | 差分 1 件以上 |
| 構文・型チェック | エラー 0 件 | エラー 1 件以上 |
| 複雑度 | "危険" 判定 0 件 | "危険" 1 件以上 |
| 型安全 | force unwrap/cast 0 件 | 1 件以上 |

## 出力

```
## コード品質チェックレポート

### サマリー
- 検査ファイル数: N
- 総指摘数: N（Error: N, Warning: N, Info: N）

### SwiftLint: PASS / FAIL
- Error: N 件, Warning: N 件
- 自動修正可能: N 件

### SwiftFormat: PASS / FAIL
- フォーマット差分: N ファイル

### 構文・型チェック: PASS / FAIL
- Error: N 件, Warning: N 件

### 複雑度: PASS / FAIL
- "危険" 判定: N 関数
- "注意" 判定: N 関数

### 型安全: PASS / FAIL
- Force unwrap: N 件
- Force cast: N 件
- Force try: N 件

### 改善推奨リスト（優先度順）
1. [Error] ...
2. [Warning] ...
3. [Info] ...

### 自動修正アクション
- `swiftlint lint --fix --path <パス>` で SwiftLint の自動修正を実行
- `swiftformat <パス>` で SwiftFormat を適用
```
