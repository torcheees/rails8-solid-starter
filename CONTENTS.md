# Rails 8 Solid Starter - コンテンツ一覧

このスターターキットに含まれるファイルとディレクトリの説明です。

## 📁 ディレクトリ構造

```
rails8-solid-starter/
├── .claude/                    # Claude Codeカスタムコマンド
│   └── commands/
│       └── create-spec.md      # 仕様書生成コマンド
├── docs/                       # ドキュメント格納場所
│   ├── features/              # 実装計画（チェックリスト形式）
│   ├── specs/                 # 生成された仕様書
│   └── closed/                # 完了したドキュメント
├── scripts/                    # 自動化スクリプト
│   ├── claude_auto.py         # Claude Code自動化（Python）
│   ├── claude-auto.sh         # シェルラッパー
│   └── README.md              # スクリプト使用方法
├── templates/                  # コードテンプレート
│   ├── controllers/
│   │   └── base_controller.rb # 標準コントローラー
│   ├── jobs/
│   │   └── base_job.rb        # Solid Queueジョブ
│   ├── models/
│   │   └── base_model.rb      # マルチテナント対応モデル
│   ├── policies/
│   │   └── base_policy.rb     # Punditポリシー
│   ├── services/
│   │   └── base_service.rb    # サービスレイヤー
│   └── views/
│       └── example_index.html.haml # Tailwind CSSビュー
└── config/                     # 設定ディレクトリ（空）
```

## 📄 ドキュメントファイル

### メインドキュメント

| ファイル | 説明 | 用途 |
|---------|------|------|
| **README.md** | プロジェクト概要と詳細ガイド | 全体像の把握 |
| **QUICK_START.md** | 5分でセットアップする手順 | 即座に開始したい場合 |
| **PROJECT_TEMPLATE.md** | 完全なセットアップガイド（650行） | 詳細な手順が必要な場合 |
| **CLAUDE.md** | Claude Code使用時のガイドライン | AI開発時の参照 |
| **CONTENTS.md** | このファイル | ファイル一覧の確認 |

### ドキュメント選択ガイド

- **今すぐ始めたい** → `QUICK_START.md`
- **詳細な手順が必要** → `PROJECT_TEMPLATE.md`
- **プロジェクト全体を理解したい** → `README.md`
- **Claude Codeを使う** → `CLAUDE.md`

## ⚙️ 設定ファイル

### Ruby/Rails設定

| ファイル | 説明 |
|---------|------|
| **.rubocop.yml** | RuboCop（Rubyリンター）設定 |
| **.haml-lint.yml** | HAML-Lint（HAMLテンプレートリンター）設定 |
| **Gemfile.example** | 推奨Gem一覧（コピーして使用） |

### JavaScript/TypeScript設定

| ファイル | 説明 |
|---------|------|
| **eslint.config.mjs** | ESLint（JS/TSリンター）設定 |
| **tsconfig.json** | TypeScriptコンパイラ設定 |
| **package.json.example** | npm依存関係一覧（コピーして使用） |

### Tailwind CSS設定

| ファイル | 説明 |
|---------|------|
| **tailwind.config.js** | Tailwind CSS設定（Notion風カラーパレット） |

### その他

| ファイル | 説明 |
|---------|------|
| **.env.example** | 環境変数テンプレート |
| **.gitignore.example** | Git除外ファイル設定 |
| **Makefile.example** | 開発コマンド集（40+コマンド） |

## 🔧 コードテンプレート

### templates/models/base_model.rb

**用途**: 新しいモデルを作成する際のテンプレート

**特徴**:
- マルチテナンシー対応（organizationへのbelongs_to）
- バリデーション例
- スコープ例
- Enum使用例
- コールバック例
- クォータチェック

**使用例**:
```bash
bin/rails generate model Post title:string body:text
# 生成されたファイルにbase_model.rbの内容を参考に追記
```

### templates/controllers/base_controller.rb

**用途**: 新しいコントローラーを作成する際のテンプレート

**特徴**:
- 認証（authenticate_user!）
- 認可（Pundit）
- マルチテナンシー（set_organization）
- RESTfulアクション（index, show, new, create, edit, update, destroy）
- Strong Parameters
- i18n対応

**使用例**:
```bash
bin/rails generate controller Posts index show new create edit update destroy
# base_controller.rbを参考に実装
```

### templates/policies/base_policy.rb

**用途**: 新しいPunditポリシーを作成する際のテンプレート

**特徴**:
- Scopeクラス（index用）
- 全アクションのポリシーメソッド
- クォータチェック（create時）
- 権限チェックヘルパー

**使用例**:
```bash
bin/rails generate pundit:policy Post
# base_policy.rbを参考に実装
```

### templates/services/base_service.rb

**用途**: ビジネスロジックをサービスクラスに分離する際のテンプレート

**特徴**:
- 初期化パターン
- executeメソッド（メインエントリーポイント）
- バリデーション
- エラーハンドリング
- 監査ログ作成
- 外部API呼び出し例

**使用例**:
```bash
mkdir -p app/services
cp templates/services/base_service.rb app/services/notification_service.rb
# 実装をカスタマイズ
```

### templates/jobs/base_job.rb

**用途**: Solid Queueバックグラウンドジョブを作成する際のテンプレート

