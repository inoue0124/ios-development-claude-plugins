---
name: repository-gen
description: Repository と Protocol ファイルを生成する。データアクセス層の抽象化と具象実装を分離。「Repository 生成」「データアクセス」「API クライアント」「Repository 作成」で自動適用。
---

# Repository + Protocol 生成

指定されたドメインに基づき、Repository の Protocol 定義と具象実装を生成する。

## ツール使用方針

- ファイル作成・プロジェクトへの追加は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `cat` / `swiftc -typecheck` 等の CLI にフォールバックする

## 入力

- **Repository 名**（例: `UserProfileRepository`）
- **ドメインの説明**（省略可。指定された場合はメソッドを調整する）
- **出力先ディレクトリ**（省略時は `Repositories/` を推定）

## 生成ファイル

1 つの Repository に対し、Protocol ファイルと具象実装ファイルの 2 ファイルを生成する。

### Protocol ファイル

```swift
import Foundation

protocol <RepositoryName>Protocol: Sendable {
    func fetch() async throws -> <ModelName>
    func save(_ model: <ModelName>) async throws
}
```

### 具象実装ファイル

```swift
import Foundation

final class <RepositoryName>: <RepositoryName>Protocol {
    // MARK: - Dependencies

    private let apiClient: APIClientProtocol

    // MARK: - Init

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - <RepositoryName>Protocol

    func fetch() async throws -> <ModelName> {
        // TODO: API 呼び出し
        fatalError("Not implemented")
    }

    func save(_ model: <ModelName>) async throws {
        // TODO: API 呼び出し
        fatalError("Not implemented")
    }
}
```

### 規約

- Protocol と具象クラスは別ファイルに分離する
- Protocol は `Sendable` に準拠する
- メソッドは `async throws` で定義する
- 具象クラスは `final class` で宣言する
- 依存（API クライアント等）は Protocol 経由でコンストラクタ注入する
- `import Foundation` のみ（`import SwiftUI` は禁止）

## 生成後の確認

- 生成したファイルが Swift の構文として正しいか検証する
  - MCP: XcodeBuildMCP の `swift_typecheck` を使用
  - CLI フォールバック: `swiftc -typecheck <ファイル>` を実行
