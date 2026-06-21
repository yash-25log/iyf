import { create } from 'zustand'
import type { User, Session } from '@supabase/supabase-js'
import type { Profile } from '@/shared/types'
import { type Role, ROLES, hasMinimumRole } from '@/shared/constants/roles'

interface AuthState {
  user: User | null
  session: Session | null
  profile: Profile | null
  isLoading: boolean

  // Actions
  setUser: (user: User | null) => void
  setSession: (session: Session | null) => void
  setProfile: (profile: Profile | null) => void
  setLoading: (loading: boolean) => void
  reset: () => void

  // RBAC helpers
  role: Role | null
  can: (minimumRole: Role) => boolean
  isAdmin: () => boolean
  isSuperAdmin: () => boolean
}

const initialState = {
  user: null,
  session: null,
  profile: null,
  isLoading: true,
  role: null,
}

export const useAuthStore = create<AuthState>((set, get) => ({
  ...initialState,

  setUser: (user) => set({ user }),
  setSession: (session) => set({ session }),
  setProfile: (profile) =>
    set({
      profile,
      role: profile?.role ?? null,
    }),
  setLoading: (isLoading) => set({ isLoading }),
  reset: () => set(initialState),

  /** Returns true if the current user has at least the given minimum role */
  can: (minimumRole: Role) => {
    const role = get().role
    if (!role) return false
    return hasMinimumRole(role, minimumRole)
  },

  isAdmin: () => {
    const role = get().role
    if (!role) return false
    return hasMinimumRole(role, ROLES.ADMIN)
  },

  isSuperAdmin: () => {
    return get().role === ROLES.SUPER_ADMIN
  },
}))
