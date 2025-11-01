import axios, { AxiosInstance, AxiosRequestConfig, AxiosError } from 'axios';
import type { ApiError, ApiResponse } from '../types';

export interface ApiClientConfig {
  baseURL: string;
  timeout?: number;
  onTokenRefresh?: () => Promise<string>;
  onAuthError?: () => void;
}

export class ApiClient {
  private client: AxiosInstance;
  private config: ApiClientConfig;

  constructor(config: ApiClientConfig) {
    this.config = config;
    this.client = axios.create({
      baseURL: config.baseURL,
      timeout: config.timeout || 30000,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors() {
    // Request interceptor - add auth token
    this.client.interceptors.request.use(
      async (config) => {
        const token = await this.getAccessToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor - handle errors
    this.client.interceptors.response.use(
      (response) => response,
      async (error: AxiosError) => {
        const originalRequest = error.config as AxiosRequestConfig & {
          _retry?: boolean;
        };

        // Handle 401 Unauthorized
        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true;

          try {
            // Try to refresh token
            if (this.config.onTokenRefresh) {
              const newToken = await this.config.onTokenRefresh();
              if (newToken && originalRequest.headers) {
                originalRequest.headers.Authorization = `Bearer ${newToken}`;
                return this.client(originalRequest);
              }
            }
          } catch (refreshError) {
            // Token refresh failed
            if (this.config.onAuthError) {
              this.config.onAuthError();
            }
            return Promise.reject(refreshError);
          }
        }

        return Promise.reject(this.formatError(error));
      }
    );
  }

  private formatError(error: AxiosError): ApiError {
    if (error.response) {
      // Server responded with error
      const data = error.response.data as { message?: string; errors?: Record<string, string[]> };
      return {
        message: data.message || 'An error occurred',
        errors: data.errors,
        statusCode: error.response.status,
      };
    } else if (error.request) {
      // Request made but no response
      return {
        message: 'No response from server',
        statusCode: 0,
      };
    } else {
      // Error setting up request
      return {
        message: error.message || 'Request failed',
        statusCode: 0,
      };
    }
  }

  private async getAccessToken(): Promise<string | null> {
    // Override this method in subclass to implement token storage
    // For web: localStorage.getItem('accessToken')
    // For mobile: SecureStore.getItemAsync('accessToken')
    return null;
  }

  // HTTP Methods
  async get<T>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.get<T>(url, config);
      return { success: true, data: response.data };
    } catch (error) {
      return { success: false, error: error as ApiError };
    }
  }

  async post<T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.post<T>(url, data, config);
      return { success: true, data: response.data };
    } catch (error) {
      return { success: false, error: error as ApiError };
    }
  }

  async put<T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.put<T>(url, data, config);
      return { success: true, data: response.data };
    } catch (error) {
      return { success: false, error: error as ApiError };
    }
  }

  async patch<T>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.patch<T>(url, data, config);
      return { success: true, data: response.data };
    } catch (error) {
      return { success: false, error: error as ApiError };
    }
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    try {
      const response = await this.client.delete<T>(url, config);
      return { success: true, data: response.data };
    } catch (error) {
      return { success: false, error: error as ApiError };
    }
  }

  // Set base URL dynamically
  setBaseURL(baseURL: string) {
    this.client.defaults.baseURL = baseURL;
  }

  // Get underlying axios instance for advanced usage
  getClient(): AxiosInstance {
    return this.client;
  }
}
