---
name: test-gen
description: テスト生成・実行・カバレッジ分析を一括で行うワークフロー。unit-test-gen、mock-gen、test-runner、coverage-reporter を組み合わせて実行する
disable-model-invocation: true
---

# テスト一括ワークフロー

> このスキルは `/test-gen` で明示的に実行します。自動活性化されません。

テスト生成から実行・カバレッジ確認までを一括で行うワークフロー。
個別スキル（unit-test-gen, mock-gen, coverage-gap-detect）と
サブエージェント（test-runner, coverage-reporter）を組み合わせて実行する。

## 実行フロー

### Step 1: カバレッジギャップの分析

coverage-gap-detect スキルでテスト対象のソースファイルを分析し、テスト未カバーのパスを特定する。

### Step 2: モック生成

mock-gen スキルで、テストに必要な Protocol 準拠のモック・スタブを生成する。
既存のモックがある場合は再生成をスキップする。

### Step 3: テストコード生成

unit-test-gen スキルで、Step 1 で特定された未カバーパスを中心にテストコードを生成する。
Swift Testing フレームワーク（`import Testing`, `@Test`, `#expect`）を使用する。

### Step 4: テスト実行（subagent）

test-runner サブエージェントを起動し、生成されたテストを実行する。

- テストが成功した場合 → Step 5 へ進む
- テストが失敗した場合 → テストコードを修正し、再実行する（最大 3 回リトライ）

### Step 5: カバレッジ確認（subagent）

coverage-reporter サブエージェントを起動し、テスト実行後のカバレッジを確認する。

### Step 6: レポート生成

全ステップの結果を統合し、最終レポートを生成する。

## 出力

```
## テスト一括ワークフロー結果

### サマリー
- 対象ファイル: <ファイル名>
- 生成テストケース数: N
- テスト実行結果: PASS / FAIL (N passed, N failed)
- カバレッジ: N% → N%（差分: +N%）

### Step 1: カバレッジギャップ
- 検出された未カバーパス: N 件

### Step 2: モック生成
- 生成されたモック: N 件

### Step 3: テストコード生成
- 正常系: N 件、異常系: N 件、境界値: N 件

### Step 4: テスト実行
- 結果: N passed, N failed, N skipped
- 失敗テスト:（ある場合）
  - <テスト名>: <失敗理由>

### Step 5: カバレッジ
- 行カバレッジ: N%
- 分岐カバレッジ: N%
- 関数カバレッジ: N%

### 残存する未カバーパス
- <テスト追加が推奨されるパスの一覧>
```
