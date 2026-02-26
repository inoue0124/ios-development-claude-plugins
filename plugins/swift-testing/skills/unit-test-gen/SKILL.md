---
name: unit-test-gen
description: 対象コードからユニットテストを生成する。Swift Testing フレームワーク（@Test, #expect）を使用。「ユニットテスト」「テスト生成」「テストケース」「Swift Testing」「@Test」で自動適用。
---

# ユニットテスト生成

対象の Swift ファイルを解析し、Swift Testing フレームワークを使用したユニットテストコードを生成する。
テスト生成パターンの詳細は → **references/TESTING_PATTERNS.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る
- テストファイルの追加は xcodeproj-mcp-server でプロジェクトに登録する
- MCP が利用できない場合は手動でファイルを配置し、ユーザーに Xcode での追加を案内する

## Swift Testing フレームワーク

テストコードは必ず Swift Testing フレームワークで記述する。

```swift
import Testing

struct UserViewModelTests {
    @Test("ユーザー名が正しく更新される")
    func updateUserName() async {
        let repository = MockUserRepository()
        let viewModel = UserViewModel(repository: repository)

        await viewModel.updateName("Alice")

        #expect(viewModel.name == "Alice")
    }

    @Test("空文字列のバリデーションが失敗する")
    func validateEmptyName() {
        let viewModel = UserViewModel(repository: MockUserRepository())

        let result = viewModel.validate(name: "")

        #expect(result == false)
    }
}
```

### レガシーパターンの検出

以下のパターンを検出した場合は Swift Testing への移行を提案する。

| 旧（非推奨） | 新（推奨） |
|---|---|
| `import XCTest` | `import Testing` |
| `class XxxTests: XCTestCase` | `struct XxxTests` |
| `func testXxx()` | `@Test func xxx()` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTAssertNil(x)` | `#expect(x == nil)` |
| `XCTAssertThrowsError(expr)` | `#expect(throws: SomeError.self) { expr }` |
| `setUp() / tearDown()` | `init() / deinit`（struct の場合は init のみ） |

## 生成手順

1. 対象ファイルを読み取り、テスト対象の型（class / struct / enum）を特定する
2. public / internal メソッドを列挙し、テストケースの候補を洗い出す
3. 依存する Protocol を特定し、モック / スタブの要否を判断する
4. 正常系・異常系・境界値のテストケースを生成する
5. async メソッドには `async` テストを生成する
6. `@Observable` ViewModel のテストでは状態変化の検証を含める

## テスト命名規則

- テスト関数名は振る舞いを説明する英語の動詞句にする
- `@Test` マクロの引数に日本語の説明を記述する

```swift
@Test("ログインに成功するとホーム画面に遷移する")
func navigateToHomeOnLoginSuccess() async { ... }

@Test("無効なメールアドレスでバリデーションエラーが発生する")
func failValidationWithInvalidEmail() { ... }
```

## Concurrency 対応

- `@Observable` ViewModel は `@MainActor` で分離されている前提でテストを記述する
- `await` が必要な箇所を正しく処理する
- `Sendable` 準拠を考慮したテストデータの設計

## 出力

```
## ユニットテスト生成: <対象ファイル名>

### 生成されたテストケース: N 件
- 正常系: N 件
- 異常系: N 件
- 境界値: N 件

### テストコード
<Swift Testing フレームワークによるテストコード>

### 必要なモック / スタブ
- <Protocol 名> → <モッククラス名>

### 注意事項
- <非同期処理や副作用に関する注意>
```

## テスト対象の特定

- 引数でファイルパスが指定された場合はそのファイルを対象にする
- 指定がない場合は `git diff` の変更ファイルから `.swift` ファイル（テストファイルを除く）を対象にする
