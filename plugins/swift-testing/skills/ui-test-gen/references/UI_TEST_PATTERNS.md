# UI テストパターン集

## アクセシビリティ識別子の設計

### 命名規則

```swift
// 画面名 + 要素種別 + 説明
.accessibilityIdentifier("userProfile_text_userName")
.accessibilityIdentifier("userProfile_button_edit")
.accessibilityIdentifier("userProfile_image_avatar")
.accessibilityIdentifier("login_textField_email")
.accessibilityIdentifier("login_textField_password")
.accessibilityIdentifier("login_button_submit")
```

### SwiftUI での識別子付与

```swift
struct UserProfileView: View {
    @State private var viewModel: UserProfileViewModel

    var body: some View {
        VStack {
            AsyncImage(url: viewModel.avatarURL)
                .accessibilityIdentifier("userProfile_image_avatar")

            Text(viewModel.userName)
                .accessibilityIdentifier("userProfile_text_userName")

            Text(viewModel.email)
                .accessibilityIdentifier("userProfile_text_email")

            Button("Edit Profile") {
                viewModel.showEditSheet = true
            }
            .accessibilityIdentifier("userProfile_button_edit")

            List(viewModel.posts) { post in
                PostRow(post: post)
                    .accessibilityIdentifier("userProfile_cell_post_\(post.id)")
            }
            .accessibilityIdentifier("userProfile_list_posts")
        }
    }
}
```

## テストパターン

### 1. 画面要素の存在確認

```swift
final class UserProfileUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testProfileScreenElementsExist() {
        navigateToProfile()

        XCTAssertTrue(app.images["userProfile_image_avatar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["userProfile_text_userName"].exists)
        XCTAssertTrue(app.staticTexts["userProfile_text_email"].exists)
        XCTAssertTrue(app.buttons["userProfile_button_edit"].exists)
    }
}
```

### 2. テキスト入力テスト

```swift
func testLoginWithValidCredentials() {
    let emailField = app.textFields["login_textField_email"]
    let passwordField = app.secureTextFields["login_textField_password"]
    let loginButton = app.buttons["login_button_submit"]

    emailField.tap()
    emailField.typeText("user@example.com")

    passwordField.tap()
    passwordField.typeText("password123")

    loginButton.tap()

    // ホーム画面への遷移を確認
    XCTAssertTrue(app.staticTexts["home_text_welcome"].waitForExistence(timeout: 10))
}
```

### 3. リスト操作テスト

```swift
func testScrollAndTapListItem() {
    let list = app.collectionViews["userProfile_list_posts"]

    // スクロール
    list.swipeUp()

    // セルのタップ
    let cell = list.cells.matching(identifier: "userProfile_cell_post_1").firstMatch
    XCTAssertTrue(cell.waitForExistence(timeout: 5))
    cell.tap()

    // 詳細画面への遷移確認
    XCTAssertTrue(app.staticTexts["postDetail_text_title"].waitForExistence(timeout: 5))
}
```

### 4. シート / モーダルテスト

```swift
func testEditProfileSheet() {
    navigateToProfile()

    app.buttons["userProfile_button_edit"].tap()

    // シートの表示確認
    let editSheet = app.sheets.firstMatch
    XCTAssertTrue(editSheet.waitForExistence(timeout: 5))

    // シート内の操作
    let nameField = app.textFields["editProfile_textField_name"]
    nameField.tap()
    nameField.clearAndEnterText("Updated Name")

    app.buttons["editProfile_button_save"].tap()

    // シートが閉じたことを確認
    XCTAssertFalse(editSheet.exists)

    // 更新されたデータの確認
    XCTAssertTrue(app.staticTexts["Updated Name"].waitForExistence(timeout: 5))
}
```

### 5. アラートテスト

```swift
func testDeleteConfirmationAlert() {
    navigateToProfile()

    app.buttons["userProfile_button_delete"].tap()

    let alert = app.alerts.firstMatch
    XCTAssertTrue(alert.waitForExistence(timeout: 5))
    XCTAssertTrue(alert.staticTexts["本当に削除しますか？"].exists)

    alert.buttons["削除"].tap()

    XCTAssertFalse(alert.exists)
}
```

### 6. プルトゥリフレッシュテスト

```swift
func testPullToRefresh() {
    navigateToProfile()

    let list = app.collectionViews["userProfile_list_posts"]
    let firstCell = list.cells.firstMatch

    // プルトゥリフレッシュ
    firstCell.swipeDown()

    // ローディングインジケーター
    XCTAssertTrue(app.activityIndicators.firstMatch.waitForExistence(timeout: 2))

    // データの再読み込み完了を待つ
    XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
}
```

### 7. エラー状態テスト

```swift
func testNetworkErrorDisplay() {
    // 環境変数でエラーをシミュレート
    app.launchArguments.append("--mock-network-error")
    app.launch()

    navigateToProfile()

    // エラーメッセージの表示確認
    XCTAssertTrue(app.staticTexts["error_text_message"].waitForExistence(timeout: 10))
    XCTAssertTrue(app.buttons["error_button_retry"].exists)

    // リトライ
    app.buttons["error_button_retry"].tap()
}
```

## ヘルパーメソッド

```swift
extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = value as? String else {
            typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
        typeText(text)
    }
}

extension XCTestCase {
    func navigateToProfile() {
        let app = XCUIApplication()
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(app.staticTexts["userProfile_text_userName"].waitForExistence(timeout: 5))
    }
}
```

## Page Object パターン

画面ごとに Page Object を定義し、テストの可読性と保守性を向上させる。

```swift
struct UserProfilePage {
    let app: XCUIApplication

    var userName: XCUIElement { app.staticTexts["userProfile_text_userName"] }
    var editButton: XCUIElement { app.buttons["userProfile_button_edit"] }
    var postsList: XCUIElement { app.collectionViews["userProfile_list_posts"] }

    func tapEdit() -> EditProfilePage {
        editButton.tap()
        return EditProfilePage(app: app)
    }
}

struct EditProfilePage {
    let app: XCUIApplication

    var nameField: XCUIElement { app.textFields["editProfile_textField_name"] }
    var saveButton: XCUIElement { app.buttons["editProfile_button_save"] }

    func updateName(_ name: String) {
        nameField.tap()
        nameField.clearAndEnterText(name)
        saveButton.tap()
    }
}
```
