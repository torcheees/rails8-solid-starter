// Shared TypeScript types for web and mobile

export interface User {
  id: number;
  email: string;
  name?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Organization {
  id: number;
  name: string;
  subdomain: string;
  planType: 'free' | 'starter' | 'professional' | 'business' | 'enterprise';
  createdAt: string;
  updatedAt: string;
}

export interface Membership {
  id: number;
  userId: number;
  organizationId: number;
  role: 'owner' | 'admin' | 'member' | 'viewer';
  createdAt: string;
  updatedAt: string;
  user?: User;
  organization?: Organization;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
  organizations: Organization[];
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
  statusCode: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    currentPage: number;
    totalPages: number;
    totalCount: number;
    perPage: number;
  };
}

export interface ApiSuccessResponse<T = unknown> {
  success: true;
  data: T;
}

export interface ApiErrorResponse {
  success: false;
  error: ApiError;
}

export type ApiResponse<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse;
