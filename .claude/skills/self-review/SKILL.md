---
name: self-review
description: PR 前のセルフレビューを実施する
argument-hint: "[plugin-name]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git diff *), Task
---

# セルフレビュー

PR を作成する前に、変更内容の品質を包括的にチェックする。

## レビュー項目

以下の順序でチェックを実施する。

### 1. 構造検証（/validate-plugin 相当）

- plugin.json の必須フィールド（name, version, description）が存在するか
- skills/ 配下の各ディレクトリに SKILL.md が存在するか
- SKILL.md の YAML frontmatter に name, description が定義されているか
- plugin.json の agents に記載された .md ファイルが実在するか
- plugin.json の hooks で指定されたファイルが実在するか（該当する場合）
- hooks.json が正しい JSON であるか（該当する場合）

### 2. CLAUDE.md 準拠チェック

- MCP 推奨 + CLI フォールバックのパターンが守られているか
- subagent 化の基準に該当する処理が subagent として実装されているか
- スキルが単一責務（atomic）になっているか
- 命名規則（kebab-case）に従っているか
- 本文が日本語で記述されているか

### 3. README.md との整合性チェック

- README.md に記載されたスキル・subagent が全て実装されているか
- 逆に README.md に未記載の実装がないか

### 4. コード品質（plugin-reviewer subagent によるレビュー）

`.claude/agents/plugin-reviewer.md` で定義された subagent を Task ツールで起動する。
対象プラグインのパスを渡し、SKILL.md・agent .md の品質を独立してレビューさせる。
subagent の結果を受け取り、このセルフレビューの「コード品質」セクションに統合する。

## 出力

チェック結果をカテゴリごとにまとめ、以下の形式で報告する。

```
## セルフレビュー結果

### 構造検証: PASS / FAIL
- (詳細)

### CLAUDE.md 準拠: PASS / FAIL
- (詳細)

### README 整合性: PASS / FAIL
- (詳細)

### コード品質: PASS / FAIL
- (詳細)

### 総合判定: PR 作成可 / 要修正
```

## 注意

- $ARGUMENTS にプラグイン名が指定された場合はそのプラグインのみレビューする
- 指定がない場合は main ブランチとの差分から対象プラグインを自動検出する
- FAIL がある場合は修正案を提示する
