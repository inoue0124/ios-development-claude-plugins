# team-conventions — 規約エンフォーサー

チームのコーディング規約・命名規則・ブランチ運用ルールを自動で検査・強制する。
hooks でコード生成前に規約を注入し、最初から規約通りに書く。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | naming-check | Swift 命名規則（API Design Guidelines 準拠）チェック |
| skill | file-structure-check | ファイル配置がチーム規約に沿っているか検査 |
| skill | commit-message-lint | コミットメッセージ形式チェック |
| skill | branch-naming-check | ブランチ命名規則の検証 |
| skill | pr-description-gen | PR テンプレートに基づく説明文の自動生成 |
| skill (manual) | convention-check | 変更ファイルに対する規約チェック一括ワークフロー |

## subagent

| 名前 | 内容 |
|---|---|
| convention-scanner | プロジェクト全体の規約準拠スキャン |

## hooks

| イベント | 内容 |
|---|---|
| UserPromptSubmit | コード生成時に規約をコンテキスト注入 |