**特徴**:
- マルチテナンシー対応（Current.organization設定）
- リトライ設定
- エラーハンドリング
- 監査ログ作成

**使用例**:
```bash
bin/rails generate job Notification
# base_job.rbを参考に実装
```

### templates/views/example_index.html.haml

**用途**: Tailwind CSSを使ったビューを作成する際のテンプレート

**特徴**:
- レスポンシブデザイン
- グリッドレイアウト
- ステータスバッジ
- ページネーション
- Empty State
- i18n対応

**使用例**:
```bash
# app/views/posts/index.html.haml を作成
# example_index.html.haml を参考にTailwindクラスを使用
```

## 🤖 自動化スクリプト

### scripts/claude_auto.py

**用途**: Claude Codeの自動化（許可プロンプト自動承認、アイドル検出）

**機能**:
- tmuxセッション管理
- ビジーステート検出（最新20行のみ）
- 自動プロンプト送信（60秒アイドル後）
- パーミッション自動承認

**使用方法**:
```bash
python3 scripts/claude_auto.py
```

### scripts/claude-auto.sh

**用途**: Python版のシェルラッパー（プリセット付き）

**プリセット**:
- `auto` - 標準（60秒待機）
- `aggressive` - アグレッシブ（30秒待機）
- `balanced` - バランス（45秒待機）
- `cautious` - 慎重（90秒待機）

**使用方法**:
```bash
./scripts/claude-auto.sh auto
./scripts/claude-auto.sh aggressive
```

詳細は `scripts/README.md` を参照。

## 🎯 Claude Codeコマンド

### .claude/commands/create-spec.md

**用途**: 実装計画から詳細な仕様書を自動生成

**機能**:
- `docs/features/` 配下の実装計画を解析
- データモデル設計
- APIエンドポイント定義
- セキュリティ要件（OWASP Top 10）
- パフォーマンス要件
- テスト要件
- i18n対応

**使用方法**:
```
/create-spec docs/features/user-authentication.md
/create-spec docs/features/api-endpoints.md --focus=security
/create-spec docs/features/monitoring.md --requirements="high-performance"
```

生成された仕様書は `docs/features/[original]-spec.md` に保存されます。

## 📊 使用の流れ

### 1. プロジェクト作成

```bash
rails new myapp --database=postgresql
cd myapp
```

### 2. スターターキットから設定をコピー

```bash
STARTER="/path/to/rails8-solid-starter"
cp $STARTER/.rubocop.yml .
cp $STARTER/Gemfile.example Gemfile
# ... (QUICK_START.md参照)
```

### 3. 開発開始

```bash
# 実装計画を作成
echo "# User Authentication" > docs/features/user-authentication.md
echo "## 要件" >> docs/features/user-authentication.md
echo "- ユーザー登録/ログイン" >> docs/features/user-authentication.md

# 仕様書生成
/create-spec docs/features/user-authentication.md

# 実装開始（Claude Code自動化）
./scripts/claude-auto.sh auto
```

### 4. コード生成時はテンプレートを参照

```bash
# モデル生成
bin/rails generate model User email:string
# templates/models/base_model.rb を参考に実装

# コントローラー生成
bin/rails generate controller Users
# templates/controllers/base_controller.rb を参考に実装

# ポリシー生成
bin/rails generate pundit:policy User
# templates/policies/base_policy.rb を参考に実装
```

### 5. コード品質チェック

```bash
make lint          # RuboCop + HAML-Lint
npm run lint:js    # ESLint
npx tsc --noEmit  # TypeScript
make test          # RSpec
```

## 🔍 ファイルサイズ一覧

```
README.md              13KB   - プロジェクト概要
QUICK_START.md         8.5KB  - クイックスタート
PROJECT_TEMPLATE.md    19KB   - 完全セットアップガイド
CLAUDE.md              14KB   - Claude Code指示書
Gemfile.example        3.3KB  - Gem依存関係
package.json.example   2.1KB  - npm依存関係
Makefile.example       3.8KB  - 開発コマンド
tailwind.config.js     3KB    - Tailwind設定
scripts/claude_auto.py 6KB    - 自動化スクリプト
```

## 💡 Tips

### ファイルのコピーは選択的に

すべてのファイルをコピーする必要はありません。プロジェクトの要件に応じて選択してください:

**最小構成**:
- `.rubocop.yml`
- `.haml-lint.yml`
- `eslint.config.mjs`
- `tsconfig.json`
- `tailwind.config.js`
- `Gemfile.example`（参考に）

**推奨構成**（上記 + 以下）:
- `Makefile.example`
- `CLAUDE.md`
- `templates/` 全体

**完全構成**（全ファイル）:
- 全ての設定ファイル
- 全てのドキュメント
- スクリプト
- テンプレート

### テンプレートのカスタマイズ

テンプレートはあくまで基本形です。プロジェクトの要件に応じてカスタマイズしてください:

- モデル名を変更
- バリデーションを追加/削除
- メソッドを追加
- コメントを更新

## 📞 サポート

問題が発生した場合:

1. `QUICK_START.md` のトラブルシューティングセクションを確認
2. `PROJECT_TEMPLATE.md` の詳細手順を確認
3. `README.md` のアーキテクチャセクションを確認

---

**Rails 8 Solid Starter** - 高品質なSaaSアプリケーションを素早く構築するためのベストプラクティス集
