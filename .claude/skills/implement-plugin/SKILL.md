---
name: implement-plugin
description: Issue に基づいてプラグインを実装し、検証・レビュー・修正を経て PR を作成する
argument-hint: "[plugin-name]"
disable-model-invocation: true
---

# プラグイン実装

Issue の内容に基づきプラグインを実装し、品質が担保された状態で PR を作成するワークフロー。
実装後に構造検証とセルフレビューを行い、重大な指摘が全て解消されるまで修正を繰り返す。

## フロー概要

```
Step 1: 実装
  ↓
Step 2: 構造検証（validate-plugin）
  ↓ FAIL → 修正して Step 2 へ
Step 3: セルフレビュー（self-review）
  ↓ 重大指摘あり → 修正して Step 2 へ
Step 4: コミット & PR 作成（pr-create）
```

## Step 1: 実装

1. $ARGUMENTS のプラグイン名に対応する Issue を `gh issue view` で取得する
2. README.md から対象プラグインのスキル・subagent 一覧を確認する
3. CLAUDE.md からプラグイン構造ルール・設計ガイドラインを確認する
4. 各ファイルの作成ルールは → **references/IMPLEMENTATION_GUIDE.md** を参照
5. `plugins/<plugin-name>/` 配下にファイル一式を生成する

## Step 2: 構造検証

`/validate-plugin` 相当のチェックを実行する。

- plugin.json の必須フィールド・パス整合性
- 全スキルの SKILL.md 存在・frontmatter 検証
- 全 agent の .md 存在・frontmatter 検証
- hooks.json の検証（該当する場合）

**FAIL の場合**: 指摘内容を修正し、Step 2 を再実行する。

## Step 3: セルフレビュー

`/self-review` 相当の品質チェックを実行する。

- CLAUDE.md 準拠（MCP フォールバック、subagent 基準、単一責務、命名規則、Swift 6.2 準拠）
- README.md との整合性
- plugin-reviewer サブエージェントによるコード品質レビュー

### 判定ルール

- **重大指摘が 1 件以上**: 指摘を修正し、Step 2 に戻る
- **軽微指摘のみ**: ユーザーに軽微指摘の一覧を提示し、修正するか PR に進むか確認する
- **指摘なし**: Step 4 に進む

## Step 4: コミット & PR 作成

`/pr-create` 相当の手順で PR を作成する。

1. 変更ファイルをステージングする
2. コミットメッセージを生成する（`feat: <plugin-name> プラグインの実装`）
3. フィーチャーブランチを作成・push する
4. 対応する Issue を `closes #N` で紐付けた PR を作成する

## 注意

- $ARGUMENTS にプラグイン名が指定されない場合は `gh issue list --label plugin` から候補を表示する
- 既にファイルが存在する場合は上書きせず、差分を確認してから更新する
- Step 2・3 のループは重大指摘が解消されるまで繰り返す（軽微指摘はユーザー判断）
