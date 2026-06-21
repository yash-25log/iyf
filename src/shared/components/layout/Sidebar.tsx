'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  BookOpen,
  Home,
  Search,
  Bookmark,
  FolderOpen,
  FileText,
  Users,
  Layers,
  Settings,
} from 'lucide-react'

import { cn } from '@/lib/utils'
import { useAuth } from '@/features/auth/hooks/useAuth'
import { ROLES } from '@/shared/constants/roles'
import { Separator } from '@/components/ui/separator'

interface NavItem {
  label: string
  href: string
  icon: React.ElementType
}

const mainNav: NavItem[] = [
  { label: 'Home', href: '/', icon: Home },
  { label: 'Search', href: '/search', icon: Search },
  { label: 'Topics', href: '/topics', icon: FileText },
  { label: 'Categories', href: '/categories', icon: FolderOpen },
  { label: 'Bookmarks', href: '/bookmarks', icon: Bookmark },
]

const adminNav: NavItem[] = [
  { label: 'Users', href: '/admin/users', icon: Users },
  { label: 'Batches', href: '/admin/batches', icon: Layers },
  { label: 'Categories', href: '/admin/categories', icon: Settings },
]

function NavLink({ item }: { item: NavItem }) {
  const pathname = usePathname()
  const isActive =
    item.href === '/' ? pathname === '/' : pathname.startsWith(item.href)

  return (
    <Link
      href={item.href}
      className={cn(
        'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-all duration-150',
        isActive
          ? 'bg-primary text-primary-foreground shadow-sm'
          : 'text-muted-foreground hover:bg-muted hover:text-foreground'
      )}
    >
      <item.icon className="h-4 w-4 shrink-0" />
      <span>{item.label}</span>
    </Link>
  )
}

export function Sidebar() {
  const { isAdmin } = useAuth()

  return (
    <aside
      id="sidebar"
      className="hidden md:flex flex-col w-60 border-r border-border/60 bg-card/50 shrink-0"
    >
      {/* Logo */}
      <div className="flex h-14 items-center gap-2.5 px-4 border-b border-border/60">
        <div className="flex h-7 w-7 items-center justify-center rounded-md bg-primary text-primary-foreground">
          <BookOpen className="h-4 w-4" />
        </div>
        <div className="leading-tight">
          <p className="text-sm font-semibold tracking-tight">IYF</p>
          <p className="text-[10px] text-muted-foreground">Preacher&apos;s Zone</p>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto p-3 space-y-1">
        {mainNav.map((item) => (
          <NavLink key={item.href} item={item} />
        ))}

        {/* Admin section */}
        {isAdmin && (
          <>
            <Separator className="my-3" />
            <p className="px-3 pb-1 text-[10px] font-semibold uppercase tracking-widest text-muted-foreground">
              Admin
            </p>
            {adminNav.map((item) => (
              <NavLink key={item.href} item={item} />
            ))}
          </>
        )}
      </nav>

      {/* Footer spacer */}
      <div className="h-4" />
    </aside>
  )
}
