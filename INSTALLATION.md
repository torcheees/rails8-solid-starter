# Rails 8 Solid Starter - Installation Guide

このスターターキットを使って新規プロジェクトを作成する方法です。

## 🚀 3つの方法

### 方法1: スクリプトで自動作成（推奨）

最も簡単な方法です。スクリプトが自動的にプロジェクトをセットアップします。

```bash
# 1. スターターキットをクローン
git clone https://github.com/torcheees/rails8-solid-starter.git
cd rails8-solid-starter

# 2. スクリプトで新規プロジェクトを作成
./create-project.sh myapp

# 3. プロジェクトに移動して起動
cd myapp
bin/dev
```

#### スクリプトのオプション

```bash
# ヘルプを表示
./create-project.sh --help

# 特定のディレクトリに作成
./create-project.sh myapp --dir ~/projects

# 最小構成（ファイルコピーのみ、bundle/npm/dbスキップ）
./create-project.sh myapp --minimal

# 特定のステップをスキップ
./create-project.sh myapp --skip-bundle --skip-npm
./create-project.sh myapp --skip-db
```

#### スクリプトが行うこと

1. ✅ Rails新規プロジェクト作成
2. ✅ 設定ファイルコピー（.rubocop.yml, eslint.config.mjs等）
3. ✅ ドキュメントコピー（CLAUDE.md, PROJECT_TEMPLATE.md等）
4. ✅ スクリプトとツールコピー（scripts/, .claude/）
5. ✅ コードテンプレートコピー（templates/）
6. ✅ Gemfile更新（HAML, Devise, Pundit等追加）
7. ✅ package.json更新（TypeScript, ESLint等追加）
8. ✅ bundle install実行
9. ✅ pnpm install実行
10. ✅ データベース作成
11. ✅ Solid Queueインストール
12. ✅ マイグレーション実行
13. ✅ Current model作成（マルチテナンシー）
14. ✅ ApplicationPolicy作成（Pundit）

所要時間: **約5分**

### 方法2: 手動セットアップ（QUICK_START.md）

細かくステップを確認しながら進めたい場合。

```bash
# 1. スターターキットをクローン
git clone https://github.com/torcheees/rails8-solid-starter.git

# 2. 新規Railsプロジェクト作成
rails new myapp --database=postgresql --css=tailwind --javascript=esbuild
cd myapp

# 3. 設定ファイルをコピー
STARTER="../rails8-solid-starter"
cp $STARTER/.rubocop.yml .
cp $STARTER/.haml-lint.yml .
# ... (QUICK_START.md参照)
```

詳細は `QUICK_START.md` を参照してください。

所要時間: **約10分**

### 方法3: 完全手動セットアップ（PROJECT_TEMPLATE.md）

全ステップを理解しながら、カスタマイズして進めたい場合。

50+項目のチェックリストに従ってセットアップします。

詳細は `PROJECT_TEMPLATE.md` を参照してください。

所要時間: **約30-60分**

## 📦 前提条件

以下がインストールされている必要があります:

### 必須
- **Ruby 3.2.2** - `asdf install ruby 3.2.2`
- **Rails 8.0+** - `gem install rails`
- **Node.js 20+** - `asdf install nodejs 20.10.0`
- **pnpm 9.0.0** - `npm install -g pnpm@9.0.0`
- **PostgreSQL 16+** - `brew install postgresql@16`

### オプション
- **tmux** - Claude Code自動化に必要

## 🎯 作成後の確認

プロジェクト作成後、以下を確認してください:

```bash
cd myapp

# 1. Linterが動作することを確認
bundle exec rubocop --version
bundle exec haml-lint --version
npm run lint:js

# 2. テストが動作することを確認
bundle exec rspec --version

# 3. データベース接続を確認
bin/rails db:version

# 4. サーバー起動を確認
bin/dev
```

ブラウザで http://localhost:3000 を開き、Railsのウェルカムページが表示されればOK!

## 📝 次のステップ

### 1. 認証のセットアップ（Devise）

```bash
# Deviseインストール
bin/rails generate devise:install

# Userモデル作成
bin/rails generate devise User
bin/rails db:migrate

# Deviseビューを生成（ERB）
bin/rails generate devise:views

# HAMLに変換（手動またはhtml2haml gemを使用）
gem install html2haml
find app/views/devise -name '*.erb' | while read f; do
  html2haml "$f" "${f%.erb}.haml" && rm "$f"
done
```

### 2. 認可のセットアップ（Pundit）

```bash
# Punditインストール
bin/rails generate pundit:install

# ポリシー例作成
bin/rails generate pundit:policy Post
```

