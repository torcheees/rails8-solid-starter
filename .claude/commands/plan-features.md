# 実装計画作成コマンド

要件定義書（`docs/REQUIREMENTS.md`）から、実装可能な機能単位の計画書を作成します。

## 前提条件

`docs/REQUIREMENTS.md` が存在すること。存在しない場合は `/define-requirements` コマンドを先に実行してください。

## 実行手順

### ステップ1: 要件定義書を読み込む

`docs/REQUIREMENTS.md` を読み込み、以下を抽出:
- Must have機能（MVP）
- Should have機能
- データモデル
- 画面設計

### ステップ2: 機能を実装単位に分割

大きな機能を、**1-2週間で実装できる単位**に分割します。

**分割の基準:**
- 1つのPull Requestで完結する
- 独立してテスト可能
- 他の機能に依存しすぎない
- データベースマイグレーションが含まれる場合は優先度を上げる

**例: 「タスク管理機能」を分割**
```
❌ 悪い例（大きすぎる）:
- タスク管理機能

✅ 良い例（適切な粒度）:
1. ユーザー認証（Devise導入）
2. Organization/Membershipモデル（マルチテナンシー）
3. Taskモデルの基本CRUD
4. タスク一覧画面（フィルタ・検索なし）
5. タスク詳細画面（コメントなし）
6. タスク検索・フィルタ機能
7. コメント機能
```

### ステップ3: 実装順序の決定

以下の優先順位で並び替え:

1. **基盤機能**（認証、マルチテナンシー、基本モデル）
2. **コア機能**（MVPに必要な機能）
3. **拡張機能**（Should have）
4. **補助機能**（Could have）

**依存関係を考慮:**
- Taskモデルは、Userモデルの後
- コメント機能は、Taskモデルの後
- 通知機能は、基本的なCRUDの後

### ステップ4: 各機能の実装計画書を作成

各機能について、`docs/features/` 配下に以下の形式で作成:

**ファイル名:** `docs/features/01-user-authentication.md`

```markdown
# ユーザー認証機能

## 概要

Deviseを使用したユーザー登録・ログイン機能を実装する。

## 目的

- ユーザーがアカウントを作成できる
- メールアドレスとパスワードでログインできる
- ログアウトできる

## 前提条件

- なし（初期機能）

## 実装内容

### 1. Deviseのセットアップ

- [ ] Deviseのインストール
- [ ] Userモデルの生成
- [ ] マイグレーションの実行
- [ ] Deviseビューの生成（HAML変換）

### 2. Userモデルの実装

**属性:**
- `email` (string, null: false, unique: true)
- `encrypted_password` (string, null: false)
- `name` (string)
- `created_at` (datetime)
- `updated_at` (datetime)

**バリデーション:**
- email: 必須、一意、メール形式
- name: 最大100文字

**関連:**
- `has_many :memberships`
- `has_many :organizations, through: :memberships`

### 3. ルーティング

\`\`\`ruby
# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root 'dashboard#index'
end
\`\`\`

### 4. ビュー実装

**必要な画面:**
- [ ] サインアップ画面 (app/views/devise/registrations/new.html.haml)
- [ ] ログイン画面 (app/views/devise/sessions/new.html.haml)
- [ ] プロフィール編集画面 (app/views/devise/registrations/edit.html.haml)

**デザイン:**
- Tailwind CSSを使用
- レスポンシブデザイン
- エラーメッセージの表示

### 5. コントローラー

\`\`\`ruby
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
\`\`\`

### 6. テスト

**必要なテスト:**
- [ ] Userモデルのバリデーションテスト
- [ ] ユーザー登録のリクエストテスト
- [ ] ログインのリクエストテスト
- [ ] ログアウトのリクエストテスト

**テストシナリオ:**
\`\`\`ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'associations' do
    it { should have_many(:memberships) }
    it { should have_many(:organizations).through(:memberships) }
  end
end
\`\`\`

### 7. セキュリティ

- [ ] CSRF対策（Railsデフォルト）
- [ ] パスワードの暗号化（Devise）
- [ ] セッション管理（secure cookie）
- [ ] ブルートフォース対策（Rack::Attack）

### 8. i18n対応

**必要な翻訳:**
- [ ] devise.ja.yml（devise-i18n gemを使用）
- [ ] カスタムメッセージの翻訳

## API仕様（モバイル用）

### POST /api/v1/auth/signup

**リクエスト:**
\`\`\`json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "name": "山田太郎"
  }
}
\`\`\`

**レスポンス（成功）:**
\`\`\`json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎"
  }
}
\`\`\`

### POST /api/v1/auth/login

**リクエスト:**
\`\`\`json
{
  "email": "user@example.com",
  "password": "password123"
}
\`\`\`

**レスポンス（成功）:**
\`\`\`json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎"
  },
  "organizations": [...]
}
\`\`\`

## 完了条件

- [ ] すべてのチェックリストが完了
- [ ] テストが全て成功（RSpec）
- [ ] Linterが全て成功（RuboCop, HAML-Lint）
- [ ] モバイルアプリからログイン可能

## 見積もり

**工数:** 3-5日

**内訳:**
- Deviseセットアップ: 0.5日
- モデル実装: 0.5日
- ビュー実装: 1-2日
- API実装: 0.5-1日
- テスト: 0.5-1日

## 参考資料

- [Devise Wiki](https://github.com/heartcombo/devise/wiki)
- [devise-i18n](https://github.com/tigrish/devise-i18n)
- [テンプレート](../../templates/)

## 次のステップ

完了後:
1. `/create-spec` コマンドで詳細仕様書を作成
2. 実装開始
3. 完了したら `docs/closed/` に移動
\`\`\`

### ステップ5: 実装計画一覧の作成

`docs/features/README.md` に全体の実装計画一覧を作成:

```markdown
# 実装計画一覧

