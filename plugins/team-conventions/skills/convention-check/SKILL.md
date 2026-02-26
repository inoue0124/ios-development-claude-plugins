---
name: convention-check
description: 変更ファイルに対する規約チェック一括ワークフロー。命名規則・ファイル配置・コミットメッセージ・ブランチ名を一括検査する
disable-model-invocation: true
---

# 規約チェック一括ワークフロー

> このスキルは `/convention-check` で明示的に実行します。自動活性化されません。

変更ファイルに対してチームの規約を包括的にチェックするワークフロー。
個別スキル（naming-check, file-structure-check, commit-message-lint, branch-naming-check）と
convention-scanner サブエージェントを組み合わせて実行する。

## 実行フロー

### Step 1: 変更ファイルの特定

```bash
git diff --name-only HEAD~1..HEAD
git diff --name-only --cached
```

変更された `.swift` ファイルを収集する。

### Step 2: ブランチ名チェック

**branch-naming-check** スキルを実行し、現在のブランチ名が規約に準拠しているか検査する。

### Step 3: コミットメッセージチェック

**commit-message-lint** スキルを実行し、直近のコミットメッセージが Conventional Commits 形式に準拠しているか検査する。

### Step 4: 命名規則チェック

**naming-check** スキルを変更された各 `.swift` ファイルに対して実行する。

### Step 5: ファイル配置チェック

**file-structure-check** スキルを変更されたファイルの配置に対して実行する。

### Step 6: 全体スキャン（大規模変更時）

変更ファイルが 20 以上の場合、**convention-scanner** サブエージェントを起動してプロジェクト全体の規約準拠を確認する。

### Step 7: 総合レポート生成

全スキルの結果を統合し、優先度付きの指摘リストを生成する。

## 判定基準

| 項目 | PASS | FAIL |
|---|---|---|
| ブランチ名 | 規約準拠 | プレフィックスまたは形式の違反 |
| コミットメッセージ | Conventional Commits 形式 | 形式違反 |
| 命名規則 | API Design Guidelines 準拠 | 命名違反 1 件以上 |
| ファイル配置 | 規約に沿った配置 | 配置違反 1 件以上 |

## 出力

```
## 規約チェックレポート

### サマリー
- 検査ファイル数: N
- 違反数: N（Critical: N, Warning: N, Info: N）

### ブランチ名: PASS / FAIL
### コミットメッセージ: PASS / FAIL
### 命名規則: PASS / FAIL (N 件)
### ファイル配置: PASS / FAIL (N 件)

### 改善推奨リスト（優先度順）
1. [Critical] ...
2. [Warning] ...
```
