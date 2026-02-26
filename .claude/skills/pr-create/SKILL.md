---
name: pr-create
description: プラグイン実装の PR を作成する
disable-model-invocation: true
---

# PR 作成

プラグイン実装の Pull Request を作成する。

## 手順

1. `git status` と `git diff main...HEAD` で変更内容を確認する
2. 変更されたプラグインの plugin.json からプラグイン名を特定する
3. `.github/PULL_REQUEST_TEMPLATE.md` のテンプレートに沿って PR 本文を構成する
4. 対応 Issue を `gh issue list --label plugin` から特定し、`closes #N` を設定する
5. プラグイン構成（スキル数、subagent 数）を plugin.json と実ファイルから集計する
6. チェックリストは全項目を含める
7. `gh pr create` で PR を作成する

## 実行コマンド例

```bash
gh pr create --title "feat: <plugin-name> プラグインの実装" --body "..."
```

## 注意

- PR 作成前に `/self-review` の実施を推奨する旨をユーザーに伝える
- 未コミットの変更がある場合はコミットを促す
- ブランチが main の場合は新しいブランチの作成を提案する
