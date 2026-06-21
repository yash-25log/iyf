import type { UserWithEmail } from './types'
import type { ApiSuccess, PaginationMeta } from '@/shared/types'

const BASE = '/api/v1/users'

/** GET /api/v1/users — list all users (Super Admin only) */
export async function fetchUsers(params?: {
  page?: number
  limit?: number
  search?: string
}): Promise<{ data: UserWithEmail[]; meta: PaginationMeta }> {
  const query = new URLSearchParams()
  if (params?.page) query.set('page', String(params.page))
  if (params?.limit) query.set('limit', String(params.limit))
  if (params?.search) query.set('search', params.search)

  const res = await fetch(`${BASE}?${query}`)
  if (!res.ok) throw new Error(`Failed to fetch users: ${res.status}`)
  const json: ApiSuccess<UserWithEmail[]> = await res.json()
  return {
    data: json.data,
    meta: json.meta!,
  }
}

/** PATCH /api/v1/users/:id — update role or status */
export async function updateUser(
  id: string,
  payload: { role?: string; is_active?: boolean }
): Promise<UserWithEmail> {
  const res = await fetch(`${BASE}/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })
  if (!res.ok) {
    const err = await res.json()
    throw new Error(err?.error?.message ?? 'Failed to update user')
  }
  const json: ApiSuccess<UserWithEmail> = await res.json()
  return json.data
}
