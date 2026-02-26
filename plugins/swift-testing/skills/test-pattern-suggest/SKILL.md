---
name: test-pattern-suggest
description: テスト対象に適切なテストパターンを提案する。AAA パターン、パラメタライズドテスト、非同期テスト等のベストプラクティスを提案。「テストパターン」「テスト設計」「テスト戦略」「パラメタライズド」「テスト構造」で自動適用。
---

# テストパターン提案

テスト対象のコードを分析し、最適なテストパターンとテスト戦略を提案する。
テストパターンの詳細は → **references/TEST_STRATEGY.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 提案するパターン

### 1. AAA パターン（Arrange-Act-Assert）

全テストケースの基本構造として推奨する。

```swift
@Test("ユーザーの表示名が正しくフォーマットされる")
func formatDisplayName() {
    // Arrange
    let user = User(firstName: "Taro", lastName: "Yamada")
    let formatter = UserNameFormatter()

    // Act
    let result = formatter.format(user)

    // Assert
    #expect(result == "Yamada Taro")
}
```

### 2. パラメタライズドテスト

同一ロジックを複数の入力で検証する場合に推奨する。

```swift
@Test("メールアドレスのバリデーション", arguments: [
    ("user@example.com", true),
    ("invalid-email", false),
    ("", false),
    ("user@.com", false),
    ("user@example.co.jp", true),
])
func validateEmail(email: String, expected: Bool) {
    let validator = EmailValidator()
    #expect(validator.isValid(email) == expected)
}
```

### 3. 非同期テスト

async / await を使用するコードのテストパターン。

```swift
@Test("API からユーザー一覧を取得する")
func fetchUsers() async throws {
    let mock = MockUserRepository()
    mock.fetchUsersResult = .success([User(id: "1", name: "Alice")])
    let useCase = FetchUsersUseCase(repository: mock)

    let users = try await useCase.execute()

    #expect(users.count == 1)
    #expect(users[0].name == "Alice")
}
```

### 4. エラーハンドリングテスト

throws 関数のエラーケースを検証するパターン。

```swift
@Test("無効な ID でエラーがスローされる")
func throwsOnInvalidId() async {
    let mock = MockUserRepository()
    mock.fetchUserResult = .failure(APIError.notFound)
    let viewModel = UserViewModel(repository: mock)

    await #expect(throws: APIError.notFound) {
        try await viewModel.fetchUser(id: "invalid")
    }
}
```

### 5. @Observable ViewModel テスト

状態変化の検証パターン。

```swift
@Test("読み込み中フラグが正しく遷移する")
func loadingStateTransition() async {
    let mock = MockUserRepository()
    mock.fetchUserResult = .success(User(id: "1", name: "Alice"))
    let viewModel = UserViewModel(repository: mock)

    #expect(viewModel.isLoading == false)

    await viewModel.fetchUser(id: "1")

    #expect(viewModel.isLoading == false)
    #expect(viewModel.user != nil)
}
```

### 6. タグによるテスト分類

Swift Testing の Tag 機能でテストを分類する。

```swift
extension Tag {
    @Tag static var viewModel: Self
    @Tag static var repository: Self
    @Tag static var integration: Self
}

@Test("ログイン処理", .tags(.viewModel))
func login() async { ... }

@Test("DB 保存", .tags(.repository, .integration))
func saveToDatabase() async throws { ... }
```

## 分析と提案の手順

1. 対象ファイルを読み取り、型の責務（ViewModel / UseCase / Repository 等）を特定する
2. メソッドの特性を分析する（同期 / 非同期、戻り値の有無、エラーの可能性）
3. 依存関係を特定する（モックが必要な Protocol）
4. 以下の観点で最適なテストパターンを選択する
   - 入力バリエーションが多い → パラメタライズドテスト
   - 非同期処理を含む → 非同期テスト
   - エラーケースがある → エラーハンドリングテスト
   - 状態変化がある → 状態遷移テスト
5. テスト分類（Tag）の提案を行う

## 出力

```
## テストパターン提案: <対象ファイル名>

### 対象の概要
- 型: <型名>（<ViewModel / UseCase / Repository 等>）
- メソッド数: N（テスト対象: N）
- 依存 Protocol: N 個

### 推奨パターン
| メソッド | 推奨パターン | 理由 |
|---|---|---|
| fetchUser() | 非同期テスト + エラーハンドリング | async throws メソッドのため |
| validate() | パラメタライズドテスト | 複数の入力バリエーションがあるため |

### テストケース候補
- <メソッド名>: 正常系 N 件、異常系 N 件、境界値 N 件

### Tag 提案
- .viewModel: ViewModel のテスト
- .integration: 統合テスト
```

## テスト対象の特定

- 引数でファイルパスが指定された場合はそのファイルを対象にする
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイル（テストファイルを除く）を対象にする
