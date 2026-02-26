---
name: testflight-upload
description: アーカイブビルドと TestFlight アップロードを一括実行するワークフロー。archive-runner サブエージェントに処理を委譲する
disable-model-invocation: true
---

# TestFlight アップロード

> このスキルは `/testflight-upload` で明示的に実行します。自動活性化されません。

アーカイブビルドから TestFlight へのアップロードまでを一括で実行するワークフロー。
ビルド・アップロード処理は archive-runner サブエージェントに委譲する。

## ツール使用方針

- アーカイブは XcodeBuildMCP の利用を優先する
- アップロードは `xcrun altool` CLI を使用する（MCP 非対応のため常に CLI）
- ビルドログが膨大になるため、archive-runner サブエージェントに処理を委譲する

### MCP 利用時（アーカイブ部分）

- XcodeBuildMCP の `xcodebuild_archive` / `xcodebuild_export` ツールでアーカイブ + エクスポートする

### CLI フォールバック（archive-runner が実行）

```bash
# アーカイブ + エクスポート（build-archive と同様）
xcodebuild archive \
  -workspace <workspace>.xcworkspace \
  -scheme <scheme> \
  -archivePath build/<scheme>.xcarchive \
  -configuration Release \
  -destination "generic/platform=iOS"

xcodebuild -exportArchive \
  -archivePath build/<scheme>.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist

# TestFlight アップロード
xcrun altool --upload-app \
  --type ios \
  --file build/ipa/<app-name>.ipa \
  --apiKey <api-key> \
  --apiIssuer <issuer-id>
```

## 実行フロー

### Step 1: 事前確認

signing-check スキルの内容に基づき、署名・プロビジョニングの設定を確認する。

- プロジェクトファイルの存在確認
- スキーム名の確認
- ExportOptions.plist の存在確認
- App Store Connect API キーの存在確認

### Step 2: App Store Connect API キーの確認

アップロードには API キーが必要。以下のいずれかで認証する。

```bash
# API キー認証（推奨）
# ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8 にキーを配置
# --apiKey と --apiIssuer を指定

# App 用パスワード認証（レガシー）
# xcrun altool --upload-app --username <apple-id> --password <app-specific-password>
```

### Step 3: アーカイブ + アップロード実行

archive-runner サブエージェントにアーカイブ・エクスポート・アップロードを一括で委譲する。

### Step 4: 結果確認

- アーカイブの成否を確認する
- IPA エクスポートの成否を確認する
- TestFlight アップロードの成否を確認する
- エラーがあれば原因を分析して報告する

## 出力

```
## TestFlight アップロード結果

### 設定
- プロジェクト: <プロジェクト名>
- スキーム: <スキーム名>
- 構成: Release

### 実行結果
1. アーカイブ: SUCCESS / FAILURE
2. IPA エクスポート: SUCCESS / FAILURE
3. TestFlight アップロード: SUCCESS / FAILURE

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
