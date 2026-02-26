# code-review-assist — コードレビュー支援

PR の差分を分析し、レビューコメントの生成・アーキテクチャ適合チェック・影響範囲の特定を行う。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | pr-diff-review | PR 差分を読んでレビューコメント生成 |
| skill | architecture-conformance | 変更が MVVM / レイヤー規約に沿っているか検査 |
| skill | impact-analysis | 変更の影響範囲を特定（依存先・呼び出し元） |
| skill | review-comment-draft | 指摘コメントを「理由 + 提案」形式で下書き |
| skill (manual) | pr-review | 上記を組み合わせた包括レビューワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| review-analyzer | PR 全体を包括分析（大規模差分の隔離実行） |