`templates/policies/base_policy.rb` を参考に実装してください。

### 3. マルチテナンシーのセットアップ

```bash
# Organizationモデル作成
bin/rails generate model Organization name:string subdomain:string
bin/rails generate model Membership user:references organization:references role:string

bin/rails db:migrate
```

`app/models/current.rb` が既に作成されています。

詳細は `PROJECT_TEMPLATE.md` の「ステップ4: アーキテクチャのセットアップ」を参照。

### 4. 最初の機能を実装

```bash
# 実装計画を作成
cat > docs/features/posts.md << 'EOF'
# Posts Feature

## 要件
- ユーザーは投稿を作成できる
- 投稿一覧を表示できる
- 投稿を編集・削除できる

## データモデル
- Post (title:string, body:text, user_id:integer, organization_id:integer)
EOF

# Claude Codeで仕様書生成
/create-spec docs/features/posts.md

# モデル生成
bin/rails generate model Post title:string body:text user:references organization:references
bin/rails db:migrate

# templates/ のテンプレートを参考に実装
cp templates/models/base_model.rb app/models/post.rb.tmp
# 実装をカスタマイズ...
```

## 🛠️ トラブルシューティング

### データベース接続エラー

```bash
# PostgreSQLが起動しているか確認
brew services list

# 起動
brew services start postgresql@16

# 再作成
bin/rails db:drop db:create db:migrate
```

### bundle installエラー

```bash
# Bundlerを更新
gem update --system
gem install bundler

# 再インストール
rm Gemfile.lock
bundle install
```

### pnpm installエラー

```bash
# pnpmを再インストール
npm uninstall -g pnpm
npm install -g pnpm@9.0.0

# node_modulesを削除して再インストール
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

### アセットビルドエラー

```bash
# アセットを再ビルド
npm run build

# 個別にビルド
npm run build:turbo
npm run build:react
npm run build:css
```

## 📚 ドキュメント

プロジェクト作成後、以下のドキュメントが利用可能です:

| ファイル | 説明 |
|---------|------|
| **CLAUDE.md** | Claude Code使用時のガイドライン（14KB） |
| **docs/PROJECT_TEMPLATE.md** | 完全なセットアップガイド（19KB、50+チェックリスト） |
| **docs/STARTER_README.md** | スターターキットの詳細説明（13KB） |
| **templates/** | コードテンプレート（models, controllers, policies, services, jobs, views） |
| **Makefile** | 40+開発コマンド |

### よく使うコマンド

```bash
# 開発サーバー起動
bin/dev

# テスト実行
make test

# Linter実行
make lint

# 自動修正
make fix

# ルート一覧
make routes

# コンソール
make console
```

## 🤖 Claude Code自動化

Claude Code自動化スクリプトが利用可能です:

```bash
# Python版（推奨）
python3 scripts/claude_auto.py

# シェル版（プリセット付き）
./scripts/claude-auto.sh auto        # 標準（60秒待機）
./scripts/claude-auto.sh aggressive  # アグレッシブ（30秒待機）
./scripts/claude-auto.sh balanced    # バランス（45秒待機）
./scripts/claude-auto.sh cautious    # 慎重（90秒待機）
```

詳細は `scripts/README.md` を参照。

## 💡 Tips

### 既存プロジェクトに設定を適用

既存のRailsプロジェクトにスターターキットの設定を適用することもできます:

```bash
cd existing-project

STARTER="/path/to/rails8-solid-starter"

# 必要な設定ファイルのみコピー
cp $STARTER/.rubocop.yml .
cp $STARTER/.haml-lint.yml .
cp $STARTER/eslint.config.mjs .
cp $STARTER/Makefile.example Makefile

# ドキュメントとツールをコピー
cp $STARTER/CLAUDE.md .
cp -r $STARTER/templates .
```

### スターターキットの更新

スターターキットは定期的に更新されます。最新版を取得:

```bash
cd rails8-solid-starter
git pull origin main

# 既存プロジェクトに反映
cd ../myapp
STARTER="../rails8-solid-starter"
cp $STARTER/.rubocop.yml .
# 必要な設定を更新...
```

## 🆘 サポート

問題が発生した場合:

1. **QUICK_START.md** のトラブルシューティングセクションを確認
2. **PROJECT_TEMPLATE.md** の詳細手順を確認
3. **GitHub Issues** で質問: https://github.com/torcheees/rails8-solid-starter/issues

## 📄 License

MIT License - 自由に使用、改変、配布できます。

---

**Rails 8 Solid Starter** - 高品質なSaaSアプリケーションを素早く構築

Repository: https://github.com/torcheees/rails8-solid-starter
