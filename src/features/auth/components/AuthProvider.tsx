'use client'

import { useEffect } from 'react'
import { createClient } from '@/shared/lib/supabase/client'
import { useAuthStore } from '@/shared/store/authStore'
import type { Profile } from '@/shared/types'

/**
 * AuthProvider — mounts once at the dashboard layout level.
 *
 * Responsibilities:
 * - Hydrates the Zustand auth store with the current session and profile.
 * - Subscribes to onAuthStateChange to keep the store in sync.
 */
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const { setUser, setSession, setProfile, setLoading, reset } = useAuthStore()

  useEffect(() => {
    const supabase = createClient()

    async function fetchProfile(userId: string) {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single()
      setProfile(data as Profile | null)
    }

    // Initial session hydration
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      if (session?.user) {
        fetchProfile(session.user.id).finally(() => setLoading(false))
      } else {
        setLoading(false)
      }
    })

    // Subscribe to future auth events
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
      if (session?.user) {
        fetchProfile(session.user.id)
      } else {
        reset()
      }
    })

    return () => subscription.unsubscribe()
  }, [setUser, setSession, setProfile, setLoading, reset])

  return <>{children}</>
}
