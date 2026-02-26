---
name: validate-plugin
description: プラグインの構造が CLAUDE.md のルールに準拠しているか検証する
argument-hint: "[plugin-name]"
disable-model-invocation: true
allowed-tools: Read, Glob, Grep
---

# プラグイン構造検証

指定されたプラグインの構造を検証し、不備を報告する。

## 検証項目

### 1. plugin.json

- ファイルが `.claude-plugin/plugin.json` に存在するか
- 必須フィールドが定義されているか: name, version, description
- version が semver 形式か
- skills, agents, hooks のパスが正しいか

### 2. スキル（skills/）

- plugin.json の skills で指定されたディレクトリが存在するか
- 各スキルディレクトリに SKILL.md が存在するか
- SKILL.md の YAML frontmatter に name, description が定義されているか
- name が kebab-case かつ 64 文字以内か
- description にトリガーキーワードが含まれているか

### 3. subagent（agents/）

- plugin.json の agents に記載された .md ファイルが全て実在するか
- 各 .md の YAML frontmatter に name, description, tools が定義されているか

### 4. hooks（hooks/）

- plugin.json に hooks が定義されている場合、hooks.json が存在するか
- hooks.json が有効な JSON であるか
- 参照されるスクリプトファイルが実在するか

## 出力

```
## 構造検証結果: <plugin-name>

- plugin.json: PASS / FAIL
- skills: PASS / FAIL (N/N スキル)
- agents: PASS / FAIL (N/N subagent)
- hooks: PASS / SKIP

総合: PASS / FAIL
```

## 注意

- $ARGUMENTS にプラグイン名が指定された場合はそのプラグインを検証する
- 指定がない場合は plugins/ 配下の全プラグインを検証する
- FAIL の項目には具体的な修正方法を提示する
