# Rails 8 Solid Starter

**Production-ready Rails 8 + React Native monorepo with best practices and modern tooling**

このスターターキットは、実践的なSaaSアプリケーション開発で培ったベストプラクティスを詰め込んだRails 8 + React Nativeモノレポテンプレートです。

## 🎯 What's Included

### Core Stack
- **Ruby 3.2.2** + **Rails 8.0** (Solid Stack)
- **PostgreSQL** - Production-grade database
- **Solid Queue** - Database-backed background jobs (no Redis needed)
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed WebSockets

### Frontend (Web)
- **Tailwind CSS 3** - Utility-first CSS framework
- **Hotwire** (Turbo + Stimulus) - Modern frontend without JavaScript bloat
- **React 18 + TypeScript** - For complex interactive widgets
- **HAML** - Clean, maintainable view templates
- **esbuild** - Lightning-fast JavaScript bundling

### Mobile
- **React Native 0.81.5** + **Expo SDK 54** - Cross-platform mobile development
- **Expo Router** - File-based routing for React Native
- **NativeWind** - Tailwind CSS for React Native
- **Zustand** - Lightweight state management
- **React Query** - Data fetching and caching
- **@myapp/shared** - Shared TypeScript package with web

### Architecture Patterns
- **Rails 8 Native Multi-tenancy** - Using `Current` attributes (no gems)
- **Pundit Authorization** - Policy-based RBAC
- **Service Layer Pattern** - Clean separation of business logic
- **Monorepo Structure** - pnpm workspaces (web + mobile + shared)
- **Type-safe API** - Shared TypeScript types between web and mobile

### Testing & Quality
- **RSpec** - Behavior-driven testing
- **FactoryBot** - Test data factories
- **SimpleCov** - Code coverage tracking
- **RuboCop** - Ruby style enforcement
- **HAML-Lint** - HAML template linting
- **ESLint** - JavaScript/TypeScript linting
- **TypeScript** - Type-safe frontend code

### Developer Experience
- **Makefile** - 40+ common development commands
- **Claude Code Integration** - AI-assisted development with `/create-spec` command
- **Automation Scripts** - Auto-response and workflow automation
- **i18n Ready** - English + Japanese translations with i18n-tasks

## 📁 What's in This Starter Kit

```
rails8-solid-starter/
├── README.md                    # This file
├── PROJECT_TEMPLATE.md          # Complete setup guide (650+ lines)
├── MONOREPO.md                  # Monorepo structure guide ⭐ NEW
├── CLAUDE.md                    # AI assistant instructions
├── pnpm-workspace.yaml          # Workspace configuration ⭐ NEW
├── web/                         # Rails 8 application
│   └── package.json.example     # Web frontend dependencies
├── mobile/                      # React Native + Expo ⭐ NEW
│   ├── app/                     # Expo Router screens
│   │   ├── (auth)/             # Auth screens
│   │   ├── (tabs)/             # Main app tabs
│   │   └── _layout.tsx         # Root layout
│   ├── src/
│   │   ├── components/
│   │   ├── hooks/
│   │   └── store/              # Zustand stores
│   ├── package.json
│   └── app.json                # Expo configuration
├── packages/                    # Shared packages ⭐ NEW
│   └── shared/                  # Shared TypeScript code
│       ├── src/
│       │   ├── api/            # API clients
│       │   ├── types/          # TypeScript types
│       │   └── validators/     # Zod schemas
│       └── package.json
├── .rubocop.yml                 # Ruby style configuration
├── .haml-lint.yml              # HAML linting configuration
├── eslint.config.mjs           # JavaScript/TypeScript linting
├── tsconfig.json               # TypeScript configuration
├── tailwind.config.js          # Tailwind CSS configuration
├── .claude/
│   └── commands/
│       └── create-spec.md      # Specification generation command
└── scripts/
    ├── claude_auto.py          # Claude Code automation (Python)
    ├── claude-auto.sh          # Shell wrapper with presets
    └── README.md               # Scripts documentation
```

## 🚀 Quick Start

### Prerequisites

必須要件:
- **Ruby 3.2.2** (asdfまたはrbenvで管理)
- **Node.js 20+** + **pnpm 9.0.0**
- **PostgreSQL 16+**
- **Git**

オプション:
- **tmux** (Claude Code自動化に必要)

### 1. 新規プロジェクトを作成

```bash
# 新しいRailsプロジェクトを作成
rails new myapp \
  --database=postgresql \
  --css=tailwind \
  --javascript=esbuild \
  --skip-test \
  --skip-jbuilder

cd myapp
```

### 2. スターターキットの設定をコピー

