# @myapp/shared

Shared TypeScript package for web and mobile applications.

## Features

- **API Client**: Type-safe API client with automatic token refresh
- **Type Definitions**: Shared TypeScript interfaces
- **Validators**: Zod schemas for runtime validation
- **Authentication**: Complete auth API integration

## Installation

This package is part of the monorepo and automatically installed with `pnpm install`.

## Usage

### In Web Application

```typescript
import { ApiClient, AuthApi, loginSchema } from '@myapp/shared';

// Create API client
const client = new ApiClient({
  baseURL: 'http://localhost:3000',
  onTokenRefresh: async () => {
    const refreshToken = localStorage.getItem('refreshToken');
    // Implement token refresh logic
    return newAccessToken;
  },
  onAuthError: () => {
    // Redirect to login
    window.location.href = '/login';
  },
});

// Use auth API
const authApi = new AuthApi(client);
const response = await authApi.login({ email, password });

// Validate input
const result = loginSchema.safeParse({ email, password });
if (!result.success) {
  console.error(result.error.errors);
}
```

### In Mobile Application (React Native)

```typescript
import { ApiClient, AuthApi } from '@myapp/shared';
import * as SecureStore from 'expo-secure-store';

// Create API client
const client = new ApiClient({
  baseURL: 'http://localhost:3000',
  onTokenRefresh: async () => {
    const refreshToken = await SecureStore.getItemAsync('refreshToken');
    // Implement token refresh logic
    return newAccessToken;
  },
  onAuthError: () => {
    // Navigate to login screen
    navigation.navigate('Login');
  },
});

// Use auth API
const authApi = new AuthApi(client);
const response = await authApi.login({ email, password });
```

## Structure

```
src/
├── api/              # API clients
│   ├── client.ts     # Base API client
│   └── auth.ts       # Authentication API
├── types/            # TypeScript type definitions
│   └── index.ts      # Shared types
├── validators/       # Zod validation schemas
│   └── auth.ts       # Auth validators
└── index.ts          # Package exports
```

## Development

```bash
# Type checking
pnpm --filter @myapp/shared type-check

# Build
pnpm --filter @myapp/shared build

# Lint
pnpm --filter @myapp/shared lint

# Tests
pnpm --filter @myapp/shared test
```

## Adding New APIs

1. Create a new API class in `src/api/`
2. Add types in `src/types/`
3. Add validators in `src/validators/`
4. Export from `src/index.ts`

Example:

```typescript
// src/api/posts.ts
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
```

## Benefits

- **Code Reuse**: Share API logic between web and mobile
- **Type Safety**: Full TypeScript support
- **Consistency**: Same API behavior across platforms
- **Validation**: Runtime validation with Zod
- **Testing**: Centralized testing for shared logic
