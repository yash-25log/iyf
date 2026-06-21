import { type NextRequest } from 'next/server'
import { createClient } from '@/shared/lib/supabase/server'
import { requireRole } from '@/shared/lib/supabase/auth'
import { ROLES } from '@/shared/constants/roles'
import { apiSuccess, apiError, parsePagination } from '@/shared/lib/utils'

export async function GET(request: NextRequest) {
  const auth = await requireRole(ROLES.SUPER_ADMIN)
  if (auth instanceof Response) return auth

  const supabase = await createClient()
  const { searchParams } = request.nextUrl
  const { page, limit, offset, sort, order } = parsePagination(searchParams)
  const search = searchParams.get('search')

  let query = supabase
    .from('profiles')
    .select('*', { count: 'exact' })

  if (search) {
    query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%`)
  }

  // Handle sorting
  const validSortColumns = ['full_name', 'email', 'role', 'is_active', 'created_at']
  const sortColumn = validSortColumns.includes(sort) ? sort : 'created_at'

  query = query
    .order(sortColumn, { ascending: order === 'asc' })
    .range(offset, offset + limit - 1)

  const { data, error, count } = await query

  if (error) {
    return apiError('DATABASE_ERROR', error.message, 500)
  }

  return apiSuccess(data || [], {
    total: count || 0,
    page,
    limit,
  })
}
