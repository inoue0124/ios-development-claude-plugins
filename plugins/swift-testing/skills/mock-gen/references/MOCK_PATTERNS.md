# モック / スタブ / スパイ パターン集

## テストダブルの種別

| 種別 | 目的 | 特徴 |
|---|---|---|
| Stub | 固定値を返す | 戻り値の制御のみ |
| Mock | 呼び出しを記録・検証 | 呼び出し回数・引数を検証 |
| Spy | 実装を呼びつつ記録 | 実オブジェクトの振る舞い + 記録 |
| Fake | 簡易な実装 | インメモリ DB など |

## 基本的なモック生成パターン

### 同期メソッドのモック

```swift
protocol FormatterProtocol {
    func format(_ value: Int) -> String
}

final class MockFormatter: FormatterProtocol {
    var formatCallCount = 0
    var formatLastArgument: Int?
    var formatResult: String = ""

    func format(_ value: Int) -> String {
        formatCallCount += 1
        formatLastArgument = value
        return formatResult
    }
}
```

### 非同期メソッドのモック

```swift
protocol UserRepositoryProtocol: Sendable {
    func fetchUser(id: String) async throws -> User
    func fetchUsers() async throws -> [User]
    func saveUser(_ user: User) async throws
    func deleteUser(id: String) async throws
}

final class MockUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    // fetchUser
    var fetchUserCallCount = 0
    var fetchUserLastArgument: String?
    var fetchUserResult: Result<User, Error> = .failure(MockError.notConfigured)

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserLastArgument = id
        return try fetchUserResult.get()
    }

    // fetchUsers
    var fetchUsersCallCount = 0
    var fetchUsersResult: Result<[User], Error> = .failure(MockError.notConfigured)

    func fetchUsers() async throws -> [User] {
        fetchUsersCallCount += 1
        return try fetchUsersResult.get()
    }

    // saveUser
    var saveUserCallCount = 0
    var saveUserLastArgument: User?

    func saveUser(_ user: User) async throws {
        saveUserCallCount += 1
        saveUserLastArgument = user
    }

    // deleteUser
    var deleteUserCallCount = 0
    var deleteUserLastArgument: String?

    func deleteUser(id: String) async throws {
        deleteUserCallCount += 1
        deleteUserLastArgument = id
    }
}

enum MockError: Error {
    case notConfigured
}
```

### プロパティを持つ Protocol のモック

```swift
protocol SettingsProtocol {
    var isDarkMode: Bool { get set }
    var fontSize: Int { get }
}

final class MockSettings: SettingsProtocol {
    var isDarkMode: Bool = false
    var fontSize: Int = 14
}
```

### クロージャを持つ Protocol のモック

```swift
protocol EventHandlerProtocol {
    func onEvent(_ handler: @escaping @Sendable (Event) -> Void)
}

final class MockEventHandler: EventHandlerProtocol {
    var onEventCallCount = 0
    var onEventLastHandler: (@Sendable (Event) -> Void)?

    func onEvent(_ handler: @escaping @Sendable (Event) -> Void) {
        onEventCallCount += 1
        onEventLastHandler = handler
    }

    /// テストからイベントを発火する
    func simulateEvent(_ event: Event) {
        onEventLastHandler?(event)
    }
}
```

## Fake パターン

### インメモリ Repository

```swift
actor FakeUserRepository: UserRepositoryProtocol {
    private var users: [String: User] = [:]

    func fetchUser(id: String) async throws -> User {
        guard let user = users[id] else {
            throw APIError.notFound
        }
        return user
    }

    func saveUser(_ user: User) async throws {
        users[user.id] = user
    }

    func deleteUser(id: String) async throws {
        users.removeValue(forKey: id)
    }

    // テストヘルパー
    func seed(_ users: [User]) {
        for user in users {
            self.users[user.id] = user
        }
    }
}
```

## Spy パターン

```swift
final class SpyUserRepository: @unchecked Sendable {
    private let real: UserRepositoryProtocol
    var callLog: [(method: String, arguments: [Any])] = []

    init(real: UserRepositoryProtocol) {
        self.real = real
    }

    func fetchUser(id: String) async throws -> User {
        callLog.append((method: "fetchUser", arguments: [id]))
        return try await real.fetchUser(id: id)
    }
}
```

## Sendable 対応ガイドライン

### テスト用モックの Sendable 対応

テスト用モックは通常、単一のテスト関数内で使用されるため `@unchecked Sendable` を許容する。

```swift
// テスト用: @unchecked Sendable は許容
final class MockUserRepository: UserRepositoryProtocol, @unchecked Sendable {
    // ...
}
```

### actor ベースの Fake

並行テストで使用する場合は actor として実装する。

```swift
// 並行テスト用: actor で安全性を保証
actor FakeUserRepository: UserRepositoryProtocol {
    // ...
}
```

## 複数の Protocol に準拠するモック

```swift
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async
}

protocol TokenStorageProtocol {
    func save(_ token: AuthToken) async
    func load() async -> AuthToken?
    func clear() async
}

// 複数 Protocol 準拠
final class MockAuthContext: AuthServiceProtocol, TokenStorageProtocol, @unchecked Sendable {
    // AuthServiceProtocol
    var loginCallCount = 0
    var loginResult: Result<AuthToken, Error> = .failure(MockError.notConfigured)

    func login(email: String, password: String) async throws -> AuthToken {
        loginCallCount += 1
        return try loginResult.get()
    }

    var logoutCallCount = 0

    func logout() async {
        logoutCallCount += 1
    }

    // TokenStorageProtocol
    var savedToken: AuthToken?

    func save(_ token: AuthToken) async {
        savedToken = token
    }

    func load() async -> AuthToken? {
        savedToken
    }

    func clear() async {
        savedToken = nil
    }
}
```
