# Development Workflow - 開発ワークフロー

Rails 8 Solid Starterを使った開発の推奨ワークフローです。

## 📋 開発フロー全体図

```
1. 要件定義 (/define-requirements)
    ↓
2. 実装計画 (/plan-features)
    ↓
3. 詳細仕様 (/create-spec)
    ↓
4. 実装 (Claude Code自動化)
    ↓
5. テスト・レビュー
    ↓
6. デプロイ
```

## 🎯 ステップ1: プロジェクト要件定義

**コマンド:** `/define-requirements`

**目的:** プロジェクト全体の要件を明確化

**成果物:** `docs/REQUIREMENTS.md`

### 実行方法

```bash
# Claude Codeで
/define-requirements
```

Claude Codeが以下をヒアリング:
- プロジェクト名と目的
- ターゲットユーザー
- 解決する課題
- コア機能
- データモデル
- 技術スタック

### 出力例

```markdown
# プロジェクト要件定義書

## 1. プロジェクト概要
プロジェクト名: タスク管理アプリ
目的: チームのタスク管理を効率化
ターゲット: 中小企業のプロジェクトチーム

## 2. ユーザーストーリー
【プロジェクトメンバー】として、
【タスクの進捗を可視化したい】、
【なぜなら】チーム全体の状況を把握する必要があるから

## 3. データモデル
User ─ Task ─ Project ─ Organization
...
```

### チェックポイント

- [ ] ターゲットユーザーが明確か？
- [ ] MVP（Must have）が3-5個に絞られているか？
- [ ] データモデルの関連が整理されているか？
- [ ] 非機能要件（性能、セキュリティ）が定義されているか？

## 🗺️ ステップ2: 実装計画の作成

**コマンド:** `/plan-features`

**目的:** 要件を実装可能な機能単位に分割

**成果物:** `docs/features/*.md` + `docs/features/README.md`

### 実行方法

```bash
# Claude Codeで（要件定義後）
/plan-features
```

Claude Codeが自動的に:
- 要件定義書を読み込み
- 機能を1-2週間単位に分割
- 依存関係を整理
- 実装順序を決定
- 各機能の計画書を作成

### 出力例

```
docs/features/
├── README.md                           # 実装計画一覧
├── 01-user-authentication.md           # ユーザー認証
├── 02-multi-tenancy.md                 # マルチテナンシー
├── 03-pundit-authorization.md          # Pundit認可
├── 04-task-model.md                    # タスクモデル
├── 05-task-list.md                     # タスク一覧
└── 06-task-detail.md                   # タスク詳細
```

### 各計画書の内容

```markdown
# ユーザー認証機能

## 概要
Deviseを使用したユーザー登録・ログイン機能

## 実装内容
- [ ] Deviseのセットアップ
- [ ] Userモデルの実装
- [ ] ビュー実装（HAML + Tailwind）
- [ ] API実装（JWT認証）
- [ ] テスト

## 完了条件
- [ ] RSpec全テスト成功
- [ ] RuboCop 0エラー
- [ ] モバイルアプリからログイン可能

## 見積もり: 3-5日
```

### チェックポイント

- [ ] 各機能が1-2週間で完了する粒度か？
- [ ] 依存関係が明確か？
- [ ] MVP機能が優先されているか？
- [ ] API仕様が含まれているか（モバイル対応）？

## 📝 ステップ3: 詳細仕様書の作成

**コマンド:** `/create-spec`

**目的:** 実装計画から詳細仕様書を生成

**成果物:** `docs/features/*-spec.md`

### 実行方法

```bash
# Claude Codeで（各機能ごと）
/create-spec docs/features/01-user-authentication.md
```

Claude Codeが自動生成:
- データモデル詳細
- APIエンドポイント仕様
- セキュリティ要件（OWASP Top 10準拠）
- パフォーマンス要件
- テスト要件
- i18n対応

### 出力例

