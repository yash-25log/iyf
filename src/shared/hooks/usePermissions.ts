'use client'

import { useAuth } from '@/features/auth/hooks/useAuth'
import { ROLES } from '@/shared/constants/roles'

/**
 * usePermissions — named boolean permissions for every action in the app.
 *
 * Prefer this over raw `can(ROLES.X)` calls in components.
 * Centralizing permission logic here means a single place to update
 * when business rules change.
 */
export function usePermissions() {
  const { can, role, isAdmin, isSuperAdmin } = useAuth()

  return {
    // ── User Management (Super Admin only) ──────────────────────────────
    canListUsers: isSuperAdmin,
    canChangeUserRole: isSuperAdmin,
    canDeactivateUser: isSuperAdmin,

    // ── Batch Management (Super Admin only) ─────────────────────────────
    canManageBatches: isSuperAdmin,

    // ── Category Management (Admin+) ────────────────────────────────────
    canCreateCategory: isAdmin,
    canEditCategory: isAdmin,
    canDeleteCategory: isSuperAdmin, // Destructive — Super Admin only

    // ── Topics ──────────────────────────────────────────────────────────
    canCreateTopic: can(ROLES.PREACHER),
    canEditOwnTopic: can(ROLES.PREACHER),
    canEditAnyTopic: isAdmin,
    canDeleteTopic: isAdmin,
    canPublishTopic: isAdmin,
    canArchiveTopic: isAdmin,
    canViewDraftTopics: can(ROLES.PREACHER), // Own drafts
    canViewAdminOnlyTopics: isAdmin,
    canAssignBatchToTopic: isAdmin,

    // ── Resources ───────────────────────────────────────────────────────
    canAddResourceToOwnTopic: can(ROLES.PREACHER),
    canAddResourceToAnyTopic: isAdmin,
    canDeleteResource: isAdmin,
    canReorderResources: can(ROLES.PREACHER),

    // ── Bookmarks (all authenticated users) ─────────────────────────────
    canBookmark: can(ROLES.USER),

    // ── Search (all authenticated users) ────────────────────────────────
    canSearch: can(ROLES.USER),

    // ── Raw role access (escape hatch) ──────────────────────────────────
    role,
    isAdmin,
    isSuperAdmin,
  }
}
