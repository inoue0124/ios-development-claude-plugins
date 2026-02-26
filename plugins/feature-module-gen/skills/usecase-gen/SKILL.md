---
name: usecase-gen
description: UseCase ファイルを生成する。単一責務の execute メソッドを持つ UseCase パターン。「UseCase 生成」「ユースケース」「ビジネスロジック」「UseCase 作成」で自動適用。
---

# UseCase 生成

指定されたユースケースに基づき、単一責務の UseCase ファイルを生成する。

## ツール使用方針

- ファイル作成・プロジェクトへの追加は xcodeproj-mcp-server の利用を優先する
- 構文検証は XcodeBuildMCP の `swift_typecheck` を優先する
- MCP が利用できない場合は `cat` / `swiftc -typecheck` 等の CLI にフォールバックする

## 入力

- **UseCase 名**（例: `FetchUserProfileUseCase`）
- **責務の説明**（省略可。指定された場合は execute メソッドのシグネチャを調整する）
- **出力先ディレクトリ**（省略時は `UseCases/` を推定）

## 生成テンプレート

### Protocol + 具象実装

```swift
import Foundation

protocol <UseCaseName>Protocol: Sendable {
    func execute() async throws -> <ReturnType>
}

final class <UseCaseName>: <UseCaseName>Protocol, Sendable {
    // MARK: - Dependencies

    private let repository: <RepositoryProtocolName>

    // MARK: - Init

    init(repository: <RepositoryProtocolName>) {
        self.repository = repository
    }

    // MARK: - Execute

    func execute() async throws -> <ReturnType> {
        // TODO: ビジネスロジック
        return try await repository.fetch()
    }
}
```

### 規約

- 1 UseCase = 1 責務（Single Responsibility）
- 公開メソッドは `execute` のみとする
- `Sendable` に準拠する
- Protocol を定義しテスタビリティを確保する
- Repository は Protocol 経由でコンストラクタ注入する
- `import Foundation` のみ（`import SwiftUI` は禁止）
- `async throws` で非同期エラーハンドリングに対応する
- 複数の Repository を組み合わせるオーケストレーションも UseCase の責務とする

### 複数 Repository を使う場合

```swift
final class PlaceOrderUseCase: PlaceOrderUseCaseProtocol, Sendable {
    private let orderRepository: OrderRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol

    init(
        orderRepository: OrderRepositoryProtocol,
        paymentRepository: PaymentRepositoryProtocol
    ) {
        self.orderRepository = orderRepository
        self.paymentRepository = paymentRepository
    }

    func execute(order: Order) async throws -> OrderConfirmation {
        let payment = try await paymentRepository.process(order.payment)
        return try await orderRepository.place(order, payment: payment)
    }
}
```

## 生成後の確認

- 生成したファイルが Swift の構文として正しいか検証する
  - MCP: XcodeBuildMCP の `swift_typecheck` を使用
  - CLI フォールバック: `swiftc -typecheck <ファイル>` を実行