```markdown
# ユーザー認証機能 - 詳細仕様書

## データモデル設計

### User
| カラム名 | 型 | NULL | デフォルト | インデックス |
|---------|-----|------|-----------|------------|
| id | bigint | NO | auto | PRIMARY |
| email | string | NO | - | UNIQUE |
| encrypted_password | string | NO | - | - |

## APIエンドポイント

### POST /api/v1/auth/signup
リクエスト:
{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}

レスポンス:
{
  "accessToken": "...",
  "user": {...}
}

## セキュリティ

### OWASP Top 10対策
- [x] A01: Broken Access Control - Punditで認可制御
- [x] A02: Cryptographic Failures - bcryptでパスワード暗号化
- [x] A03: Injection - Strong Parametersで対策
...
```

### チェックポイント

- [ ] データベーススキーマが明確か？
- [ ] API仕様が完全か（リクエスト/レスポンス）？
- [ ] セキュリティ対策が網羅されているか？
- [ ] テストケースが具体的か？

## 💻 ステップ4: 実装

### 4.1 手動実装

```bash
# プロジェクトディレクトリで
cd web

# 仕様書を確認
cat docs/features/01-user-authentication-spec.md

# 実装開始
bin/rails generate devise:install
bin/rails generate devise User
...
```

### 4.2 Claude Code自動実装（推奨）

```bash
# 自動化スクリプトで実装
./scripts/claude-auto.sh auto
```

**自動化スクリプトが行うこと:**
- `docs/features/` の実装計画を読み取り
- チェックリスト形式で実装
- テスト・Lintを自動実行
- エラーがあれば修正
- 完了したら `docs/closed/` に移動
- 定期的にGit push

**プリセット:**
```bash
./scripts/claude-auto.sh auto        # 標準（60秒待機）
./scripts/claude-auto.sh aggressive  # アグレッシブ（30秒待機）
./scripts/claude-auto.sh balanced    # バランス（45秒待機）
./scripts/claude-auto.sh cautious    # 慎重（90秒待機）
```

### 実装中のチェックリスト

各実装計画書のチェックボックスを順番に完了:

```markdown
## 実装内容
- [x] Deviseのセットアップ ← 完了
- [x] Userモデルの実装 ← 完了
- [ ] ビュー実装 ← 進行中
- [ ] API実装
- [ ] テスト
```

### コード品質チェック（必須）

実装後、必ず以下を実行:

```bash
# ルートディレクトリで
pnpm lint           # Web + Mobile + Shared
pnpm type-check     # TypeScript型チェック
pnpm test           # 全テスト

# web/ ディレクトリで
cd web
make lint           # RuboCop + HAML-Lint
bundle exec rspec   # Rails tests
```

**期待される結果:**
- RuboCop: 0 offenses
- HAML-Lint: 0 lints
- ESLint: 0 errors
- TypeScript: 0 errors
- RSpec: 全テスト成功

## ✅ ステップ5: テスト・レビュー

### 5.1 自動テスト

```bash
# 全テスト実行
cd web && bundle exec rspec
pnpm test

# カバレッジ確認
cd web && COVERAGE=true bundle exec rspec
open coverage/index.html
```

**目標カバレッジ:**
- Models: 90%+
- Controllers: 80%+
- Services: 90%+
- Policies: 100%

### 5.2 手動テスト

**Webアプリ:**
```bash
cd web && bin/dev
# http://localhost:3000 で確認
```

**モバイルアプリ:**
```bash
pnpm mobile:start
# Expo Goアプリで確認
```

### 5.3 セキュリティチェック

```bash
# セキュリティ脆弱性スキャン
cd web && bundle exec brakeman

# 依存関係の脆弱性チェック
bundle audit
pnpm audit
```

### 5.4 パフォーマンステスト

```bash
# N+1クエリチェック
cd web && bundle exec rspec --profile

# レスポンスタイム測定
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/api/v1/tasks
```

