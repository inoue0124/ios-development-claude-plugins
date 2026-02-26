---
name: mock-gen
description: Protocol 準拠のモック・スタブを自動生成する。テストダブルの生成でテスタビリティを向上。「モック生成」「スタブ」「テストダブル」「Mock」「Stub」「Spy」で自動適用。
---

# モック / スタブ自動生成

Protocol 定義を解析し、テスト用のモック・スタブクラスを自動生成する。
モックパターンの詳細は → **references/MOCK_PATTERNS.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## テストダブルの種別

| 種別 | 用途 | 生成条件 |
|---|---|---|
| Mock | メソッド呼び出しの記録・検証 | デフォルト |
| Stub | 固定値を返すだけの実装 | 戻り値のみ必要な場合 |
| Spy | 実装を呼びつつ呼び出しを記録 | 実装の振る舞いも検証したい場合 |

## 生成例

### Protocol からのモック生成

```swift
// 元の Protocol
protocol UserRepositoryProtocol: Sendable {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
    func deleteUser(id: String) async throws
}

// 生成されるモック
final class MockUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    // 呼び出し記録
    var fetchUserCallCount = 0
    var fetchUserLastArgument: String?

    var saveUserCallCount = 0
    var saveUserLastArgument: User?

    var deleteUserCallCount = 0
    var deleteUserLastArgument: String?

    // スタブ戻り値
    var fetchUserResult: Result<User, Error> = .failure(MockError.notConfigured)

    // 実装
    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserLastArgument = id
        return try fetchUserResult.get()
    }

    func saveUser(_ user: User) async throws {
        saveUserCallCount += 1
        saveUserLastArgument = user
    }

    func deleteUser(id: String) async throws {
        deleteUserCallCount += 1
        deleteUserLastArgument = id
    }
}

enum MockError: Error {
    case notConfigured
}
```

### テストでの使用例

```swift
import Testing

struct UserViewModelTests {
    @Test("ユーザー取得が成功すると状態が更新される")
    func fetchUserSuccess() async {
        let mock = MockUserRepository()
        mock.fetchUserResult = .success(User(id: "1", name: "Alice"))
        let viewModel = UserViewModel(repository: mock)

        await viewModel.fetchUser(id: "1")

        #expect(viewModel.user?.name == "Alice")
        #expect(mock.fetchUserCallCount == 1)
        #expect(mock.fetchUserLastArgument == "1")
    }
}
```

## 生成手順

1. 対象ファイルまたは指定された Protocol を読み取る
2. Protocol のメソッド・プロパティ要件を解析する
3. 各メソッドの引数・戻り値・throws / async 属性を特定する
4. 呼び出し記録用のプロパティを生成する
5. スタブ戻り値用のプロパティを生成する（戻り値がある場合）
6. Protocol 準拠の実装を生成する
7. `Sendable` 準拠が必要な場合は `@unchecked Sendable` を付与する

## Sendable 対応

- Protocol が `Sendable` に準拠している場合、モックも `@unchecked Sendable` で準拠させる
- テスト用モックは単一スレッドで使用する前提のため `@unchecked` を許容する
- 本番コードでの `@unchecked Sendable` の使用は推奨しない旨を注記する

## 出力

```
## モック生成: <Protocol 名>

### 生成された型
- MockXxx（Mock）: メソッド呼び出しの記録 + スタブ戻り値

### メソッド一覧
| メソッド | 引数記録 | 戻り値スタブ | async | throws |
|---|---|---|---|---|
| fetchUser(id:) | fetchUserLastArgument | fetchUserResult | Yes | Yes |
| saveUser(_:) | saveUserLastArgument | - | Yes | Yes |

### 生成コード
<モッククラスのコード>

### 使用例
<テストコードでの使用例>
```

## テスト対象の特定

- 引数で Protocol 名またはファイルパスが指定された場合はそれを対象にする
- 指定がない場合は `git diff` の変更ファイルから Protocol 定義を含む `.swift` ファイルを対象にする
