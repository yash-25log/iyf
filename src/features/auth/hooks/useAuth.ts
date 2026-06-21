'use client'

import { useAuthStore } from '@/shared/store/authStore'
import { type Role } from '@/shared/constants/roles'

/**
 * useAuth — convenience hook that reads from the Zustand auth store.
 * Use this in Client Components for all auth/role checks.
 */
export function useAuth() {
  const { user, profile, isLoading, role, can, isAdmin, isSuperAdmin } =
    useAuthStore()

  return {
    user,
    profile,
    isLoading,
    role,
    isAuthenticated: !!user,
    /** True if user has at least the given minimum role */
    can: (minimumRole: Role) => can(minimumRole),
    isAdmin: isAdmin(),
    isSuperAdmin: isSuperAdmin(),
  }
}