## 🚀 ステップ6: デプロイ

### 6.1 Git管理

```bash
# 変更をコミット
git add .
git commit -m "feat: Implement user authentication

- Add Devise setup
- Create User model
- Implement auth API endpoints
- Add RSpec tests (90% coverage)

Closes #1"

git push origin main
```

### 6.2 Pull Request作成

```bash
# GitHub CLIで
gh pr create --title "Feature: User Authentication" --body "$(cat <<EOF
## 概要
ユーザー認証機能を実装しました

## 実装内容
- [x] Devise導入
- [x] User モデル
- [x] 認証API
- [x] RSpecテスト

## テスト結果
- RSpec: 25 examples, 0 failures
- RuboCop: 0 offenses
- カバレッジ: 92%

## スクリーンショット
[Login画面のスクショ]

## チェックリスト
- [x] テスト全て成功
- [x] Lint全て成功
- [x] ドキュメント更新
- [x] モバイルアプリ動作確認
EOF
)"
```

### 6.3 本番デプロイ

**Heroku:**
```bash
git push heroku main
heroku run rails db:migrate
heroku open
```

**Docker:**
```bash
docker build -t myapp .
docker run -p 3000:3000 myapp
```

## 🔄 継続的な改善

### 完了した計画書の管理

```bash
# 実装完了後
mv docs/features/01-user-authentication.md docs/closed/
mv docs/features/01-user-authentication-spec.md docs/closed/
```

### 新機能の追加

```bash
# 新しい要件が出たら
/define-requirements  # 要件定義を更新

# 新しい実装計画を追加
/plan-features       # 計画書を追加生成

# 実装
/create-spec docs/features/XX-new-feature.md
./scripts/claude-auto.sh auto
```

## 📊 プロジェクト進捗管理

### 進捗の確認

```bash
# 実装計画一覧を確認
cat docs/features/README.md

# 完了した機能
ls docs/closed/

# 残りの機能
ls docs/features/*.md
```

### 週次レビュー

毎週、以下を確認:
- [ ] 完了した機能数
- [ ] テストカバレッジ
- [ ] 技術的負債の蓄積
- [ ] パフォーマンス指標
- [ ] セキュリティ監査

## 🛠️ トラブルシューティング

### よくある問題

**問題1: テストが失敗する**
```bash
# データベースをリセット
cd web && bin/rails db:reset RAILS_ENV=test

# 再実行
bundle exec rspec
```

**問題2: Lintエラーが多数**
```bash
# 自動修正
bundle exec rubocop -A
npm run lint:fix
```

**問題3: モバイルアプリがAPIに接続できない**
```bash
# APIのURLを確認
# mobile/.env
EXPO_PUBLIC_API_URL=http://localhost:3000

# Rails サーバーが起動しているか確認
cd web && bin/dev
```

## 📚 コマンドリファレンス

| コマンド | 説明 | 成果物 |
|---------|------|--------|
| `/define-requirements` | 要件定義作成 | docs/REQUIREMENTS.md |
| `/plan-features` | 実装計画作成 | docs/features/*.md |
| `/create-spec` | 詳細仕様書作成 | docs/features/*-spec.md |
| `./scripts/claude-auto.sh` | 自動実装 | - |

## 💡 ベストプラクティス

1. **小さく分割** - 1-2週間で完了する機能単位
2. **テストファースト** - 実装前にテストを書く
3. **継続的統合** - 頻繁にpush、頻繁にデプロイ
4. **ドキュメント更新** - コードと同時にドキュメントも更新
5. **セキュリティ優先** - OWASP Top 10を常に意識
6. **パフォーマンス監視** - レスポンスタイムとN+1クエリをチェック
7. **コードレビュー** - Pull Requestで必ずレビュー

---

**Rails 8 Solid Starter** - 効率的な開発ワークフローで高品質なアプリケーションを構築
