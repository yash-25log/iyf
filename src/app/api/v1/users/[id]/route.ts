import { type NextRequest } from 'next/server'
import { createClient } from '@/shared/lib/supabase/server'
import { requireRole } from '@/shared/lib/supabase/auth'
import { ROLES } from '@/shared/constants/roles'
import { apiSuccess, apiError } from '@/shared/lib/utils'

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const auth = await requireRole(ROLES.SUPER_ADMIN)
  if (auth instanceof Response) return auth

  const { id } = await params
  const body = await request.json()

  const { role, is_active } = body
  const updates: Record<string, any> = {
    updated_at: new Date().toISOString(),
    updated_by: auth.profile.id,
  }

  if (role !== undefined) {
    if (!Object.values(ROLES).includes(role)) {
      return apiError('INVALID_INPUT', 'Invalid role specified', 400)
    }
    updates.role = role
  }

  if (is_active !== undefined) {
    if (typeof is_active !== 'boolean') {
      return apiError('INVALID_INPUT', 'is_active must be a boolean', 400)
    }
    if (id === auth.profile.id && !is_active) {
      return apiError('FORBIDDEN', 'You cannot deactivate your own account', 403)
    }
    updates.is_active = is_active
  }

  if (role === undefined && is_active === undefined) {
    return apiError('INVALID_INPUT', 'No fields to update', 400)
  }

  const supabase = await createClient()
  const { data, error } = await supabase
    .from('profiles')
    .update(updates)
    .eq('id', id)
    .select()
    .single()

  if (error) {
    return apiError('DATABASE_ERROR', error.message, 500)
  }

  return apiSuccess(data)
}