```bash
# このスターターキットのディレクトリから
STARTER_KIT_DIR="/Users/akimitsukoshikawa/workspace/torcheees/rails8-solid-starter"
PROJECT_DIR="."  # 新しいプロジェクトのディレクトリ

# 設定ファイルをコピー
cp $STARTER_KIT_DIR/.rubocop.yml $PROJECT_DIR/
cp $STARTER_KIT_DIR/.haml-lint.yml $PROJECT_DIR/
cp $STARTER_KIT_DIR/eslint.config.mjs $PROJECT_DIR/
cp $STARTER_KIT_DIR/tsconfig.json $PROJECT_DIR/
cp $STARTER_KIT_DIR/tailwind.config.js $PROJECT_DIR/

# ドキュメントをコピー
cp $STARTER_KIT_DIR/CLAUDE.md $PROJECT_DIR/
cp $STARTER_KIT_DIR/PROJECT_TEMPLATE.md $PROJECT_DIR/docs/

# スクリプトとコマンドをコピー
cp -r $STARTER_KIT_DIR/scripts $PROJECT_DIR/
cp -r $STARTER_KIT_DIR/.claude $PROJECT_DIR/

# ディレクトリ構造を作成
mkdir -p $PROJECT_DIR/docs/{features,specs,closed}
mkdir -p $PROJECT_DIR/.github/workflows
```

### 3. Gemfileにベストプラクティスの依存関係を追加

`PROJECT_TEMPLATE.md`の「ステップ3: Gemfileの設定」を参照してください。

主要なGem:
- **devise** - 認証
- **pundit** - 認可
- **acts_as_tenant** または Rails 8 `Current`属性でマルチテナント
- **haml-rails** - HAMLテンプレート
- **rspec-rails** - テスト
- **factory_bot_rails** - テストデータ
- **simplecov** - カバレッジ
- **rubocop** - Linter

```bash
bundle install
```

### 4. データベースとSolid Queueのセットアップ

```bash
# データベース作成
bin/rails db:create

# Solid Queueインストール
bin/rails solid_queue:install

# マイグレーション実行
bin/rails db:migrate
```

### 5. pnpmモノレポ構造のセットアップ

```bash
# pnpmをインストール（まだの場合）
npm install -g pnpm@9.0.0

# pnpm workspacesを初期化
cat > pnpm-workspace.yaml <<EOF
packages:
  - 'web'
  - 'mobile'
  - 'packages/*'
EOF

# package.jsonをプロジェクトルートに作成
# （詳細はPROJECT_TEMPLATE.mdを参照）

# 依存関係をインストール
pnpm install
```

### 6. アプリケーションを起動

```bash
# 開発サーバー起動（Rails + Solid Queue + アセットウォッチング）
bin/dev
```

ブラウザで http://localhost:3000 を開く

## 📖 Detailed Setup Guide

完全なセットアップ手順は `PROJECT_TEMPLATE.md` を参照してください:

- ✅ 50+項目の詳細チェックリスト
- ✅ マルチテナンシーの実装手順
- ✅ Pundit認可の設定
- ✅ Solid Queueジョブの設定
- ✅ サービスレイヤーパターン
- ✅ RSpec + FactoryBotテスト環境
- ✅ i18n多言語化設定
- ✅ CI/CDパイプライン (GitHub Actions)
- ✅ 本番環境デプロイガイド

## 🛠️ Development Workflow

### コード品質チェック（必須）

コード変更後、**必ず**以下のチェックを実行してください:

```bash
# Rubyスタイルチェック
bundle exec rubocop

# テスト実行
bundle exec rspec

# HAMLテンプレートチェック
bundle exec haml-lint app/views

# JavaScript/TypeScriptチェック
npm run lint:js

# TypeScript型チェック
npx tsc --noEmit

# ビルド確認
npm run build
```

**期待される結果:**
- RuboCop: 0 offenses
- RSpec: 全テスト成功
- HAML-Lint: 0 lints
- ESLint: 0 errors (warnings OK)
- TypeScript: 出力なし（成功）
- Build: 全アセットのコンパイル成功

### Makefileコマンド

`Makefile` を作成すると、開発が効率化されます（例は `PROJECT_TEMPLATE.md` 参照）:

```bash
make setup           # 初回セットアップ
make dev             # 開発サーバー起動
make test            # 全テスト実行
make lint            # 全リンター実行
make fix             # 自動修正
```

### Claude Code Automation

**自動化スクリプト** を使うと、Claude Codeが自動的に開発タスクを処理します:

```bash
# Python版（推奨）
python3 scripts/claude_auto.py

# シェル版（プリセット付き）
./scripts/claude-auto.sh auto       # 自動モード
./scripts/claude-auto.sh aggressive # アグレッシブモード
./scripts/claude-auto.sh balanced   # バランスモード
```

詳細は `scripts/README.md` を参照。

## 🎨 Design System

### Tailwind CSS Only

このスターターキットでは **Tailwind CSSのみ** を使用します:

✅ **DO:**
- Tailwindユーティリティクラスを使う: `bg-blue-600`, `hover:bg-blue-700`
- レスポンシブ修飾子を使う: `sm:`, `md:`, `lg:`, `xl:`
- 一貫したカラーパレットを使う

❌ **DON'T:**
- カスタムCSSクラスを書かない
- インラインスタイルを使わない（メールテンプレート除く）
- 新しいCSSファイルを作らない

### HAML Templates Only

すべてのビューテンプレートは **HAML** で記述します:

```haml
.container
  %h1.text-2xl.font-bold.text-gray-900 Welcome
  = link_to "Sign Up", signup_path, class: "btn-primary"
  - if user.admin?
    %p.text-sm.text-gray-500 Admin Panel
```

### TypeScript Only

すべてのJavaScriptファイルは **TypeScript** (.ts/.tsx) で記述します。

## 📝 Slash Commands

Claude Codeで使える便利なスラッシュコマンド:

### `/create-spec` - 仕様書作成

`docs/features/` の実装計画から詳細な仕様書を生成します。

```
/create-spec docs/features/user-authentication.md
/create-spec docs/features/api-endpoints.md --focus=security
```

仕様書には以下が含まれます:
- データモデル設計
- APIエンドポイント定義
- セキュリティ要件（OWASP Top 10準拠）
- パフォーマンス要件
- テスト要件
- i18n対応

## 🏗️ Architecture Patterns

### 1. Multi-Tenancy (Rails 8 Native)

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :organization, :organization_id, :user
end

# Controllers
Current.organization = current_user.current_organization

# Models (automatic scoping)
class Monitor < ApplicationRecord
  belongs_to :organization
  default_scope { where(organization_id: Current.organization_id) }
end
```

### 2. Pundit Authorization

```ruby
# app/policies/monitor_policy.rb
class MonitorPolicy < ApplicationPolicy
  def create?
    user_is_member? && organization.within_quota?(:monitors)
  end

  def update?
    user_is_admin? || record.user == user
  end
end

# Controllers
authorize @monitor
@monitors = policy_scope(Monitor)
```

### 3. Service Layer

```ruby
# app/services/notification_service.rb
class NotificationService
  def initialize(channel, resource)
    @channel = channel
    @resource = resource
  end

  def send
    notifier = case @channel.channel_type
    when 'email' then EmailNotifier.new(@channel, @resource)
    when 'slack' then SlackNotifier.new(@channel, @resource)
    end

    notifier.send
  end
end
```

### 4. Solid Queue Jobs

```ruby
# app/jobs/notification_job.rb
class NotificationJob < ApplicationJob
  queue_as :default

  def perform(channel_id, resource_id)
    Current.organization = Channel.find(channel_id).organization

    channel = Channel.find(channel_id)
    resource = Resource.find(resource_id)

    NotificationService.new(channel, resource).send
  end
end

# Usage
NotificationJob.perform_later(channel.id, resource.id)
```

## 🧪 Testing Standards

### RSpec Test Structure

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:memberships) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
  end

  describe '#admin_of?' do
    let(:user) { create(:user) }
    let(:org) { create(:organization) }

    it 'returns true when user is admin' do
      create(:membership, user: user, organization: org, role: 'admin')
      expect(user.admin_of?(org)).to be true
    end
  end
end
```

### Test Coverage Requirements

- **Models**: 90%+ coverage
- **Controllers**: 80%+ coverage
- **Services**: 90%+ coverage
- **Policies**: 100% coverage

```bash
# カバレッジ確認
COVERAGE=true bundle exec rspec
open coverage/index.html
```

## 🌍 Internationalization (i18n)

### Translation Management

```bash
# 翻訳の健全性チェック
bundle exec i18n-tasks health

# 不足している翻訳を検出
bundle exec i18n-tasks missing

# 未使用の翻訳を検出
bundle exec i18n-tasks unused

# YAMLを正規化
bundle exec i18n-tasks normalize
```

### Usage in Code

```haml
-# Views
%h1= t('landing.hero.title')
%p= t('views.common.welcome', name: @user.name)
```

```ruby
# Controllers
flash[:notice] = t('controllers.users.create.success')

# Models
validates :name, presence: { message: I18n.t('errors.blank') }
```

## 🚢 Deployment

### Environment Variables

`.env.example` を `.env` にコピーして、以下を設定:

```bash
DATABASE_URL=postgresql://...
REDIS_URL=redis://...  # Solid Queueではオプション

SECRET_KEY_BASE=...
APPLICATION_HOST=yourdomain.com

# 外部サービス
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_USERNAME=...
SMTP_PASSWORD=...
```

### Docker Deployment

```bash
docker build -t myapp .
docker run -p 3000:3000 myapp
```

### Heroku Deployment

```bash
git push heroku main
heroku run rails db:migrate
heroku config:set SECRET_KEY_BASE=...
```

## 📚 Resources

- **PROJECT_TEMPLATE.md** - 完全なセットアップガイド
- **CLAUDE.md** - Claude Code使用時のガイドライン
- **scripts/README.md** - 自動化スクリプトの使い方
- **Rails 8 Guides** - https://guides.rubyonrails.org/
- **Tailwind CSS Docs** - https://tailwindcss.com/docs
- **Solid Queue** - https://github.com/rails/solid_queue

## 🤝 Contributing

このスターターキットは実際のプロダクション環境で培ったベストプラクティスをまとめたものです。

改善提案や新しいパターンがあれば、ぜひフィードバックをお寄せください。

## 📄 License

MIT License - 自由に使用、改変、配布できます。

---

**Built with ❤️ using Rails 8 Solid Stack**

このスターターキットで、高品質なSaaSアプリケーションを素早く構築できます。
