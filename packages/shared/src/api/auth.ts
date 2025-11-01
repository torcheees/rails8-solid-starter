import { ApiClient } from './client';
import type { AuthResponse, User } from '../types';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignupCredentials extends LoginCredentials {
  name?: string;
  organizationName?: string;
}

export class AuthApi {
  constructor(private client: ApiClient) {}

  async login(credentials: LoginCredentials) {
    return this.client.post<AuthResponse>('/api/v1/auth/login', credentials);
  }

  async signup(credentials: SignupCredentials) {
    return this.client.post<AuthResponse>('/api/v1/auth/signup', credentials);
  }

  async logout() {
    return this.client.post<void>('/api/v1/auth/logout');
  }

  async refreshToken(refreshToken: string) {
    return this.client.post<{ accessToken: string; refreshToken: string }>('/api/v1/auth/refresh', {
      refreshToken,
    });
  }

  async getCurrentUser() {
    return this.client.get<User>('/api/v1/auth/me');
  }

  async updateProfile(data: Partial<User>) {
    return this.client.patch<User>('/api/v1/auth/profile', data);
  }

  async changePassword(currentPassword: string, newPassword: string) {
    return this.client.post<void>('/api/v1/auth/change-password', {
      currentPassword,
      newPassword,
    });
  }

  async requestPasswordReset(email: string) {
    return this.client.post<void>('/api/v1/auth/forgot-password', { email });
  }

  async resetPassword(token: string, newPassword: string) {
    return this.client.post<void>('/api/v1/auth/reset-password', {
      token,
      newPassword,
    });
  }
}
