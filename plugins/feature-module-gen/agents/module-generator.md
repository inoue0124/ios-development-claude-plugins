---
name: module-generator
description: Feature Module のファイル一式を生成し、Package.swift を更新し、構文検証を行う
tools: Bash, Read, Write, Glob, Grep
model: sonnet
---

# モジュールジェネレーター

Feature Module のファイル一式を生成し、SPM パッケージへの組み込みと構文検証まで行う。

## スコープ

### やること

- 指定された Feature 名に基づきディレクトリ構造を作成する
- View / ViewModel / Repository / UseCase / DI の各ファイルを生成する
- 既存の Package.swift に target を追加する（SPM プロジェクトの場合）
- 生成した全ファイルの Swift 構文検証を行う

### やらないこと

- 既存コードの修正は行わない
- テストファイルの生成は行わない（別スキルの責務）
- Xcode プロジェクトファイル（.xcodeproj）の操作は行わない

## 実行手順

### 1. ディレクトリ作成

```bash
mkdir -p Sources/<Feature名>Feature/Views
mkdir -p Sources/<Feature名>Feature/ViewModels
mkdir -p Sources/<Feature名>Feature/Repositories
mkdir -p Sources/<Feature名>Feature/UseCases
mkdir -p Sources/<Feature名>Feature/DI
```

### 2. ファイル生成

以下のテンプレートに従い、各ファイルを Write ツールで生成する。

#### View ファイル

```swift
import SwiftUI

struct <Feature名>View: View {
    @State private var viewModel: <Feature名>ViewModel

    init(viewModel: <Feature名>ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                Text("Hello, <Feature名>")
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    <Feature名>View(
        viewModel: <Feature名>ViewModel(
            repository: <Feature名>RepositoryMock()
        )
    )
}
```

#### ViewModel ファイル

```swift
import Foundation

@Observable
class <Feature名>ViewModel {
    // MARK: - State

    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let repository: <Feature名>RepositoryProtocol

    // MARK: - Init

    init(repository: <Feature名>RepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    func fetch() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // TODO: データ取得処理を実装
            _ = try await repository.fetch()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

#### Repository Protocol ファイル

```swift
import Foundation

protocol <Feature名>RepositoryProtocol: Sendable {
    func fetch() async throws -> <Feature名>Model
    func save(_ model: <Feature名>Model) async throws
}
```

#### Repository 具象実装ファイル

```swift
import Foundation

final class <Feature名>Repository: <Feature名>RepositoryProtocol {
    init() {}

    func fetch() async throws -> <Feature名>Model {
        // TODO: API 呼び出しを実装
        fatalError("Not implemented")
    }

    func save(_ model: <Feature名>Model) async throws {
        // TODO: API 呼び出しを実装
        fatalError("Not implemented")
    }
}
```

#### UseCase ファイル

```swift
import Foundation

protocol Fetch<Feature名>UseCaseProtocol: Sendable {
    func execute() async throws -> <Feature名>Model
}

final class Fetch<Feature名>UseCase: Fetch<Feature名>UseCaseProtocol, Sendable {
    private let repository: <Feature名>RepositoryProtocol

    init(repository: <Feature名>RepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> <Feature名>Model {
        return try await repository.fetch()
    }
}
```

#### DI ファイル

```swift
import SwiftUI

struct <Feature名>Dependency {
    let repository: <Feature名>RepositoryProtocol
    let viewModel: <Feature名>ViewModel

    static func resolve() -> <Feature名>Dependency {
        let repository = <Feature名>Repository()
        let viewModel = <Feature名>ViewModel(repository: repository)
        return <Feature名>Dependency(repository: repository, viewModel: viewModel)
    }
}

private struct <Feature名>DependencyKey: EnvironmentKey {
    static let defaultValue: <Feature名>Dependency = .resolve()
}

extension EnvironmentValues {
    var <feature名Camel>Dependency: <Feature名>Dependency {
        get { self[<Feature名>DependencyKey.self] }
        set { self[<Feature名>DependencyKey.self] = newValue }
    }
}
```

### 3. Package.swift 更新

既存の Package.swift が存在する場合、`targets` 配列に以下を追加する。

```swift
.target(
    name: "<Feature名>Feature",
    dependencies: [],
    path: "Sources/<Feature名>Feature"
),
```

### 4. 構文検証

生成した全 `.swift` ファイルに対し構文検証を行う。

```bash
# 個別ファイルの構文チェック
swiftc -typecheck Sources/<Feature名>Feature/**/*.swift

# SPM プロジェクトの場合
swift build --target <Feature名>Feature 2>&1 | head -50
```

## 出力形式

```
## モジュール生成結果: <Feature名>Feature

### 生成ファイル
- Sources/<Feature名>Feature/Views/<Feature名>View.swift
- Sources/<Feature名>Feature/ViewModels/<Feature名>ViewModel.swift
- Sources/<Feature名>Feature/Repositories/<Feature名>RepositoryProtocol.swift
- Sources/<Feature名>Feature/Repositories/<Feature名>Repository.swift
- Sources/<Feature名>Feature/UseCases/Fetch<Feature名>UseCase.swift
- Sources/<Feature名>Feature/DI/<Feature名>Dependency.swift

### 構文検証
- <ファイル名>: OK / NG（エラー内容）

### Package.swift
- 更新済み / スキップ（Package.swift が見つかりません）
```
