'use client'

import { type UserWithEmail } from '../types'
import { ROLES, type Role } from '@/shared/constants/roles'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { MoreHorizontal, Shield, UserX, UserCheck, Edit2 } from 'lucide-react'
import { formatDate } from '@/shared/lib/utils'

interface UserListTableProps {
  users: UserWithEmail[]
  currentUserId?: string
  onUpdateUser: (id: string, payload: { role?: string; is_active?: boolean }) => void
  isUpdating: boolean
}

const ROLE_LABELS: Record<Role, string> = {
  [ROLES.SUPER_ADMIN]: 'Super Admin',
  [ROLES.ADMIN]: 'Admin',
  [ROLES.PREACHER]: 'Preacher',
  [ROLES.USER]: 'User',
}

const ROLE_BADGE_VARIANTS: Record<Role, string> = {
  [ROLES.SUPER_ADMIN]: 'bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/20 hover:bg-purple-500/15',
  [ROLES.ADMIN]: 'bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/20 hover:bg-blue-500/15',
  [ROLES.PREACHER]: 'bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/20 hover:bg-amber-500/15',
  [ROLES.USER]: 'bg-slate-500/10 text-slate-600 dark:text-slate-400 border-slate-500/20 hover:bg-slate-500/15',
}

export function UserListTable({
  users,
  currentUserId,
  onUpdateUser,
  isUpdating,
}: UserListTableProps) {
  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .slice(0, 2)
      .join('')
      .toUpperCase()
  }

  return (
    <div className="rounded-xl border border-border/50 bg-card overflow-hidden shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-border/60 bg-muted/40 text-muted-foreground text-xs font-semibold uppercase tracking-wider">
              <th className="px-6 py-4">User</th>
              <th className="px-6 py-4">Role</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Joined Date</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border/40 text-sm">
            {users.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-12 text-center text-muted-foreground">
                  No users found.
                </td>
              </tr>
            ) : (
              users.map((user) => {
                const isSelf = user.id === currentUserId
                return (
                  <tr
                    key={user.id}
                    className="hover:bg-muted/30 transition-colors duration-150 group"
                  >
                    {/* User Info */}
                    <td className="px-6 py-4.5">
                      <div className="flex items-center gap-3">
                        <Avatar className="h-9 w-9 border border-border/60">
                          <AvatarImage src={user.avatar_url || undefined} alt={user.full_name} />
                          <AvatarFallback className="bg-primary/5 text-primary text-xs font-semibold">
                            {getInitials(user.full_name || 'User')}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex flex-col min-w-0">
                          <span className="font-medium text-foreground truncate max-w-[200px]">
                            {user.full_name || 'Anonymous User'}
                            {isSelf && (
                              <span className="ml-1.5 rounded-md bg-primary/10 px-1.5 py-0.5 text-[10px] font-semibold text-primary">
                                You
                              </span>
                            )}
                          </span>
                          <span className="text-xs text-muted-foreground truncate max-w-[200px]">
                            {user.email || 'No email'}
                          </span>
                        </div>
                      </div>
                    </td>

                    {/* Role */}
                    <td className="px-6 py-4.5">
                      <Badge
                        variant="outline"
                        className={`font-semibold text-xs py-0.5 px-2 border ${ROLE_BADGE_VARIANTS[user.role as Role] || ''}`}
                      >
                        {ROLE_LABELS[user.role as Role] || user.role}
                      </Badge>
                    </td>

                    {/* Status */}
                    <td className="px-6 py-4.5">
                      {user.is_active ? (
                        <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
                          <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                          Active
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-muted-foreground">
                          <span className="h-1.5 w-1.5 rounded-full bg-slate-400 dark:bg-slate-500" />
                          Deactivated
                        </span>
                      )}
                    </td>

                    {/* Joined Date */}
                    <td className="px-6 py-4.5 text-muted-foreground text-xs">
                      {formatDate(user.created_at)}
                    </td>

                    {/* Actions */}
                    <td className="px-6 py-4.5 text-right">
                      {isSelf ? (
                        <span className="text-xs text-muted-foreground italic px-2">
                          No actions
                        </span>
                      ) : (
                        <DropdownMenu>
                          <DropdownMenuTrigger render={
                            <Button
                              variant="ghost"
                              className="h-8 w-8 p-0 hover:bg-muted group-hover:opacity-100"
                              disabled={isUpdating}
                            >
                              <span className="sr-only">Open menu</span>
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          } />
                          <DropdownMenuContent align="end" className="w-48">
                            {/* Change Role Section */}
                            <div className="px-2 py-1.5 text-xs font-semibold text-muted-foreground">
                              Change Role
                            </div>
                            {Object.entries(ROLES).map(([key, value]) => (
                              <DropdownMenuItem
                                key={key}
                                onClick={() => onUpdateUser(user.id, { role: value })}
                                className="flex items-center gap-2"
                                disabled={user.role === value}
                              >
                                <Shield className="h-3.5 w-3.5" />
                                <span>{ROLE_LABELS[value as Role]}</span>
                              </DropdownMenuItem>
                            ))}

                            <div className="h-px bg-border my-1" />

                            {/* Activate/Deactivate */}
                            {user.is_active ? (
                              <DropdownMenuItem
                                onClick={() => onUpdateUser(user.id, { is_active: false })}
                                className="text-destructive focus:bg-destructive/5 focus:text-destructive flex items-center gap-2"
                              >
                                <UserX className="h-3.5 w-3.5" />
                                <span>Deactivate User</span>
                              </DropdownMenuItem>
                            ) : (
                              <DropdownMenuItem
                                onClick={() => onUpdateUser(user.id, { is_active: true })}
                                className="text-emerald-600 focus:bg-emerald-500/5 focus:text-emerald-600 dark:text-emerald-400 dark:focus:text-emerald-400 flex items-center gap-2"
                              >
                                <UserCheck className="h-3.5 w-3.5" />
                                <span>Activate User</span>
                              </DropdownMenuItem>
                            )}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      )}
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
