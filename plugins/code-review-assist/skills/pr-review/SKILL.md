---
name: pr-review
description: PR の包括レビューワークフロー。差分レビュー・アーキテクチャ適合チェック・影響範囲分析・コメント下書きを一括実行する
disable-model-invocation: true
---

# PR 包括レビュー

> このスキルは `/pr-review` で明示的に実行します。自動活性化されません。

PR に対する包括的なコードレビューを実行するワークフロー。
個別スキル（pr-diff-review, architecture-conformance, impact-analysis, review-comment-draft）と
review-analyzer サブエージェントを組み合わせて実行する。

## 入力

- PR 番号を引数として受け取る（例: `/pr-review 123`）
- 引数がない場合はカレントブランチの PR を対象にする

## 実行フロー

### Step 1: PR 情報の取得

```bash
# PR の概要を取得
gh pr view <PR番号>

# 差分の規模を確認
gh pr diff <PR番号> --name-only | wc -l
```

差分の規模に応じて実行方式を切り替える:
- **10 ファイル以下**: メイン会話で直接実行
- **11 ファイル以上**: review-analyzer サブエージェントに委譲

### Step 2: 差分レビュー（pr-diff-review）

PR の差分をコード品質・設計・安全性の観点からレビューする。
指摘事項を Critical / Warning / Info の重要度で分類する。

### Step 3: アーキテクチャ適合チェック（architecture-conformance）

変更が MVVM / レイヤー規約に準拠しているかを検査する。
Swift 6.2 の Observation フレームワーク・Concurrency の準拠も含む。

### Step 4: 影響範囲分析（impact-analysis）

変更の影響範囲（依存先・呼び出し元）を特定し、リグレッションリスクを評価する。
テスト推奨リストを生成する。

### Step 5: レビューコメント下書き（review-comment-draft）

Step 2〜4 の結果を統合し、「理由 + 提案」形式のレビューコメントを生成する。
重要度ラベル（Must Fix / Should Fix / Suggestion / Question / Nit）を付与する。

### Step 6: 総合レポート生成

全ステップの結果を統合し、PR の品質サマリーを生成する。

## 出力

```
## PR レビューレポート: #<PR番号>

### PR 情報
- タイトル: <PR タイトル>
- 変更ファイル数: N
- 追加行数: +N / 削除行数: -N

### 総合判定: APPROVE / REQUEST_CHANGES / COMMENT
- Critical 指摘: N 件
- Warning 指摘: N 件
- Info 指摘: N 件

### 判定基準
- APPROVE: Critical 0 件 かつ Warning 2 件以下
- REQUEST_CHANGES: Critical 1 件以上
- COMMENT: Warning 3 件以上（Critical なし）

### コードレビュー指摘
（pr-diff-review の結果）

### アーキテクチャ適合
（architecture-conformance の結果）

### 影響範囲
（impact-analysis の結果）

### レビューコメント
（review-comment-draft の結果）

### テスト推奨リスト（優先度順）
1. <テスト対象と理由>
2. <テスト対象と理由>
```
