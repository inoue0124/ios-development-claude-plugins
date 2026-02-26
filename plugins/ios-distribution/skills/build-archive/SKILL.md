---
name: build-archive
description: Xcode プロジェクトをアーカイブし IPA ファイルを生成する。archive-runner サブエージェントに処理を委譲する
disable-model-invocation: true
---

# IPA 生成（アーカイブビルド）

> このスキルは `/build-archive` で明示的に実行します。自動活性化されません。

Xcode プロジェクトをアーカイブし、IPA ファイルを生成する。
ビルドログが膨大になるため、実際のアーカイブ処理は archive-runner サブエージェントに委譲する。

## ツール使用方針

- アーカイブビルドは XcodeBuildMCP の利用を優先する
- MCP が利用できない場合は `xcodebuild` CLI にフォールバックする
- ビルドログが膨大になるため、archive-runner サブエージェントに処理を委譲する

### MCP 利用時

- XcodeBuildMCP の `xcodebuild_archive` ツールでアーカイブを実行する
- XcodeBuildMCP の `xcodebuild_export` ツールで IPA をエクスポートする

### CLI フォールバック（archive-runner が実行）

以下のコマンドを使用する。

```bash
# アーカイブ
xcodebuild archive \
  -project <project>.xcodeproj \
  -scheme <scheme> \
  -archivePath build/<scheme>.xcarchive \
  -configuration Release \
  -destination "generic/platform=iOS"

# ワークスペース使用時
xcodebuild archive \
  -workspace <workspace>.xcworkspace \
  -scheme <scheme> \
  -archivePath build/<scheme>.xcarchive \
  -configuration Release \
  -destination "generic/platform=iOS"

# IPA エクスポート
xcodebuild -exportArchive \
  -archivePath build/<scheme>.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ExportOptions.plist
```

## 実行フロー

### Step 1: 事前確認

- プロジェクトファイル（`.xcodeproj` / `.xcworkspace`）の存在確認
- スキーム名の確認（引数またはプロジェクトから自動取得）
- ExportOptions.plist の存在確認（なければ生成を提案）

### Step 2: ExportOptions.plist の準備

ExportOptions.plist が存在しない場合、以下のテンプレートを提案する。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

### Step 3: アーカイブ実行

archive-runner サブエージェントにアーカイブとエクスポートを委譲する。

### Step 4: 結果確認

- `.xcarchive` の生成を確認する
- IPA ファイルの生成を確認する
- エラーがあれば原因を分析して報告する

## 出力

```
## アーカイブ結果

### 設定
- プロジェクト: <プロジェクト名>
- スキーム: <スキーム名>
- 構成: Release

### 結果: SUCCESS / FAILURE
- アーカイブ: <パス>.xcarchive (SUCCESS / FAILURE)
- IPA: <パス>.ipa (SUCCESS / FAILURE)
- ファイルサイズ: N MB

### エラー（該当する場合）
- <エラー内容>
- [提案] <修正案>
```

## 引数

- `--scheme <name>`: アーカイブ対象のスキーム名（省略時はプロジェクトから自動取得）
- `--project <path>`: プロジェクトファイルのパス（省略時はカレントディレクトリを検索）
- `--workspace <path>`: ワークスペースファイルのパス
- `--export-options <path>`: ExportOptions.plist のパス（省略時は `ExportOptions.plist`）
