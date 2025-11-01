import { create } from 'zustand';
import * as SecureStore from 'expo-secure-store';
import { ApiClient, AuthApi, type User, type Organization } from '@myapp/shared';

interface AuthState {
  user: User | null;
  organizations: Organization[];
  currentOrganization: Organization | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  setCurrentOrganization: (org: Organization) => void;
  refreshUser: () => Promise<void>;
}

// API Client setup
const apiClient = new ApiClient({
  baseURL: process.env.EXPO_PUBLIC_API_URL || 'http://localhost:3000',
  onTokenRefresh: async () => {
    const refreshToken = await SecureStore.getItemAsync('refreshToken');
    if (!refreshToken) throw new Error('No refresh token');

    const authApi = new AuthApi(apiClient);
    const response = await authApi.refreshToken(refreshToken);

    if (response.success) {
      await SecureStore.setItemAsync('accessToken', response.data.accessToken);
      await SecureStore.setItemAsync('refreshToken', response.data.refreshToken);
      return response.data.accessToken;
    }

    throw new Error('Token refresh failed');
  },
  onAuthError: async () => {
    await SecureStore.deleteItemAsync('accessToken');
    await SecureStore.deleteItemAsync('refreshToken');
    useAuthStore.getState().logout();
  },
});

const authApi = new AuthApi(apiClient);

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  organizations: [],
  currentOrganization: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,

  login: async (email, password) => {
    set({ isLoading: true, error: null });

    try {
      const response = await authApi.login({ email, password });

      if (response.success) {
        const { accessToken, refreshToken, user, organizations } = response.data;

        // Save tokens
        await SecureStore.setItemAsync('accessToken', accessToken);
        await SecureStore.setItemAsync('refreshToken', refreshToken);

        set({
          user,
          organizations,
          currentOrganization: organizations[0] || null,
          isAuthenticated: true,
          isLoading: false,
        });
      } else {
        set({
          error: response.error.message,
          isLoading: false,
        });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Login failed',
        isLoading: false,
      });
    }
  },

  logout: async () => {
    try {
      await authApi.logout();
    } catch (error) {
      console.error('Logout error:', error);
    } finally {
      await SecureStore.deleteItemAsync('accessToken');
      await SecureStore.deleteItemAsync('refreshToken');

      set({
        user: null,
        organizations: [],
        currentOrganization: null,
        isAuthenticated: false,
        error: null,
      });
    }
  },

  setCurrentOrganization: (org) => {
    set({ currentOrganization: org });
  },

  refreshUser: async () => {
    set({ isLoading: true });

    try {
      const response = await authApi.getCurrentUser();

      if (response.success) {
        set({
          user: response.data,
          isLoading: false,
        });
      } else {
        set({
          error: response.error.message,
          isLoading: false,
        });
      }
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to refresh user',
        isLoading: false,
      });
    }
  },
}));

export { apiClient, authApi };
