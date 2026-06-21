import type { Profile } from '@/shared/types'

/** Profile with email (available in admin contexts) */
export interface UserWithEmail extends Profile {
  email: string | null
}

export interface UpdateUserRolePayload {
  role: string
}

export interface UpdateUserStatusPayload {
  is_active: boolean
}
