import { createBrowserClient } from '@supabase/ssr'

/**
 * Supabase client for use in Client Components (browser context).
 * Creates a new instance per call — singleton pattern not needed
 * since @supabase/ssr handles this internally.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
