---
name: testflight-upload
description: ビルド番号更新・アーカイブビルド・TestFlight アップロード・コミットを一括実行するワークフロー。archive-runner サブエージェントに処理を委譲する
disable-model-invocation: true
---

# TestFlight アップロード

> このスキルは `/testflight-upload` で明示的に実行します。自動活性化されません。

ビルド番号のインクリメントからアーカイブ・TestFlight アップロード・コミットまでを一括で実行するワークフロー。
ビルド・アップロード処理は archive-runner サブエージェントに委譲する。

## ツール使用方針

- アーカイブは XcodeBuildMCP の利用を優先する
- アップロードは `xcrun altool` CLI を使用する（MCP 非対応のため常に CLI）
- ビルドログが膨大になるため、archive-runner サブエージェントに処理を委譲する

### MCP 利用時（アーカイブ部分）

- XcodeBuildMCP の `xcodebuild_archive` / `xcodebuild_export` ツールでアーカイブ + エクスポートする

### CLI フォールバック（archive-runner が実行）

```bash
# アーカイブ + エクスポート
xcodebuild archive \
  -project <project>.xcodeproj \
  -scheme <scheme> \
  -archivePath build/<scheme>.xcarchive \
  -configuration Release \
  -destination "generic/platform=iOS"

xcodebuild -exportArchive \
  -archivePath build/<scheme>.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist

# TestFlight アップロード（App-Specific Password 認証）
xcrun altool --upload-app \
  --type ios \
  --file build/ipa/<app-name>.ipa \
  --username <apple-id> \
  --password <app-specific-password>

# TestFlight アップロード（API キー認証）
xcrun altool --upload-app \
  --type ios \
  --file build/ipa/<app-name>.ipa \
  --apiKey <api-key> \
  --apiIssuer <issuer-id>
```

## 実行フロー

### Step 1: 事前確認

signing-check スキルの内容に基づき、署名・プロビジョニングの設定を確認する。

- 未コミットの差分がないことを確認（`git status`）
- プロジェクトファイルの存在確認
- スキーム名の確認
- ExportOptions.plist の存在確認

### Step 2: 認証情報の確認

`.env` ファイルまたは環境変数から認証情報を取得する。

```bash
# .env ファイル例
APPLE_ID=user@example.com
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=xxxx-xxxx-xxxx-xxxx
```

以下のいずれかで認証する:

- **App-Specific Password 認証**: `APPLE_ID` + `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`
- **API キー認証（推奨）**: `~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8` + `--apiKey` / `--apiIssuer`

### Step 3: ビルド番号インクリメント

`project.yml`（XcodeGen 利用時）または Xcode プロジェクトの `CURRENT_PROJECT_VERSION` をインクリメントする。

```bash
# project.yml の CURRENT_PROJECT_VERSION を +1 する
# 例: "5" → "6"
```

XcodeGen 利用時はプロジェクトを再生成する:

```bash
mint run xcodegen generate
```

### Step 4: アーカイブ + アップロード実行

archive-runner サブエージェントにアーカイブ・エクスポート・アップロードを一括で委譲する。

### Step 5: コミット + プッシュ

ビルド番号の変更をコミットしてプッシュする。

```bash
git add project.yml
git commit -m "chore(build): ビルド番号を <N> に更新"
git push origin <branch>
```

### Step 6: 結果確認

- アーカイブの成否を確認する
- IPA エクスポートの成否を確認する
- TestFlight アップロードの成否を確認する
- エラーがあれば原因を分析して報告する

## 出力

```
## TestFlight アップロード結果

### バージョン情報
- バージョン: <MARKETING_VERSION> (Build <CURRENT_PROJECT_VERSION>)

### 実行結果
1. ビルド番号更新: SUCCESS / FAILURE
2. XcodeGen: SUCCESS / SKIPPED
3. アーカイブ: SUCCESS / FAILURE
4. IPA エクスポート: SUCCESS / FAILURE
5. TestFlight アップロード: SUCCESS / FAILURE
6. コミット + プッシュ: SUCCESS / FAILURE

### 詳細
- IPA ファイル: <パス> (N MB)
- アップロード先: App Store Connect
- 処理時間: N 分

### エラー（該当する場合）
- <エラー内容>
- [提案] <修正案>
```

## 引数

- `--scheme <name>`: アーカイブ対象のスキーム名（省略時はプロジェクトから自動取得）
- `--project <path>`: プロジェクトファイルのパス
- `--workspace <path>`: ワークスペースファイルのパス
- `--export-options <path>`: ExportOptions.plist のパス
- `--api-key <key>`: App Store Connect API キー ID
- `--api-issuer <issuer>`: App Store Connect Issuer ID
- `--skip-commit`: ビルド番号変更のコミットをスキップ
