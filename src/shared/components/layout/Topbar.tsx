'use client'

import { useRouter } from 'next/navigation'
import { LogOut, User, ChevronDown } from 'lucide-react'
import { toast } from 'sonner'

import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Badge } from '@/components/ui/badge'
import { createClient } from '@/shared/lib/supabase/client'
import { useAuth } from '@/features/auth/hooks/useAuth'
import { useAuthStore } from '@/shared/store/authStore'

const ROLE_LABELS: Record<string, string> = {
  SUPER_ADMIN: 'Super Admin',
  ADMIN: 'Admin',
  PREACHER: 'Preacher',
  USER: 'User',
}

export function Topbar() {
  const { profile, role } = useAuth()
  const reset = useAuthStore((s) => s.reset)
  const router = useRouter()

  async function handleSignOut() {
    const supabase = createClient()
    await supabase.auth.signOut()
    reset()
    toast.success('Signed out')
    router.push('/login')
  }

  const initials = profile?.full_name
    ? profile.full_name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    : '?'

  return (
    <header
      id="topbar"
      className="flex h-14 items-center justify-end gap-3 border-b border-border/60 bg-card/50 px-4 md:px-6 shrink-0"
    >
      {/* Role badge */}
      {role && (
        <Badge variant="secondary" className="text-xs hidden sm:inline-flex">
          {ROLE_LABELS[role] ?? role}
        </Badge>
      )}

      {/* User menu */}
      <DropdownMenu>
        <DropdownMenuTrigger
          id="user-menu-trigger"
          className="flex items-center gap-2 rounded-md px-2 py-1 hover:bg-muted transition-colors outline-none"
        >
          <Avatar className="h-7 w-7">
            <AvatarFallback className="text-xs bg-primary text-primary-foreground">
              {initials}
            </AvatarFallback>
          </Avatar>
          <span className="hidden sm:block text-sm font-medium truncate max-w-32">
            {profile?.full_name ?? 'Loading…'}
          </span>
          <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
        </DropdownMenuTrigger>

        <DropdownMenuContent align="end" className="w-52">
          <div className="px-3 py-2 text-xs font-normal">
            <div className="flex flex-col gap-0.5">
              <span className="font-medium text-sm text-foreground">{profile?.full_name}</span>
              <span className="text-xs text-muted-foreground truncate">
                {ROLE_LABELS[role ?? ''] ?? role}
              </span>
            </div>
          </div>
          <DropdownMenuSeparator />
          <DropdownMenuItem id="profile-menu-item">
            <User className="mr-2 h-4 w-4" />
            My Profile
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            id="sign-out-menu-item"
            className="text-destructive focus:text-destructive"
            onClick={handleSignOut}
          >
            <LogOut className="mr-2 h-4 w-4" />
            Sign out
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  )
}
