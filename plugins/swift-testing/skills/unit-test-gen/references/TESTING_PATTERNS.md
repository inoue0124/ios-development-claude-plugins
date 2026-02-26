# Swift Testing フレームワーク テストパターン集

## Swift Testing vs XCTest 対応表

| XCTest（レガシー） | Swift Testing（推奨） |
|---|---|
| `import XCTest` | `import Testing` |
| `class XxxTests: XCTestCase` | `struct XxxTests` |
| `func testXxx()` | `@Test("説明") func xxx()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertNotEqual(a, b)` | `#expect(a != b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertFalse(x)` | `#expect(!x)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertNotNil(x)` | `#expect(x != nil)` |
| `XCTAssertGreaterThan(a, b)` | `#expect(a > b)` |
| `XCTAssertThrowsError(expr)` | `#expect(throws: ErrorType.self) { expr }` |
| `XCTFail("message")` | `Issue.record("message")` |
| `XCTSkip("reason")` | `throw SkipError("reason")` を `withKnownIssue` で使用 |
| `setUp()` | `init()` |
| `tearDown()` | `deinit`（class の場合のみ） |
| `setUpWithError()` | `init() throws` |
| `measure { }` | 現時点では未サポート（XCTest を併用） |

## ViewModel テストパターン

### @Observable ViewModel の基本テスト

```swift
import Testing

@Observable
class UserViewModel {
    var user: User?
    var isLoading = false
    var errorMessage: String?

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor
    func fetchUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await repository.fetchUser(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct UserViewModelTests {
    @Test("ユーザー取得に成功すると user が更新される")
    func fetchUserSuccess() async {
        let mock = MockUserRepository()
        mock.fetchUserResult = .success(User(id: "1", name: "Alice"))
        let viewModel = UserViewModel(repository: mock)

        await viewModel.fetchUser(id: "1")

        #expect(viewModel.user?.name == "Alice")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("ユーザー取得に失敗するとエラーメッセージが設定される")
    func fetchUserFailure() async {
        let mock = MockUserRepository()
        mock.fetchUserResult = .failure(APIError.networkError)
        let viewModel = UserViewModel(repository: mock)

        await viewModel.fetchUser(id: "1")

        #expect(viewModel.user == nil)
        #expect(viewModel.errorMessage != nil)
    }
}
```

### パラメタライズドテスト

```swift
@Test("バリデーション", arguments: [
    ("valid@email.com", true),
    ("invalid", false),
    ("", false),
    ("a@b.c", true),
])
func emailValidation(email: String, expected: Bool) {
    let validator = EmailValidator()
    #expect(validator.isValid(email) == expected)
}
```

### タグによるテスト分類

```swift
extension Tag {
    @Tag static var viewModel: Self
    @Tag static var repository: Self
    @Tag static var useCase: Self
    @Tag static var slow: Self
}

@Test("高速なテスト", .tags(.viewModel))
func fastTest() { ... }

@Test("遅いテスト", .tags(.slow), .timeLimit(.minutes(1)))
func slowTest() async { ... }
```

### Suite によるテストグルーピング

```swift
@Suite("UserViewModel のテスト")
struct UserViewModelTests {
    let viewModel: UserViewModel
    let mock: MockUserRepository

    init() {
        mock = MockUserRepository()
        viewModel = UserViewModel(repository: mock)
    }

    @Test("初期状態は空")
    func initialState() {
        #expect(viewModel.user == nil)
        #expect(viewModel.isLoading == false)
    }

    @Suite("fetch 操作")
    struct FetchTests {
        @Test("成功")
        func success() async { ... }

        @Test("失敗")
        func failure() async { ... }
    }
}
```

## Repository テストパターン

### Protocol を使ったテスト

```swift
protocol UserRepositoryProtocol: Sendable {
    func fetchUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}

struct UserRepositoryTests {
    @Test("fetchUser が正しい URL を呼び出す")
    func fetchUserCallsCorrectURL() async throws {
        let mockClient = MockHTTPClient()
        mockClient.responseData = try JSONEncoder().encode(User(id: "1", name: "Test"))
        let repository = UserRepository(httpClient: mockClient)

        _ = try await repository.fetchUser(id: "1")

        #expect(mockClient.lastRequestURL?.path == "/users/1")
    }
}
```

## UseCase テストパターン

```swift
struct FetchUsersUseCaseTests {
    @Test("正常系: ユーザー一覧を取得してソートする")
    func fetchAndSort() async throws {
        let mock = MockUserRepository()
        mock.fetchUsersResult = .success([
            User(id: "2", name: "Bob"),
            User(id: "1", name: "Alice"),
        ])
        let useCase = FetchUsersUseCase(repository: mock)

        let users = try await useCase.execute()

        #expect(users[0].name == "Alice")
        #expect(users[1].name == "Bob")
    }
}
```

## エラーテストパターン

```swift
@Test("ネットワークエラーが適切にハンドリングされる")
func handleNetworkError() async {
    let mock = MockUserRepository()
    mock.fetchUserResult = .failure(APIError.networkError)
    let viewModel = UserViewModel(repository: mock)

    await viewModel.fetchUser(id: "1")

    #expect(viewModel.errorMessage == "ネットワークエラーが発生しました")
}

@Test("不正な入力でエラーがスローされる")
func throwOnInvalidInput() {
    let validator = InputValidator()

    #expect(throws: ValidationError.empty) {
        try validator.validate("")
    }
}
```

## Concurrency テストパターン

```swift
@Test("並行アクセスでデータ競合が発生しない")
func concurrentAccess() async {
    let cache = UserCache()

    await withTaskGroup(of: Void.self) { group in
        for i in 0..<100 {
            group.addTask {
                await cache.set(User(id: "\(i)", name: "User\(i)"))
            }
        }
    }

    let count = await cache.count
    #expect(count == 100)
}
```
