import { createClient } from '@/shared/lib/supabase/server'
import type { Profile } from '@/shared/types'
import { apiError } from '@/shared/lib/utils'
import { type Role, hasMinimumRole } from '@/shared/constants/roles'

/**
 * Resolves the current authenticated user + their profile.
 *
 * Usage in Route Handlers:
 * ```ts
 * const authResult = await requireAuth()
 * if (authResult instanceof Response) return authResult  // 401
 * const { user, profile } = authResult
 * ```
 */
export async function requireAuth(): Promise<
  { user: { id: string }; profile: Profile } | Response
> {
  const supabase = await createClient()

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return apiError('UNAUTHORIZED', 'Authentication required', 401)
  }

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()

  if (profileError || !profile) {
    return apiError('UNAUTHORIZED', 'Profile not found', 401)
  }

  if (!profile.is_active) {
    return apiError('FORBIDDEN', 'Your account has been deactivated', 403)
  }

  return { user, profile: profile as Profile }
}

/**
 * Resolves the current user + requires a minimum role.
 *
 * Usage:
 * ```ts
 * const authResult = await requireRole(ROLES.ADMIN)
 * if (authResult instanceof Response) return authResult  // 401 or 403
 * const { profile } = authResult
 * ```
 */
export async function requireRole(
  minimumRole: Role
): Promise<{ user: { id: string }; profile: Profile } | Response> {
  const authResult = await requireAuth()
  if (authResult instanceof Response) return authResult

  const { profile } = authResult

  if (!hasMinimumRole(profile.role as Role, minimumRole)) {
    return apiError(
      'FORBIDDEN',
      `This action requires ${minimumRole} or higher`,
      403
    )
  }

  return authResult
}
