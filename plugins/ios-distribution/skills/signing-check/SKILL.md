---
name: signing-check
description: コード署名・プロビジョニングプロファイルの設定を確認する。「署名」「プロビジョニング」「signing」「provisioning」「証明書」「certificate」「コード署名」で自動適用。
---

# 署名・プロビジョニング確認

指定されたプロジェクトまたはターゲットに対し、コード署名とプロビジョニングプロファイルの設定が正しく構成されているかを確認する。

## ツール使用方針

- プロジェクト設定の読み取りは XcodeBuildMCP / xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は CLI にフォールバックする

### MCP 利用時

- xcodeproj-mcp-server でビルド設定（`CODE_SIGN_IDENTITY`, `PROVISIONING_PROFILE_SPECIFIER`, `DEVELOPMENT_TEAM` 等）を取得する
- XcodeBuildMCP で `xcodebuild -showBuildSettings` 相当の情報を取得する

### CLI フォールバック

以下のコマンドを使用する。

```bash
# ビルド設定の確認
xcodebuild -showBuildSettings -project <project>.xcodeproj -scheme <scheme> | grep -E "(CODE_SIGN|PROVISIONING|DEVELOPMENT_TEAM)"

# ワークスペース使用時
xcodebuild -showBuildSettings -workspace <workspace>.xcworkspace -scheme <scheme> | grep -E "(CODE_SIGN|PROVISIONING|DEVELOPMENT_TEAM)"

# インストール済みプロビジョニングプロファイル一覧
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# プロファイルの詳細確認
security cms -D -i ~/Library/MobileDevice/Provisioning\ Profiles/<uuid>.mobileprovision

# インストール済み証明書の確認
security find-identity -v -p codesigning
```

## 検査項目

### 1. 署名設定

- `CODE_SIGN_IDENTITY` が設定されているか
- `DEVELOPMENT_TEAM` が設定されているか
- Automatic Signing（`CODE_SIGN_STYLE = Automatic`）の有無を確認
- Manual Signing の場合、プロファイルが明示的に指定されているか

### 2. プロビジョニングプロファイル

- 指定されたプロファイルがローカルに存在するか（`~/Library/MobileDevice/Provisioning Profiles/`）
- プロファイルの有効期限が切れていないか
- プロファイルの App ID がプロジェクトの Bundle Identifier と一致するか
- プロファイルの種類（Development / Ad Hoc / App Store）が配信目的と一致するか

### 3. 証明書

- `security find-identity` で有効な署名証明書が存在するか
- 証明書の有効期限が切れていないか
- プロファイルに紐づく証明書がキーチェーンに存在するか

### 4. ビルド構成別チェック

- Debug 構成: Development 証明書・プロファイルが設定されているか
- Release 構成: Distribution 証明書・App Store プロファイルが設定されているか

## 出力

```
## 署名・プロビジョニング確認結果

### 署名設定
- CODE_SIGN_IDENTITY: <値> (PASS / WARN)
- DEVELOPMENT_TEAM: <値> (PASS / WARN)
- CODE_SIGN_STYLE: Automatic / Manual (INFO)

### プロビジョニングプロファイル
- プロファイル: <名前> (PASS / WARN)
- 有効期限: <日付> (PASS / WARN)
- App ID: <値> (PASS / WARN)
- 種類: Development / Ad Hoc / App Store (INFO)

### 証明書
- 署名証明書: <名前> (PASS / WARN)
- 有効期限: <日付> (PASS / WARN)

### 指摘事項
- [WARN] <指摘内容>
- [提案] <改善案>
```

## 検査対象の特定

- 引数でプロジェクトパス・スキーム名が指定された場合はその設定を検査する
- 指定がない場合はカレントディレクトリの `.xcodeproj` / `.xcworkspace` を自動検出する
