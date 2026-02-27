# spec-driven-dev — スペック駆動開発ワークフロー

アイディアから体系的なプロジェクトスペックへ段階的に落とし込むスペック駆動開発ワークフロー。
PRD・機能設計・アーキテクチャ・リポジトリ構造・開発ガイドライン・用語集を `docs/` 配下に生成する。

## スキル一覧

| 種別 | 名前 | 内容 |
|---|---|---|
| skill | prd-writing | `docs/ideas/` を元にプロダクト要求定義書を作成（ユーザー承認あり） |
| skill | functional-design | PRD を元に機能設計書を作成 |
| skill | architecture-design | 既存ドキュメントを元にアーキテクチャ設計書を作成 |
| skill | repository-structure | 既存ドキュメントを元にリポジトリ構造定義書を作成 |
| skill | development-guidelines | 既存ドキュメントを元に開発ガイドラインを作成 |
| skill | glossary-gen | 全ドキュメントから用語を抽出し用語集を作成 |
| skill (manual) | spec-driven-workflow | 上記 6 スキルを順番に実行する一気通貫ワークフロー |

## ワークフロー

```
docs/ideas/ (入力)
    │
    ▼
Step 1: /prd-writing ──→ docs/product-requirements.md（ユーザー承認）
    ▼
Step 2: /functional-design ──→ docs/functional-design.md
    ▼
Step 3: /architecture-design ──→ docs/architecture.md
    ▼
Step 4: /repository-structure ──→ docs/repository-structure.md
    ▼
Step 5: /development-guidelines ──→ docs/development-guidelines.md
    ▼
Step 6: /glossary-gen ──→ docs/glossary.md
    ▼
Feature 実装へ（/implement-feature）
```
