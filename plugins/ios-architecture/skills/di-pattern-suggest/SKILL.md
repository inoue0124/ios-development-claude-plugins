---
name: di-pattern-suggest
description: Dependency Injection パターンの提案を行う。コンストラクタ注入、Protocol による抽象化、DI コンテナの設計を支援。「DI」「依存注入」「初期化」「テスタビリティ」で自動適用。
---

# DI パターン提案

指定されたコードに対し、適切な Dependency Injection パターンを提案する。

## 検出と提案

### 1. 直接インスタンス化の検出

ViewModel や UseCase 内で具象クラスを直接生成している箇所を検出する。

```swift
// NG: 具象クラスに直接依存
class UserViewModel: ObservableObject {
    private let repository = UserRepository()
}

// OK: Protocol 経由でコンストラクタ注入
class UserViewModel: ObservableObject {
    private let repository: UserRepositoryProtocol
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
}
```

### 2. 提案する DI パターン

| パターン | 用途 | 推奨度 |
|---|---|---|
| コンストラクタ注入 | 必須依存の注入 | 最優先 |
| Protocol 抽象化 | テスタビリティの確保 | 必須 |
| Factory パターン | 動的な依存の生成 | 状況による |
| Environment 注入 | SwiftUI 環境値での共有 | View 層のみ |

### 3. テスタビリティの評価

- Protocol 経由で依存を注入できる設計になっているか
- モックの差し替えが容易か
- サイドエフェクト（ネットワーク、DB）が分離されているか

## 出力

```
## DI パターン提案: <ファイル名>

### 検出された直接依存
- <行番号>: <型名> を直接インスタンス化しています

### 推奨パターン
- コンストラクタ注入 + Protocol 抽象化の適用例を提示

### テスタビリティ評価: 高 / 中 / 低
```
