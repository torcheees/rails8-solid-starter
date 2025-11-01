# Rails 8 Solid Starter - クイックスタートガイド

このスターターキットを使って新しいRails 8プロジェクトを始める最速の方法です。

## 📋 前提条件

以下がインストールされていることを確認してください:

- **Ruby 3.2.2** (asdf推奨: `asdf install ruby 3.2.2`)
- **Node.js 20+** (`asdf install nodejs 20.10.0`)
- **pnpm 9.0.0** (`npm install -g pnpm@9.0.0`)
- **PostgreSQL 16+** (Homebrew: `brew install postgresql@16`)

## 🚀 5分でセットアップ

### ステップ1: 新規Railsプロジェクトを作成

```bash
# 新しいディレクトリで
rails new myapp \
  --database=postgresql \
  --css=tailwind \
  --javascript=esbuild \
  --skip-test \
  --skip-jbuilder

cd myapp
```

### ステップ2: スターターキットから設定をコピー

```bash
STARTER="/Users/akimitsukoshikawa/workspace/torcheees/rails8-solid-starter"

# 設定ファイル
cp $STARTER/.rubocop.yml .
cp $STARTER/.haml-lint.yml .
cp $STARTER/eslint.config.mjs .
cp $STARTER/tsconfig.json .
cp $STARTER/tailwind.config.js .

# 環境変数とGitignore
cp $STARTER/.env.example .env
cp $STARTER/.gitignore.example .gitignore

# Makefile
cp $STARTER/Makefile.example Makefile

# ドキュメント
mkdir -p docs/{features,specs,closed}
cp $STARTER/CLAUDE.md .
cp $STARTER/PROJECT_TEMPLATE.md docs/

# Claude Codeコマンドとスクリプト
cp -r $STARTER/.claude .
cp -r $STARTER/scripts .
chmod +x scripts/claude-auto.sh

# コードテンプレート
cp -r $STARTER/templates .
```

### ステップ3: Gemfileを更新

`$STARTER/Gemfile.example` を参考に、以下のGemを追加:

```ruby
# View Engine
gem 'haml-rails'

# Authentication & Authorization
gem 'devise'
gem 'devise-i18n'
gem 'pundit'

# Testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'rubocop-rails-omakase'
  gem 'haml_lint', require: false
  gem 'i18n-tasks'
end

group :test do
  gem 'shoulda-matchers'
  gem 'pundit-matchers'
  gem 'simplecov', require: false
end

# 最後に追加
gem 'jsbundling-rails'
```

```bash
bundle install
```

### ステップ4: package.jsonを更新

`$STARTER/package.json.example` を参考に、スクリプトと依存関係を追加:

```bash
pnpm add -D \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint \
  eslint-config-prettier \
  eslint-plugin-prettier \
  eslint-plugin-react \
  eslint-plugin-react-hooks \
  prettier \
  typescript \
  @types/react \
  @types/react-dom
```

### ステップ5: データベースとSolid Queueのセットアップ

```bash
# データベース作成
bin/rails db:create

# Solid Queue インストール
bin/rails solid_queue:install

# マイグレーション実行
bin/rails db:migrate
```

### ステップ6: RSpecとDeviseのセットアップ

```bash
# RSpec
bin/rails generate rspec:install

# Devise
bin/rails generate devise:install
bin/rails generate devise User
bin/rails db:migrate

# HAML変換（Deviseビュー）
bin/rails generate devise:views
# 手動でERBをHAMLに変換、または html2haml gem使用
```

### ステップ7: アプリケーション起動

```bash
# 開発サーバー起動（Rails + Solid Queue + アセット監視）
bin/dev

# または個別に
bin/rails server     # Rails
bin/jobs            # Solid Queue
npm run build       # アセットビルド
```

ブラウザで http://localhost:3000 を開く

## 📝 次のステップ

### マルチテナンシーのセットアップ

```bash
# app/models/current.rb を作成
cat > app/models/current.rb <<'EOF'
class Current < ActiveSupport::CurrentAttributes
  attribute :organization, :organization_id, :user
end
EOF

# Organization モデルを生成
bin/rails generate model Organization name:string subdomain:string
bin/rails db:migrate
```

