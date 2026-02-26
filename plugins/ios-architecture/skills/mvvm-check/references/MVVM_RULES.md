# MVVM ルール詳細（Swift 6.2 / SwiftUI）

## Observation フレームワーク（Swift 5.9+）

Swift 5.9 以降、`ObservableObject` + `@Published` に代わり `@Observable` マクロを使用する。

### 新旧対応表

| 旧（非推奨） | 新（推奨） | 備考 |
|---|---|---|
| `ObservableObject` | `@Observable` | クラスに付与するマクロ |
| `@Published var` | `var`（そのまま） | `@Observable` では不要 |
| `@StateObject` | `@State` | View でのオーナーシップ |
| `@ObservedObject` | 直接参照 or `@Bindable` | バインディングが必要なら `@Bindable` |
| `@EnvironmentObject` | `@Environment` | 環境値として注入 |

### ViewModel の正しい実装

```swift
// NG: レガシーパターン
class UserViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var isLoading: Bool = false
}

struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
}

// OK: Observation フレームワーク
@Observable
class UserViewModel {
    var name: String = ""
    var isLoading: Bool = false
}

struct UserView: View {
    @State private var viewModel = UserViewModel()
}
```

### バインディングが必要な場合

```swift
// @Bindable で双方向バインディングを作成
struct UserEditView: View {
    @Bindable var viewModel: UserViewModel

    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

### 環境値としての注入

```swift
// NG: @EnvironmentObject
struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
}

// OK: @Environment
struct ContentView: View {
    @Environment(AppSettings.self) private var settings
}
```

## View 層のルール

### 禁止パターン

```swift
// NG: View 内でビジネスロジック
struct UserView: View {
    var body: some View {
        // 計算ロジックが View に混在
        let displayName = user.firstName + " " + user.lastName
        let isEligible = user.age >= 18 && user.hasVerified
        Text(displayName)
    }
}

// OK: ViewModel に委譲
struct UserView: View {
    var viewModel: UserViewModel

    var body: some View {
        Text(viewModel.displayName)
    }
}
```

```swift
// NG: View が Repository に直接依存
struct UserView: View {
    let repository = UserRepository()
}

// OK: ViewModel 経由でアクセス
struct UserView: View {
    @State private var viewModel: UserViewModel

    init(viewModel: UserViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
}
```

### @State の使い分け

| 用途 | 適切か | 例 |
|---|---|---|
| UI 一時状態 | OK | `@State private var isSheetPresented = false` |
| ViewModel の保持 | OK | `@State private var viewModel = UserViewModel()` |
| ビジネスロジックの状態 | NG | `@State private var users: [User] = []` |

## ViewModel 層のルール

### import SwiftUI の禁止

```swift
// NG: SwiftUI に依存
import SwiftUI

@Observable
class UserViewModel {
    var color: Color = .blue  // SwiftUI の型に依存
}

// OK: Foundation のみ
import Foundation

@Observable
class UserViewModel {
    var colorHex: String = "#0000FF"
}
```

### 他の ViewModel への直接参照の禁止

```swift
// NG: ViewModel 間の直接参照
@Observable
class OrderViewModel {
    let userViewModel: UserViewModel  // 直接参照
}

// OK: 必要なデータのみ Protocol 経由で注入
@Observable
class OrderViewModel {
    let userProvider: UserProviding  // Protocol 経由
}
```

## Model 層のルール

- プレゼンテーションロジック（表示用文字列の生成、フォーマット等）を含まない
- View / ViewModel を import しない
- `Codable` / `Sendable` / `Equatable` 等の基本プロトコルのみに準拠する
