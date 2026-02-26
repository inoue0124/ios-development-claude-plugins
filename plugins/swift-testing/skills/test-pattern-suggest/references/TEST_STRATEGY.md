# テスト戦略ガイド

## テストピラミッド

```
        /  E2E  \          ← 少数・遅い・高コスト
       / UI Test \
      /           \
     / Integration \       ← 中程度
    /               \
   /   Unit Test     \     ← 多数・高速・低コスト
  /___________________\
```

| レイヤー | テスト対象 | フレームワーク | 実行速度 |
|---|---|---|---|
| Unit | ViewModel / UseCase / Repository / Model | Swift Testing | 高速 |
| Integration | 複数コンポーネントの結合 | Swift Testing | 中程度 |
| UI | 画面操作・画面遷移 | XCUITest | 低速 |

## レイヤー別テスト戦略

### ViewModel テスト

最も重要なテスト対象。ビジネスロジックの大部分が含まれる。

**テスト観点:**
- 状態の初期値
- メソッド呼び出しによる状態変化
- 非同期処理の結果反映
- エラーハンドリング
- バリデーション

**推奨パターン:**
- AAA パターン（Arrange-Act-Assert）
- モックによる依存の差し替え
- パラメタライズドテスト（バリデーション系）

```swift
import Testing

@Suite("UserViewModel のテスト")
struct UserViewModelTests {
    let mock = MockUserRepository()

    @Test("初期状態: ユーザーは nil、ローディングは false")
    func initialState() {
        let viewModel = UserViewModel(repository: mock)
        #expect(viewModel.user == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("ユーザー取得成功で状態が更新される")
    func fetchSuccess() async {
        mock.fetchUserResult = .success(User(id: "1", name: "Alice"))
        let viewModel = UserViewModel(repository: mock)

        await viewModel.fetchUser(id: "1")

        #expect(viewModel.user?.name == "Alice")
    }

    @Test("ユーザー取得失敗でエラーメッセージが設定される")
    func fetchFailure() async {
        mock.fetchUserResult = .failure(APIError.networkError)
        let viewModel = UserViewModel(repository: mock)

        await viewModel.fetchUser(id: "1")

        #expect(viewModel.errorMessage != nil)
    }
}
```

### UseCase テスト

ビジネスルールの検証に焦点を当てる。

**テスト観点:**
- ビジネスルールの正しさ
- 入力のバリデーション
- Repository への委譲の確認
- エラー変換

**推奨パターン:**
- 入力 → 出力の検証
- 境界値テスト
- エラーケース

```swift
@Suite("FetchUsersUseCase のテスト")
struct FetchUsersUseCaseTests {
    @Test("ユーザーが名前順にソートされる")
    func sortByName() async throws {
        let mock = MockUserRepository()
        mock.fetchUsersResult = .success([
            User(id: "2", name: "Bob"),
            User(id: "1", name: "Alice"),
        ])
        let useCase = FetchUsersUseCase(repository: mock)

        let result = try await useCase.execute()

        #expect(result[0].name == "Alice")
        #expect(result[1].name == "Bob")
    }
}
```

### Repository テスト

データアクセス層の検証。

**テスト観点:**
- API リクエストの構築
- レスポンスのパース
- エラーハンドリング
- キャッシュの動作

**推奨パターン:**
- Mock HTTP Client の使用
- JSON レスポンスのスタブ

### Model テスト

データモデルの Codable / Equatable / 計算プロパティの検証。

**テスト観点:**
- JSON のエンコード / デコード
- 計算プロパティの正しさ
- Equatable の動作

```swift
@Suite("User モデルのテスト")
struct UserTests {
    @Test("JSON からデコードできる")
    func decodeFromJSON() throws {
        let json = """
        {"id": "1", "name": "Alice", "email": "alice@example.com"}
        """.data(using: .utf8)!

        let user = try JSONDecoder().decode(User.self, from: json)

        #expect(user.id == "1")
        #expect(user.name == "Alice")
    }

    @Test("不完全な JSON でデコードエラーが発生する")
    func decodeFailsWithIncompleteJSON() {
        let json = """
        {"id": "1"}
        """.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(User.self, from: json)
        }
    }
}
```

## テスト設計の原則

### FIRST 原則

| 原則 | 説明 |
|---|---|
| **F**ast | テストは高速に実行される |
| **I**ndependent | テスト間に依存関係がない |
| **R**epeatable | 何度実行しても同じ結果 |
| **S**elf-validating | 自動で成否を判定 |
| **T**imely | プロダクションコードと同時に書く |

### テストケースの分類

| 分類 | 説明 | 例 |
|---|---|---|
| 正常系 | 期待される入力で正しく動作する | 有効なメールアドレスでログイン成功 |
| 異常系 | エラー入力で適切にハンドリングされる | 無効なメールアドレスでバリデーションエラー |
| 境界値 | 境界条件で正しく動作する | 空文字列、最大長、0、負数 |
| 並行性 | 並行アクセスでデータ競合が発生しない | 同時書き込み |

### カバレッジ目標

| レイヤー | 目標カバレッジ | 理由 |
|---|---|---|
| ViewModel | 80% 以上 | ビジネスロジックの中心 |
| UseCase | 90% 以上 | ビジネスルールの正しさが重要 |
| Repository | 70% 以上 | データアクセスの信頼性 |
| Model | 80% 以上 | Codable / 計算プロパティ |
| View | 低い | UI テストで補完 |

## Swift Testing 固有の機能

### 条件付きテスト

```swift
@Test("iOS 18 以降で動作する機能", .enabled(if: ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 18))
func ios18Feature() { ... }
```

### タイムリミット

```swift
@Test("API 呼び出しが 5 秒以内に完了する", .timeLimit(.seconds(5)))
func apiCallTimeout() async throws { ... }
```

### 既知の問題

```swift
@Test("既知のバグ: 特定条件でクラッシュする")
func knownIssue() {
    withKnownIssue("Issue #123 で修正予定") {
        // クラッシュするコード
    }
}
```
