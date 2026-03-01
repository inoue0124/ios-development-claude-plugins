---
name: release
description: Git タグ作成・GitHub Release 自動生成・App Store リリースノート生成を一括実行するリリースワークフロー
disable-model-invocation: true
---

# リリース

> このスキルは `/release` で明示的に実行します。自動活性化されません。

TestFlight での QA 完了後、審査合格・リリースのタイミングで実行するワークフロー。
ビルドやアップロードは行わず、タグ付け・GitHub Release 作成・App Store メタデータ管理に専念する。

## 前提

- TestFlight アップロード済みのビルドが存在すること（`/testflight-upload` で事前に実行）
- QA テスト完了済みであること
- main ブランチが最新であること

## `/testflight-upload` との棲み分け

| | `/testflight-upload` | `/release` |
|---|---|---|
| ビルド番号更新 | する | しない |
| アーカイブ + アップロード | する | しない |
| Git タグ作成 | しない | する |
| GitHub Release | しない | する |
| App Store リリースノート | しない | する |
| 実行タイミング | 開発完了時 | 審査合格・リリース時 |

## 実行フロー

### Step 1: バージョン情報の確認

`project.yml` または Xcode プロジェクトから現在のバージョン情報を取得する。

```bash
# project.yml から取得
grep MARKETING_VERSION project.yml
grep CURRENT_PROJECT_VERSION project.yml

# 既存タグの確認
git tag --sort=-version:refname | head -5
```

### Step 2: 前回リリースからのコミットログ取得

```bash
# 前回タグからの差分
git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD

# 初回リリースの場合は全コミット
git log --oneline
```

### Step 3: App Store リリースノート生成

コミットログからユーザー向けリリースノートを生成する。

**変換ルール:**

| コミット type | 扱い | 例 |
|---|---|---|
| `feat:` | 新機能として記載 | 「いいねした短歌を一覧で見られるようになりました」 |
| `fix:` | 修正として記載 | 「ダークモードでの表示を改善しました」 |
| `perf:` | 改善として記載 | 「いいねボタンの反応速度を改善しました」 |
| `chore:` / `refactor:` / `docs:` / `ci:` / `build:` | 省略 | — |

**生成後、ユーザーに内容を確認する。** 承認後に `fastlane/metadata/ja/release_notes.txt` に書き込む。

### Step 4: バージョンバンプ（オプション）

`--patch` / `--minor` / `--major` が指定された場合、`MARKETING_VERSION` を更新する。

```bash
# 例: 1.0.0 → 1.0.1 (--patch)
# 例: 1.0.0 → 1.1.0 (--minor)
# 例: 1.0.0 → 2.0.0 (--major)
```

XcodeGen 利用時は `project.yml` を編集し、プロジェクトを再生成する。

### Step 5: 変更をコミット + プッシュ

リリースノートやバージョン変更をコミットする。

```bash
git add fastlane/metadata/ja/release_notes.txt project.yml
git commit -m "chore(release): v<version> リリース準備"
git push origin main
```

### Step 6: Git タグ作成 + GitHub Release

```bash
# タグ形式: v{MARKETING_VERSION}-build.{BUILD_NUMBER}
# 例: v1.0.0-build.5

gh release create "v1.0.0-build.5" \
  --title "v1.0.0 (Build 5)" \
  --generate-notes \
  --latest
```

`--generate-notes` により、前回リリースからのコミット一覧が GitHub 上に自動生成される。
Conventional Commits の `feat:` / `fix:` 等が自動でグループ化される。

### Step 7: App Store メタデータアップロード（オプション）

`--upload-metadata` が指定された場合、Fastlane deliver でメタデータを App Store Connect にアップロードする。

```bash
fastlane deliver \
  --skip_binary_upload \
  --skip_screenshots \
  --force
```

## 出力

```
## リリース結果

### バージョン情報
- バージョン: <MARKETING_VERSION> (Build <BUILD_NUMBER>)
- タグ: v<MARKETING_VERSION>-build.<BUILD_NUMBER>
- 前回リリースからのコミット: N 件

### 実行結果
1. リリースノート生成: SUCCESS
2. バージョンバンプ: SUCCESS / SKIPPED
3. コミット + プッシュ: SUCCESS
4. Git タグ + GitHub Release: SUCCESS
5. メタデータアップロード: SUCCESS / SKIPPED

### App Store リリースノート
<生成されたリリースノートの内容>

### リンク
- GitHub Release: <URL>
```

## 引数

- `--patch`: パッチバージョンをバンプ（例: 1.0.0 → 1.0.1）
- `--minor`: マイナーバージョンをバンプ（例: 1.0.0 → 1.1.0）
- `--major`: メジャーバージョンをバンプ（例: 1.0.0 → 2.0.0）
- `--upload-metadata`: App Store Connect にメタデータをアップロード
- `--draft`: GitHub Release を下書きで作成
- `--prerelease`: GitHub Release をプレリリースとしてマーク
- `--skip-metadata`: App Store リリースノート生成をスキップ
