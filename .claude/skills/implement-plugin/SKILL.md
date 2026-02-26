---
name: implement-plugin
description: Issue に基づいてプラグインのファイル一式を実装する
argument-hint: "[plugin-name]"
disable-model-invocation: true
---

# プラグイン実装

Issue の内容に基づき、プラグインのディレクトリ構造とファイル一式を生成する。

## 手順

1. $ARGUMENTS のプラグイン名に対応する Issue を `gh issue view` で取得する
2. README.md から対象プラグインのスキル・subagent 一覧を確認する
3. CLAUDE.md からプラグイン構造ルール・設計ガイドラインを確認する
4. 各ファイルの作成ルールは → **references/IMPLEMENTATION_GUIDE.md** を参照
5. `plugins/<plugin-name>/` 配下にファイル一式を生成する
6. 実装完了後、`/validate-plugin <plugin-name>` の実行を推奨する旨をユーザーに伝える

## 注意

- $ARGUMENTS にプラグイン名が指定されない場合は `gh issue list --label plugin` から候補を表示する
- 既にファイルが存在する場合は上書きせず、差分を確認してから更新する
