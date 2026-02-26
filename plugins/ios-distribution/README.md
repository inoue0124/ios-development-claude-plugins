# ios-distribution — TestFlight 配信・署名

アーカイブビルドから TestFlight アップロードまでの配信フローを自動化する。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | signing-check | 署名・プロビジョニング確認 |
| skill (manual) | build-archive | IPA 生成 |
| skill (manual) | testflight-upload | archive + upload（xcodebuild + xcrun altool） |

## subagent

| 名前 | 内容 |
|---|---|
| archive-runner | アーカイブ + アップロード（隔離実行） |
