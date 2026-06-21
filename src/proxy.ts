import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'
import { ROLES } from '@/shared/constants/roles'

/**
 * Next.js Proxy (formerly Middleware) — runs on every matched request.
 *
 * Responsibilities:
 * 1. Refresh the Supabase session cookie (keeps JWT alive).
 * 2. Redirect unauthenticated users to /login.
 * 3. Redirect authenticated users away from /login.
 * 4. Guard /admin routes to ADMIN+ roles only.
 *
 * Note: In Next.js 16, this file is `proxy.ts` (renamed from `middleware.ts`).
 * The exported function must be named `proxy`.
 */
export async function proxy(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Refresh session — must not write any cookies after this point
  const {
    data: { user },
  } = await supabase.auth.getUser()

  const { pathname } = request.nextUrl

  // ── Redirect logged-in users away from /login ───────────────────────────
  if (user && pathname === '/login') {
    return NextResponse.redirect(new URL('/', request.url))
  }

  // ── Require authentication for all non-login routes ─────────────────────
  if (!user && pathname !== '/login') {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // ── Guard /admin routes to ADMIN and SUPER_ADMIN only ───────────────────
  if (user && pathname.startsWith('/admin')) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    const adminRoles: string[] = [ROLES.ADMIN, ROLES.SUPER_ADMIN]
    if (!profile || !adminRoles.includes(profile.role)) {
      return NextResponse.redirect(new URL('/', request.url))
    }
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico, sitemap.xml, robots.txt
     * - public files with extensions
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