詳細は `PROJECT_TEMPLATE.md` の「ステップ4: アーキテクチャのセットアップ」を参照。

### Pundit認可のセットアップ

```bash
# Punditインストール
bin/rails generate pundit:install

# ポリシーの作成例
bin/rails generate pundit:policy Post
```

詳細は `PROJECT_TEMPLATE.md` の「ステップ4.2: Pundit認可」を参照。

### コードテンプレートの使用

`templates/` ディレクトリに以下のテンプレートがあります:

- **models/base_model.rb** - マルチテナント対応モデル
- **controllers/base_controller.rb** - 認証・認可付きコントローラー
- **policies/base_policy.rb** - Punditポリシー
- **services/base_service.rb** - サービスレイヤークラス
- **jobs/base_job.rb** - Solid Queueジョブ
- **views/example_index.html.haml** - Tailwind CSSビュー

新しいファイルを作成する際、これらをコピーして使用してください。

## 🛠️ 開発ワークフロー

### コマンドリファレンス

```bash
# 開発
make dev              # サーバー起動
make console          # Railsコンソール
make routes           # ルート一覧

# テスト
make test             # 全テスト（カバレッジ付き）
make test-fast        # 全テスト（カバレッジなし）
make test-file FILE=spec/models/user_spec.rb

# コード品質
make lint             # 全リンター
make fix              # 自動修正
npm run type-check    # TypeScript型チェック

# データベース
make db-migrate       # マイグレーション実行
make db-rollback      # ロールバック
make db-reset         # リセット（注意！）

# i18n
make i18n-health      # 翻訳チェック
make i18n-normalize   # 翻訳ファイル整形
```

### Claude Code自動化

開発を自動化するスクリプトが利用可能:

```bash
# Python版（推奨）
python3 scripts/claude_auto.py

# シェル版（プリセット付き）
./scripts/claude-auto.sh auto        # 自動モード
./scripts/claude-auto.sh aggressive  # アグレッシブモード
./scripts/claude-auto.sh balanced    # バランスモード
```

詳細は `scripts/README.md` を参照。

### Claude Codeスラッシュコマンド

#### `/create-spec` - 仕様書生成

実装計画から詳細な仕様書を生成:

```
/create-spec docs/features/user-authentication.md
/create-spec docs/features/api-endpoints.md --focus=security
```

## 📚 完全なドキュメント

- **PROJECT_TEMPLATE.md** - 完全なセットアップガイド（50+項目チェックリスト）
- **CLAUDE.md** - Claude Code使用時のガイドライン
- **README.md** - プロジェクト概要と詳細説明
- **scripts/README.md** - 自動化スクリプトの使い方

## ✅ セットアップ完了チェックリスト

- [ ] Ruby 3.2.2インストール済み
- [ ] PostgreSQLインストール済み
- [ ] pnpm 9.0.0インストール済み
- [ ] Railsプロジェクト作成完了
- [ ] 設定ファイルコピー完了
- [ ] Gemfile更新とbundle install完了
- [ ] package.json更新とpnpm install完了
- [ ] データベース作成完了
- [ ] Solid Queueインストール完了
- [ ] RSpecセットアップ完了
- [ ] Deviseセットアップ完了
- [ ] bin/dev でサーバー起動成功
- [ ] make lint で0エラー
- [ ] make test で全テスト成功

## 🆘 トラブルシューティング

### データベース接続エラー

```bash
# PostgreSQLが起動しているか確認
brew services list

# 起動
brew services start postgresql@16
```

### アセットビルドエラー

```bash
# node_modulesを再インストール
rm -rf node_modules pnpm-lock.yaml
pnpm install

# アセットを再ビルド
npm run build
```

### Solid Queueエラー

```bash
# Solid Queueを再インストール
bin/rails solid_queue:install
bin/rails db:migrate
```

## 🎉 完成!

これで高品質なRails 8アプリケーションの基盤が完成しました。

次は `docs/features/` に実装計画を作成し、`/create-spec` コマンドで仕様書を生成して開発を進めましょう！
