# SwiftUI View パターン集（Swift 6.2）

## 基本パターン

### ViewModel 注入パターン

```swift
import SwiftUI

struct UserProfileView: View {
    @State private var viewModel: UserProfileViewModel

    init(viewModel: UserProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Text(viewModel.displayName)
    }
}
```

### Environment 注入パターン

```swift
import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Toggle("Dark Mode", isOn: settings.isDarkMode)
    }
}
```

### @Bindable パターン（子 View で双方向バインディング）

```swift
import SwiftUI

struct UserEditView: View {
    @Bindable var viewModel: UserProfileViewModel

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            TextField("Email", text: $viewModel.email)
        }
    }
}
```

## ローディング・エラーハンドリング

### 標準パターン

```swift
struct ContentLoadingView: View {
    @State private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                contentView
            }
        }
        .task {
            await viewModel.fetch()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        // メインコンテンツ
    }
}
```

## ナビゲーションパターン

### NavigationStack + NavigationLink

```swift
struct ItemListView: View {
    @State private var viewModel: ItemListViewModel

    init(viewModel: ItemListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                NavigationLink(value: item) {
                    ItemRowView(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(
                    viewModel: ItemDetailViewModel(item: item)
                )
            }
        }
    }
}
```

## レガシーパターンとの対照

| 旧（使わない） | 新（使う） |
|---|---|
| `@StateObject private var vm = VM()` | `@State private var vm: VM` + init |
| `@ObservedObject var vm: VM` | `var vm: VM` or `@Bindable var vm: VM` |
| `@EnvironmentObject var settings: Settings` | `@Environment(Settings.self) private var settings` |
| `struct Preview: PreviewProvider { ... }` | `#Preview { ... }` |

## UI 状態の @State（ViewModel ではなく View ローカル状態）

```swift
struct ExampleView: View {
    @State private var viewModel: ExampleViewModel
    // UI 一時状態は @State でそのまま保持して良い
    @State private var isSheetPresented = false
    @State private var searchText = ""

    init(viewModel: ExampleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.filteredItems(searchText: searchText)) { item in
            Text(item.name)
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $isSheetPresented) {
            DetailSheet()
        }
    }
}
```
