# Monorepo Structure - Rails 8 + React Native

このスターターキットは **pnpm workspaces** を使用したモノレポ構成です。

## 📁 ディレクトリ構造

```
project/
├── web/                      # Rails 8 backend + web frontend
│   ├── app/
│   │   ├── models/
│   │   ├── controllers/
│   │   ├── views/          # HAML templates
│   │   └── javascript/     # TypeScript/React web components
│   ├── spec/               # RSpec tests
│   └── package.json.example
├── mobile/                  # React Native (Expo SDK 54)
│   ├── app/                # Expo Router screens
│   │   ├── (auth)/        # Authentication screens
│   │   ├── (tabs)/        # Main app tabs
│   │   ├── _layout.tsx    # Root layout
│   │   └── index.tsx      # Entry point
│   ├── src/
│   │   ├── components/    # React Native components
│   │   ├── hooks/         # Custom hooks
│   │   ├── store/         # Zustand state management
│   │   ├── navigation/
│   │   ├── utils/
│   │   └── constants/
│   ├── package.json
│   ├── tsconfig.json
│   ├── app.json           # Expo configuration
│   └── tailwind.config.js # NativeWind configuration
├── packages/
│   └── shared/            # Shared TypeScript package
│       ├── src/
│       │   ├── api/      # API clients (ApiClient, AuthApi)
│       │   ├── types/    # TypeScript interfaces
│       │   ├── validators/ # Zod schemas
│       │   └── utils/    # Shared utilities
│       ├── package.json
│       ├── tsconfig.json
│       └── README.md
├── package.json          # Root package.json (monorepo scripts)
├── pnpm-workspace.yaml   # Workspace configuration
└── templates/            # Code templates
    ├── models/
    ├── controllers/
    ├── policies/
    ├── services/
    ├── jobs/
    ├── views/
    └── mobile/           # Mobile templates
        ├── store/
        ├── hooks/
        └── screens/
```

## 🎯 モノレポのメリット

### 1. コードの再利用
- API型定義を一度書けばWebとMobileで共有
- バリデーションロジックの統一
- APIクライアントの共有

### 2. 一貫性
- 同じTypeScript設定
- 同じリンタールール
- 同じテストフレームワーク

### 3. 開発効率
- 1つのリポジトリで管理
- 同時に変更可能
- 型の整合性が自動的に保たれる

## 📦 パッケージ詳細

### web/ - Rails 8 Backend + Web Frontend

**役割**: サーバーサイドロジック、API、Web UI

**技術スタック**:
- Ruby 3.2.2 + Rails 8.0
- Solid Queue/Cache/Cable
- PostgreSQL
- HAML templates
- Hotwire (Turbo + Stimulus)
- React 18 (ウィジェット用)

**パッケージマネージャー**: Bundler (Ruby) + pnpm (JavaScript)

### mobile/ - React Native App

**役割**: iOSおよびAndroidモバイルアプリ

**技術スタック**:
- React Native 0.81.5
- Expo SDK 54
- Expo Router (file-based routing)
- NativeWind (Tailwind for React Native)
- Zustand (state management)
- React Query (data fetching)
- @myapp/shared (共有API/types)

**依存**: `@myapp/shared` package

### packages/shared/ - Shared Package

**役割**: WebとMobileで共有するTypeScriptコード

**含まれるもの**:
- **API Clients**: `ApiClient`, `AuthApi`
- **Types**: `User`, `Organization`, `ApiResponse`
- **Validators**: Zodスキーマ (`loginSchema`, `signupSchema`)
- **Utils**: 共通ユーティリティ関数

**依存**: axios, zod

## 🚀 セットアップ

### 前提条件

- **Ruby 3.2.2**
- **Node.js 20+**
- **pnpm 9.0.0**
- **PostgreSQL 16+**

### インストール

```bash
# プロジェクトルートで
pnpm install

# これで全てのworkspaceの依存関係がインストールされる
# - mobile/
# - packages/shared/
# - web/ (JavaScriptのみ、Rubyはbundle installで)

# Rails gems
cd web && bundle install
```

## 🛠️ 開発ワークフロー

### 全体のビルド

```bash
# ルートディレクトリで
pnpm build

# 個別にビルド
pnpm build:web      # Webアセット
pnpm build:shared   # Shared packageのTypeScript
```

### Linter実行

```bash
# 全てのworkspaceでLint
pnpm lint

# 個別に実行
pnpm lint:web       # Web (ESLint + RuboCop + HAML-Lint)
pnpm lint:mobile    # Mobile (ESLint)
pnpm lint:shared    # Shared (ESLint)
```

### 型チェック

```bash
# 全てのworkspaceで型チェック
pnpm type-check
```

### テスト

```bash
# 全てのテスト
pnpm test

# 個別
cd web && bundle exec rspec           # Rails tests
pnpm --filter mobile test             # Mobile tests
pnpm --filter @myapp/shared test      # Shared tests
```

