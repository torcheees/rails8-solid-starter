import { useAuthStore } from '@/store/auth';

/**
 * Custom hook for authentication
 * Provides easy access to auth state and actions
 */
export function useAuth() {
  const {
    user,
    organizations,
    currentOrganization,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    setCurrentOrganization,
    refreshUser,
  } = useAuthStore();

  return {
    // State
    user,
    organizations,
    currentOrganization,
    isAuthenticated,
    isLoading,
    error,

    // Actions
    login,
    logout,
    setCurrentOrganization,
    refreshUser,

    // Helper functions
    isOwner: currentOrganization
      ? user?.memberships?.some(
          (m) =>
            m.organizationId === currentOrganization.id &&
            m.role === 'owner'
        ) || false
      : false,

    isAdmin: currentOrganization
      ? user?.memberships?.some(
          (m) =>
            m.organizationId === currentOrganization.id &&
            (m.role === 'owner' || m.role === 'admin')
        ) || false
      : false,

    isMember: currentOrganization
      ? user?.memberships?.some(
          (m) => m.organizationId === currentOrganization.id
        ) || false
      : false,
  };
}
