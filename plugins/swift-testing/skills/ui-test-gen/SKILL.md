---
name: ui-test-gen
description: SwiftUI 画面から UI テスト（XCUITest）を生成する。画面遷移・ユーザー操作・アクセシビリティ識別子を活用した UI テスト。「UI テスト」「XCUITest」「画面テスト」「E2E テスト」「アクセシビリティ」で自動適用。
---

# UI テスト生成

SwiftUI の View ファイルを解析し、XCUITest による UI テストコードを生成する。
UI テストパターンの詳細は → **references/UI_TEST_PATTERNS.md** を参照。

## ツール使用方針

- ファイル読み取りは xcodeproj-mcp-server の利用を優先する
- MCP が利用できない場合は Read / Grep ツールで直接ファイルを読み取る

## 生成するテスト

### 1. 画面要素の存在確認

View に含まれる UI コンポーネント（`Text`, `Button`, `TextField`, `List` 等）の存在を検証する。

```swift
import XCTest

final class UserProfileUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testProfileScreenElements() {
        // 画面遷移
        app.tabBars.buttons["Profile"].tap()

        // 要素の存在確認
        XCTAssertTrue(app.staticTexts["userName"].exists)
        XCTAssertTrue(app.buttons["editButton"].exists)
        XCTAssertTrue(app.images["profileImage"].exists)
    }
}
```

### 2. ユーザー操作のシナリオテスト

タップ・入力・スワイプなどのユーザー操作をシミュレートする。

```swift
func testEditUserName() {
    app.tabBars.buttons["Profile"].tap()
    app.buttons["editButton"].tap()

    let nameField = app.textFields["nameTextField"]
    nameField.tap()
    nameField.clearAndEnterText("New Name")
    app.buttons["saveButton"].tap()

    XCTAssertTrue(app.staticTexts["New Name"].waitForExistence(timeout: 5))
}
```

### 3. 画面遷移の検証

NavigationLink、Sheet、FullScreenCover による画面遷移を検証する。

### 4. エラー状態の検証

ネットワークエラー・バリデーションエラー時の UI 表示を検証する。

## アクセシビリティ識別子

UI テストの安定性のため、アクセシビリティ識別子の付与を推奨する。

```swift
// View 側での識別子付与
Text(viewModel.userName)
    .accessibilityIdentifier("userName")

Button("Edit") { ... }
    .accessibilityIdentifier("editButton")
```

対象 View にアクセシビリティ識別子が不足している場合は、追加を提案する。

## 生成手順

1. 対象の SwiftUI View ファイルを読み取る
2. View の構造（body 内のコンポーネント構成）を解析する
3. `NavigationLink`, `.sheet`, `.fullScreenCover` 等の画面遷移を特定する
4. `Button`, `TextField`, `Toggle` 等のインタラクティブ要素を特定する
5. アクセシビリティ識別子の有無を確認する
6. 画面要素・操作シナリオ・画面遷移・エラー状態のテストを生成する

## 出力

```
## UI テスト生成: <対象 View 名>

### アクセシビリティ識別子
- 既存: N 個
- 追加推奨: N 個
  - <コンポーネント> に `.accessibilityIdentifier("<識別子>")` を追加

### 生成されたテストケース: N 件
- 画面要素確認: N 件
- 操作シナリオ: N 件
- 画面遷移: N 件
- エラー状態: N 件

### テストコード
<XCUITest によるテストコード>
```

## テスト対象の特定

- 引数でファイルパスが指定された場合はそのファイルを対象にする
- 指定がない場合は `git diff` の変更ファイルから `*View.swift` / `*Screen.swift` を対象にする