### 開発サーバー

```bash
# Web development server
pnpm dev
# または
cd web && bin/dev

# Mobile development server
pnpm mobile:start
# または
pnpm --filter mobile start

# iOSシミュレータで起動
pnpm mobile:ios

# Androidエミュレータで起動
pnpm mobile:android
```

## 📝 workspaceコマンドの使い方

### 特定のworkspaceでコマンド実行

```bash
# Filterオプションを使用
pnpm --filter mobile <command>
pnpm --filter @myapp/shared <command>
pnpm --filter web <command>

# 例
pnpm --filter mobile start
pnpm --filter @myapp/shared build
pnpm --filter mobile lint:fix
```

### 全workspaceでコマンド実行

```bash
# -rはrecursive（全workspace）
pnpm -r <command>

# 例
pnpm -r build
pnpm -r lint
pnpm -r type-check
```

## 🔄 shared packageの使い方

### packages/shared からエクスポート

```typescript
// packages/shared/src/index.ts
export { ApiClient } from './api/client';
export { AuthApi } from './api/auth';
export type { User, Organization } from './types';
export { loginSchema } from './validators/auth';
```

### Web で使用

```typescript
// web/app/javascript/auth/login.ts
import { ApiClient, AuthApi, loginSchema } from '@myapp/shared';

const client = new ApiClient({
  baseURL: window.location.origin,
  onTokenRefresh: async () => {
    const token = localStorage.getItem('refreshToken');
    // Refresh logic
    return newToken;
  },
});

const authApi = new AuthApi(client);
const response = await authApi.login({ email, password });
```

### Mobile で使用

```typescript
// mobile/src/store/auth.ts
import { ApiClient, AuthApi } from '@myapp/shared';
import * as SecureStore from 'expo-secure-store';

const client = new ApiClient({
  baseURL: 'http://localhost:3000',
  onTokenRefresh: async () => {
    const token = await SecureStore.getItemAsync('refreshToken');
    // Refresh logic
    return newToken;
  },
});

const authApi = new AuthApi(client);
```

## 🧩 新しいAPIの追加

### 1. packages/shared に型とAPIを追加

```typescript
// packages/shared/src/types/index.ts
export interface Post {
  id: number;
  title: string;
  body: string;
  userId: number;
}

// packages/shared/src/api/posts.ts
import { ApiClient } from './client';
import type { Post, PaginatedResponse } from '../types';

export class PostsApi {
  constructor(private client: ApiClient) {}

  async list(page = 1) {
    return this.client.get<PaginatedResponse<Post>>(`/api/v1/posts?page=${page}`);
  }

  async get(id: number) {
    return this.client.get<Post>(`/api/v1/posts/${id}`);
  }

  async create(data: Partial<Post>) {
    return this.client.post<Post>('/api/v1/posts', data);
  }
}

// packages/shared/src/index.ts
export { PostsApi } from './api/posts';
export type { Post } from './types';
```

### 2. Railsでエンドポイント実装

```ruby
# web/app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < Api::V1::BaseController
  def index
    @posts = policy_scope(Post).page(params[:page])
    render json: {
      data: @posts,
      meta: pagination_meta(@posts)
    }
  end

  def show
    @post = Post.find(params[:id])
    authorize @post
    render json: { data: @post }
  end
end
```

### 3. WebとMobileで使用

```typescript
// Both web and mobile
import { PostsApi } from '@myapp/shared';

const postsApi = new PostsApi(apiClient);
const response = await postsApi.list(1);

if (response.success) {
  console.log(response.data.data); // posts array
}
```

## 🔧 トラブルシューティング

### workspace間の依存関係エラー

```bash
# workspaceを再インストール
pnpm install

# キャッシュをクリア
pnpm store prune

# node_modulesを削除して再インストール
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

### sharedパッケージの変更が反映されない

```bash
# sharedをビルド
pnpm --filter @myapp/shared build

# または watch mode
pnpm --filter @myapp/shared build --watch
```

### TypeScript型エラー

```bash
# 全workspaceで型チェック
pnpm type-check

# 個別に確認
pnpm --filter mobile type-check
pnpm --filter @myapp/shared type-check
```

## 📚 関連ドキュメント

- **QUICK_START.md** - 5分でセットアップ
- **PROJECT_TEMPLATE.md** - 完全なセットアップガイド
- **packages/shared/README.md** - Shared packageの詳細
- **mobile/README.md** - Mobileアプリの詳細 (TODO)

## 💡 ベストプラクティス

1. **型は必ずsharedで定義** - 重複を避ける
2. **APIクライアントはsharedで統一** - 一貫性を保つ
3. **バリデーションもsharedで共有** - フロントとバックで同じルール
4. **sharedの変更はテストを書く** - WebとMobile両方に影響
5. **workspace間の循環依存は避ける** - webはsharedに依存しない

---

**Rails 8 Solid Starter Monorepo** - Web + Mobile の統合開発環境
