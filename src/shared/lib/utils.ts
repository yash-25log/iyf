// cn is owned by Shadcn at @/lib/utils — re-export to keep a single source
export { cn } from '@/lib/utils'

/** Convert a string to a URL-safe slug */
export function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

/** Format a date string to a readable format */
export function formatDate(dateString: string | null | undefined): string {
  if (!dateString) return '—'
  return new Date(dateString).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  })
}

/** Build a standard success API response */
export function apiSuccess<T>(
  data: T,
  meta?: { total: number; page: number; limit: number }
): Response {
  const body = meta
    ? {
        data,
        meta: {
          ...meta,
          totalPages: Math.ceil(meta.total / meta.limit),
        },
      }
    : { data }
  return Response.json(body, { status: 200 })
}

/** Build a standard error API response */
export function apiError(
  code: string,
  message: string,
  status: number = 400
): Response {
  return Response.json({ error: { code, message } }, { status })
}

/** Parse and validate pagination query params with safe defaults */
export function parsePagination(searchParams: URLSearchParams): {
  page: number
  limit: number
  offset: number
  sort: string
  order: 'asc' | 'desc'
} {
  const page = Math.max(1, parseInt(searchParams.get('page') ?? '1', 10))
  const limit = Math.min(
    100,
    Math.max(1, parseInt(searchParams.get('limit') ?? '20', 10))
  )
  const sort = searchParams.get('sort') ?? 'created_at'
  const rawOrder = searchParams.get('order') ?? 'desc'
  const order: 'asc' | 'desc' = rawOrder === 'asc' ? 'asc' : 'desc'

  return { page, limit, offset: (page - 1) * limit, sort, order }
}
