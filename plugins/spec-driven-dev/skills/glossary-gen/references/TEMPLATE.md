# 用語集テンプレート

以下のテンプレートに従って `docs/glossary.md` を生成する。

---

```markdown
# 用語集

> 生成日時: YYYY-MM-DD
> ステータス: Draft
> 入力: docs/ 配下の全ドキュメント

## 1. ドメイン用語

| 用語（日本語） | 用語（英語） | 定義 | コード上の命名 |
|---|---|---|---|
| 商品 | Product | 販売対象のアイテム | `Product`, `ProductRepository` |
| ユーザー | User | アプリの利用者 | `User`, `UserProfile` |
| 注文 | Order | 商品の購入リクエスト | `Order`, `OrderRepository` |

## 2. 技術用語

| 用語 | 定義（プロジェクトでの意味） | 参照 |
|---|---|---|
| ViewModel | 画面の状態管理とビジネスロジックを担う `@Observable` クラス | docs/architecture.md |
| Repository | データアクセスを抽象化する層。Protocol + 具象実装 | docs/architecture.md |
| EnvironmentKey | SwiftUI の DI メカニズム。`@Environment` で注入する | docs/architecture.md |
| Route | ナビゲーション先を表す `Hashable` enum | docs/architecture.md |

## 3. 略語

| 略語 | 正式名称 | 説明 |
|---|---|---|
| PRD | Product Requirements Document | プロダクト要求定義書 |
| DI | Dependency Injection | 依存注入 |
| MVVM | Model-View-ViewModel | アーキテクチャパターン |
| API | Application Programming Interface | 外部サービスとの通信インターフェース |

## 4. 命名マッピング

| ドメイン概念 | View | ViewModel | Repository | Model |
|---|---|---|---|---|
| 商品 | `ProductView` | `ProductViewModel` | `ProductRepository` | `Product` |
| ユーザー | `UserView` | `UserViewModel` | `UserRepository` | `User` |
| 注文 | `OrderView` | `OrderViewModel` | `OrderRepository` | `Order` |
```