## 進捗サマリー

- **全機能数:** 15
- **完了:** 0
- **進行中:** 0
- **未着手:** 15

## フェーズ1: 基盤機能（MVP）

### 認証・認可
- [ ] [01. ユーザー認証](01-user-authentication.md) - 未着手
- [ ] [02. マルチテナンシー](02-multi-tenancy.md) - 未着手
- [ ] [03. Pundit認可](03-pundit-authorization.md) - 未着手

### コア機能
- [ ] [04. タスクモデル](04-task-model.md) - 未着手
- [ ] [05. タスク一覧画面](05-task-list.md) - 未着手
- [ ] [06. タスク詳細画面](06-task-detail.md) - 未着手

## フェーズ2: 拡張機能

### 検索・フィルタ
- [ ] [07. タスク検索機能](07-task-search.md) - 未着手
- [ ] [08. フィルタ機能](08-task-filter.md) - 未着手

### コミュニケーション
- [ ] [09. コメント機能](09-comments.md) - 未着手
- [ ] [10. 通知機能](10-notifications.md) - 未着手

## 実装順序

1. 01 → 02 → 03 （基盤）
2. 04 → 05 → 06 （コア機能）
3. 07 → 08 （検索）
4. 09 → 10 （拡張）

## 依存関係

```
01-user-authentication
  ├─ 02-multi-tenancy
  │   ├─ 03-pundit-authorization
  │   └─ 04-task-model
  │       ├─ 05-task-list
  │       ├─ 06-task-detail
  │       ├─ 07-task-search
  │       ├─ 08-task-filter
  │       └─ 09-comments
  │           └─ 10-notifications
```
\`\`\`

## 出力形式

1. 各機能の計画書を `docs/features/XX-feature-name.md` に保存
2. 実装計画一覧を `docs/features/README.md` に保存

## 完了メッセージ

```
✅ 実装計画を作成しました

📁 保存場所: docs/features/

📋 作成された計画書:
  - docs/features/README.md (一覧)
  - docs/features/01-user-authentication.md
  - docs/features/02-multi-tenancy.md
  - docs/features/03-pundit-authorization.md
  ... (合計 XX 個)

🎯 次のステップ:

1. **計画をレビュー**
   cat docs/features/README.md

2. **最初の機能から実装開始**
   /create-spec docs/features/01-user-authentication.md

3. **自動化スクリプトで開発**
   ./scripts/claude-auto.sh auto

💡 Tips:
- 実装順序を守ることで依存関係の問題を回避できます
- 各機能の実装後は必ずテストを通してください
- 完了した計画書は docs/closed/ に移動してください
```

## 注意事項

- 機能は **小さく分割** すること（1-2週間で完了する粒度）
- 依存関係を明確にすること
- API仕様も含めること（モバイルアプリとの連携のため）
- テスト要件を明記すること
- 見積もりは現実的に（過小評価しない）
- 各機能は独立してテスト可能であること
