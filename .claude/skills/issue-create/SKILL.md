---
name: issue-create
description: プラグイン開発用の Issue を作成する
argument-hint: "[plugin-name]"
disable-model-invocation: true
---

# Issue 作成

プラグイン開発用の GitHub Issue を作成する。

## 手順

1. README.md を読み、対象プラグインの情報（名前、Tier、番号、スキル一覧）を取得する
2. `.github/ISSUE_TEMPLATE/plugin-development.md` のテンプレートに沿って内容を構成する
3. 概要はプラグインの説明文（README.md の各プラグイン冒頭の1行）を使う
4. スキル一覧は README.md の表をそのまま転記する
5. `gh issue create` で Issue を作成する

## 実行コマンド例

```bash
gh issue create --title "feat: <plugin-name> プラグインの実装" --label "plugin" --body "..."
```

## 注意

- $ARGUMENTS にプラグイン名が指定された場合はそのプラグインの Issue を作成する
- 指定がない場合は未作成のプラグインを一覧表示し、ユーザーに選択させる
- 既に同名の Issue が存在する場合は作成せず、既存 Issue の URL を表示する
