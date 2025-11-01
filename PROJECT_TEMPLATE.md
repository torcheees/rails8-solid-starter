# Rails 8 プロジェクトテンプレート - 構築ガイド

本プロジェクト（uptime-monitor-rails）のベストプラクティス、アーキテクチャパターン、開発環境設定を利用して、新規プロジェクトを構築するための完全ガイドです。

## 📋 目次

- [概要](#概要)
- [前提条件](#前提条件)
- [プロジェクト初期化](#プロジェクト初期化)
- [アーキテクチャ設定](#アーキテクチャ設定)
- [開発環境設定](#開発環境設定)
- [ドキュメント構成](#ドキュメント構成)
- [コーディング規約](#コーディング規約)
- [CI/CD設定](#cicd設定)
- [チェックリスト](#チェックリスト)

---

## 📖 概要

このテンプレートは以下の構成を提供します:

### 技術スタック
- **バックエンド**: Rails 8.0+ (Solid Stack)
- **データベース**: PostgreSQL 16+
- **フロントエンド**: Tailwind CSS 3 + Hotwire + React 18 (TypeScript)
- **テンプレート**: HAML (ERB禁止)
- **バックグラウンドジョブ**: Solid Queue (Redis不要)
- **認証**: Devise
- **認可**: Pundit
- **テスト**: RSpec + FactoryBot + WebMock
- **コード品質**: RuboCop + ESLint + HAML-Lint

### アーキテクチャパターン
- マルチテナンシー（Rails 8 Current attributes）
- サービス層パターン
- ポリシーベース認可
- Progressive Enhancement（Hotwire + React）

---

## 🔧 前提条件

### 必須ツール

```bash
# Ruby
asdf install ruby 3.2.2
asdf local ruby 3.2.2

# Node.js
asdf install nodejs 20.11.0
asdf local nodejs 20.11.0

# PostgreSQL
brew install postgresql@16

# pnpm (モノレポの場合)
npm install -g pnpm

# tmux (自動化スクリプト用)
brew install tmux
```

### 環境確認

```bash
ruby --version   # 3.2.2
node --version   # 20.11.0
psql --version   # PostgreSQL 16+
pnpm --version   # 9.0.0+
```

---

## 🚀 プロジェクト初期化

### 1. Rails プロジェクト作成

```bash
# 基本構成
rails new my-project \
  --database=postgresql \
  --css=tailwind \
  --javascript=esbuild \
  --skip-test \
  --skip-jbuilder

cd my-project
```

### 2. 本プロジェクトから設定ファイルをコピー

#### A. 基本設定ファイル

```bash
# uptime-monitor-rails のパスを設定
TEMPLATE_PROJECT="/path/to/uptime-monitor-rails"

# RuboCop設定
cp $TEMPLATE_PROJECT/.rubocop.yml .

# Git設定
cp $TEMPLATE_PROJECT/.gitignore .

# Environment設定
cp $TEMPLATE_PROJECT/web/.env.example .env.example

# EditorConfig
cp $TEMPLATE_PROJECT/.editorconfig .
```

#### B. CLAUDE.md のカスタマイズ

```bash
# CLAUDE.mdをコピーしてプロジェクト情報を更新
cp $TEMPLATE_PROJECT/CLAUDE.md .

# 以下を自分のプロジェクトに合わせて編集:
# - プロジェクト名
# - 技術スタック
# - データモデル
# - 特有のアーキテクチャ決定
```

#### C. ドキュメントディレクトリ構造

```bash
# ドキュメント構造をコピー
mkdir -p docs/{features,specs,api,db,closed}
mkdir -p .claude/commands

# READMEテンプレート
cp $TEMPLATE_PROJECT/README.md README.md
# プロジェクト情報を更新

# スクリプト
cp -r $TEMPLATE_PROJECT/scripts .
```

### 3. Gemfile 設定

#### 必須 Gem を追加

```ruby
# Gemfile

# Multi-tenancy (Rails 8 native approach)
# gem 'acts_as_tenant' # 不要 - Current attributes を使用

# Authorization
gem 'pundit'

# Authentication
gem 'devise'

# View Templates
gem 'haml-rails'

# Background Jobs (Solid Queue - Rails 8 included)
# Already included in Rails 8

# Testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end

group :test do
  gem 'webmock'
  gem 'vcr'
  gem 'simplecov', require: false
end

# Code Quality
group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'haml_lint', require: false
  gem 'brakeman', require: false
  gem 'bullet'
end

# API
gem 'jbuilder' # または削除して手動JSON構築

# CORS (API用)
gem 'rack-cors'

# Rate Limiting
gem 'rack-attack'

# Environment Variables
gem 'dotenv-rails', groups: [:development, :test]
```

#### インストール

```bash
bundle install
```

### 4. フロントエンド設定

#### package.json

```bash
# uptime-monitor-rails の package.json をベースにコピー
cp $TEMPLATE_PROJECT/package.json .

# 必要に応じてプロジェクト名などを変更
# 以下が含まれていることを確認:
# - esbuild
# - tailwindcss
# - typescript
# - eslint
# - react (必要に応じて)
```

#### インストール

```bash
npm install
# または pnpm install (モノレポの場合)
```

#### Tailwind CSS 設定

```bash
# Tailwind設定をコピー
cp $TEMPLATE_PROJECT/tailwind.config.js .
cp $TEMPLATE_PROJECT/app/assets/stylesheets/application.tailwind.css app/assets/stylesheets/
```

#### TypeScript 設定

```bash
# TypeScript設定をコピー
cp $TEMPLATE_PROJECT/tsconfig.json .
cp $TEMPLATE_PROJECT/.eslintrc.js .

# TypeScriptディレクトリ構造
mkdir -p app/javascript/{components,hooks,types}
```

---

## 🏗️ アーキテクチャ設定

### 1. マルチテナンシー（Rails 8 Native）

#### Current Attributes

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :organization, :organization_id, :user
end
```

#### ApplicationController

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_current_organization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_current_organization
    Current.organization = current_user&.current_organization
    Current.organization_id = Current.organization&.id
  end

  def user_not_authorized
    flash[:alert] = "権限がありません"
    redirect_to(request.referrer || root_path)
  end
end
```

#### ApplicationRecord

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # 自動的にorganization_idでスコープ
  default_scope -> { where(organization_id: Current.organization_id) if Current.organization_id }

  # グローバルスコープが必要な場合
  scope :unscoped_by_organization, -> { unscope(where: :organization_id) }
end
```

### 2. Pundit 認可

#### ApplicationPolicy

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record, :organization

  def initialize(user, record)
    @user = user
    @record = record
    @organization = Current.organization
  end

  def index?
    user_is_member?
  end

  def show?
    user_is_member? && record.organization_id == organization.id
  end

  def create?
    user_is_member?
  end

  def update?
    user_is_admin? && record.organization_id == organization.id
  end

  def destroy?
    user_is_admin? && record.organization_id == organization.id
  end

  private

  def user_is_member?
    user.present? && organization.present? && user.member_of?(organization)
  end

  def user_is_admin?
    user.present? && organization.present? &&
      (user.admin_of?(organization) || user.owner_of?(organization))
  end

  def user_is_owner?
    user.present? && organization.present? && user.owner_of?(organization)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
      @organization = Current.organization
    end

    def resolve
      if organization.present?
        scope.where(organization_id: organization.id)
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope, :organization
  end
end
```

#### Pundit 初期化

```bash
rails generate pundit:install
```

### 3. Solid Queue（Rails 8標準）

#### 設定

```yaml
# config/queue.yml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 5
      processes: 3
      polling_interval: 0.1

development:
  dispatchers:
    - polling_interval: 1
      batch_size: 100
  workers:
    - queues: "*"
      threads: 3
      processes: 1
      polling_interval: 1
```

#### ジョブの作成

```bash
rails generate job ExampleJob
```

```ruby
# app/jobs/example_job.rb
class ExampleJob < ApplicationJob
  queue_as :default

  def perform(organization_id, *args)
    # テナントコンテキスト設定
    Current.organization = Organization.find(organization_id)

    # 処理
  end
end
```

### 4. サービス層パターン

#### サービスクラスの基本構造

```ruby
# app/services/application_service.rb
class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs, &block).call
  end

  def call
    raise NotImplementedError
  end
end
```

#### サービス例

```ruby
# app/services/example_service.rb
class ExampleService < ApplicationService
  def initialize(resource, params)
    @resource = resource
    @params = params
    @organization = Current.organization
  end

  def call
    validate!
    execute
  end

  private

  attr_reader :resource, :params, :organization

  def validate!
    # バリデーション
  end

  def execute
    # メイン処理
  end
end
```

---

## 🧪 テスト環境設定

### 1. RSpec 初期化

```bash
rails generate rspec:install
```

### 2. spec/rails_helper.rb 設定

```ruby
# spec/rails_helper.rb

require 'spec_helper'
require 'database_cleaner/active_record'

# SimpleCov
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
end

RSpec.configure do |config|
  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Pundit matchers
  config.include Pundit::RSpec::Matchers

  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  # カスタムヘルパー
  config.before(:each) do
    # テナントコンテキストのリセット
    Current.reset
  end
end
```

### 3. FactoryBot 設定

```ruby
# spec/factories/organizations.rb
FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    subdomain { Faker::Internet.domain_word }
  end
end

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }

    trait :with_organization do
      after(:create) do |user|
        organization = create(:organization)
        create(:membership, user: user, organization: organization, role: 'owner')
      end
    end
  end
end
```

### 4. テストヘルパー

```ruby
# spec/support/authentication_helper.rb
module AuthenticationHelper
  def sign_in_as(user, organization: nil)
    sign_in user
    org = organization || user.organizations.first
    Current.organization = org
    Current.user = user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper
end
```

---

## 📁 ドキュメント構成

### ディレクトリ構造

```
docs/
├── features/           # 機能仕様・実装計画
│   ├── example-feature.md
│   └── example-feature-spec.md
├── specs/              # 詳細な技術仕様
├── api/                # API仕様書
│   └── v1/
│       └── endpoints.md
├── db/                 # データベース設計
│   ├── schema.md
│   └── erd.md
└── closed/             # 完了したドキュメント（アーカイブ）

.claude/
└── commands/           # Claude Code slash commands
    └── create-spec.md
```

### ドキュメントテンプレート

#### 機能仕様テンプレート

```bash
# 本プロジェクトからコピー
cp $TEMPLATE_PROJECT/docs/features/TEMPLATE.md docs/features/
```

#### CLAUDE.md のカスタマイズ

`CLAUDE.md` を自分のプロジェクトに合わせて更新:

1. プロジェクト概要
2. 技術スタック
3. データモデル関係
4. 重要なアーキテクチャ決定
5. 開発フロー
6. コーディング規約

---

## 📐 コーディング規約

### Ruby / Rails

#### .rubocop.yml

```bash
# 本プロジェクトの設定をコピー
cp $TEMPLATE_PROJECT/.rubocop.yml .
```

主要な設定:
- インデント: 2スペース
- 行の長さ: 120文字
- メソッドの長さ: 25行以下
- クラスの長さ: 250行以下
- Rails規約に準拠

#### 実行コマンド

```bash
# チェック
bundle exec rubocop

# 自動修正
bundle exec rubocop -A
```

### HAML

#### .haml-lint.yml

```bash
cp $TEMPLATE_PROJECT/.haml-lint.yml .
```

#### ルール
- インデント: 2スペース
- ERB禁止（全てHAML）
- Tailwind CSSクラスのみ使用

```bash
# チェック
bundle exec haml-lint app/views
```

### JavaScript / TypeScript

#### .eslintrc.js

```bash
cp $TEMPLATE_PROJECT/.eslintrc.js .
```

#### ルール
- 全てTypeScript（JavaScript禁止）
- `any`型禁止
- React Hooks ルール準拠

```bash
# チェック
npm run lint:js

# 自動修正
npm run lint:js:fix

# 型チェック
npx tsc --noEmit
```

### Tailwind CSS

#### ルール
1. **カスタムCSS禁止** - Tailwindユーティリティクラスのみ
2. **色パレット統一** - gray, blue, green, red の定義済みカラー
3. **レスポンシブ** - sm:, md:, lg:, xl: 修飾子の活用

```bash
# ビルド
npm run build:css
```

---

## 🔄 Makefile設定

本プロジェクトのMakefileをコピー:

```bash
# web/Makefile をコピー
cp $TEMPLATE_PROJECT/web/Makefile .
```

### 主要コマンド

```bash
# セットアップ
make setup

# 開発サーバー起動
make dev

# テスト
make test
make test-fast
make test-file FILE=spec/models/user_spec.rb

# Lint
make lint
make fix

# データベース
make db-migrate
make db-rollback
make db-reset

# I18n
make i18n-health
make i18n-missing
make i18n-normalize
```

---

## 🤖 自動化スクリプト

### Claude Code 自動応答システム

```bash
# scripts/ ディレクトリをコピー
cp -r $TEMPLATE_PROJECT/scripts .
```

#### 使い方

```bash
# 完全自動実装
./scripts/claude-auto.sh --auto

# デバッグモード
./scripts/claude-auto.sh --auto --debug
```

詳細: `scripts/README.md` 参照

---

## 🌐 国際化 (i18n)

### 設定

```ruby
# config/application.rb
config.i18n.available_locales = [:en, :ja]
config.i18n.default_locale = :ja
```

### ディレクトリ構造

```
config/locales/
├── en.yml
├── ja.yml
├── models/
│   ├── en.yml
│   └── ja.yml
├── views/
│   ├── en.yml
│   └── ja.yml
└── controllers/
    ├── en.yml
    └── ja.yml
```

### i18n-tasks

```ruby
# Gemfile
gem 'i18n-tasks'
```

```bash
# チェック
bundle exec i18n-tasks health

# 使われていないキー検出
bundle exec i18n-tasks unused

# 不足しているキー検出
bundle exec i18n-tasks missing

# 正規化
bundle exec i18n-tasks normalize
```

---

## 🚢 CI/CD設定

### GitHub Actions

```bash
# .github/workflows/ をコピー
mkdir -p .github/workflows
cp $TEMPLATE_PROJECT/.github/workflows/* .github/workflows/
```

#### ワークフロー
- `ci.yml` - Lint + Test
- `deploy.yml` - デプロイ
- `security.yml` - Brakeman セキュリティスキャン

### Heroku設定

```bash
# Procfile
cp $TEMPLATE_PROJECT/Procfile .

# app.json
cp $TEMPLATE_PROJECT/app.json .
```

---

## ✅ 初期セットアップチェックリスト

### 環境構築
- [ ] Ruby 3.2.2 インストール
- [ ] Node.js 20+ インストール
- [ ] PostgreSQL 16+ インストール
- [ ] pnpm インストール（モノレポの場合）
- [ ] tmux インストール

### プロジェクト初期化
- [ ] Rails プロジェクト作成
- [ ] Git初期化 (`git init`)
- [ ] `.gitignore` コピー
- [ ] `.env.example` コピー → `.env` 作成

### 設定ファイル
- [ ] `Gemfile` 更新（必須Gem追加）
- [ ] `package.json` コピー・更新
- [ ] `.rubocop.yml` コピー
- [ ] `.eslintrc.js` コピー
- [ ] `.haml-lint.yml` コピー
- [ ] `tailwind.config.js` コピー
- [ ] `tsconfig.json` コピー
- [ ] `Makefile` コピー

### ドキュメント
- [ ] `CLAUDE.md` コピー・カスタマイズ
- [ ] `README.md` コピー・カスタマイズ
- [ ] `docs/` ディレクトリ構造作成
- [ ] `.claude/commands/` コピー

### アーキテクチャ
- [ ] `Current` attributes 設定
- [ ] `ApplicationController` 更新
- [ ] `ApplicationRecord` 更新
- [ ] `ApplicationPolicy` 作成
- [ ] Pundit初期化

### テスト
- [ ] RSpec初期化
- [ ] `spec/rails_helper.rb` 設定
- [ ] FactoryBot設定
- [ ] テストヘルパー作成

### フロントエンド
- [ ] Tailwind CSS設定
- [ ] TypeScriptディレクトリ構造
- [ ] React設定（必要に応じて）

### 自動化
- [ ] `scripts/` ディレクトリコピー
- [ ] 自動化スクリプト実行権限付与

### CI/CD
- [ ] GitHub Actions設定
- [ ] Heroku設定（必要に応じて）

### 動作確認
- [ ] `bundle install` 成功
- [ ] `npm install` 成功
- [ ] `bundle exec rubocop` 通過
- [ ] `npm run build` 成功
- [ ] `rails db:create` 成功
- [ ] `rails db:migrate` 成功
- [ ] `bundle exec rspec` 成功（初期状態）
- [ ] `rails server` 起動成功

---

## 📚 次のステップ

1. **データモデル設計**
   - ERD作成
   - マイグレーション作成
   - モデル実装

2. **認証・認可実装**
   - Devise設定
   - User/Organization/Membership モデル
   - Punditポリシー

3. **基本機能実装**
   - CRUD操作
   - テスト作成
   - ビュー作成（HAML + Tailwind）

4. **API実装**（必要に応じて）
   - API v1 エンドポイント
   - JWT認証
   - APIドキュメント

5. **デプロイ**
   - 環境変数設定
   - データベースセットアップ
   - デプロイ実行

---

## 🔗 参考リンク

- [Rails 8 Guides](https://guides.rubyonrails.org/)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Pundit](https://github.com/varvet/pundit)
- [Tailwind CSS](https://tailwindcss.com/)
- [HAML](https://haml.info/)
- [RSpec](https://rspec.info/)

---

## 💡 ヒント

### マルチテナンシー
- 全てのモデルに `organization_id` を追加
- `ApplicationRecord` の `default_scope` でスコープ
- コントローラーで `Current.organization` を設定

### セキュリティ
- OWASP Top 10 に準拠
- Punditで細かい権限制御
- Rack::Attack でレート制限

### パフォーマンス
- 複合インデックスを適切に配置
- Bullet gem で N+1 検出
- Solid Cache で効率的なキャッシング

### コード品質
- RuboCop 0 offenses
- RSpec 90%以上のカバレッジ
- 全てのPRでLint/Test実行

---

**このテンプレートで、本プロジェクトのベストプラクティスを完全に継承した新規プロジェクトを構築できます！** 🎉
