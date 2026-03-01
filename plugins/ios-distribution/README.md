# ios-distribution — TestFlight 配信・署名・リリース管理

アーカイブビルド・TestFlight アップロード・リリース管理の配信フローを自動化する。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | signing-check | 署名・プロビジョニング確認 |
| skill (manual) | build-archive | IPA 生成 |
| skill (manual) | testflight-upload | ビルド番号更新 + archive + upload + コミット |
| skill (manual) | release | Git タグ + GitHub Release + App Store リリースノート生成 |

## リリースフロー

```
開発完了 → /testflight-upload → QA テスト → 審査提出 → 審査合格 → /release
```

- `/testflight-upload`: ビルド番号更新・アーカイブ・TestFlight アップロード・コミット
- `/release`: リリースノート生成・Git タグ・GitHub Release 作成（ビルドしない）

## subagent

| 名前 | 内容 |
|---|---|
| archive-runner | アーカイブ + アップロード（隔離実行） |
