export const ROLES = {
  SUPER_ADMIN: 'SUPER_ADMIN',
  ADMIN: 'ADMIN',
  PREACHER: 'PREACHER',
  USER: 'USER',
} as const

export type Role = (typeof ROLES)[keyof typeof ROLES]

/** Ordered hierarchy — higher index = more privilege */
export const ROLE_HIERARCHY: Role[] = [
  ROLES.USER,
  ROLES.PREACHER,
  ROLES.ADMIN,
  ROLES.SUPER_ADMIN,
]

/** Returns true if `role` has at least the privilege level of `minimum` */
export function hasMinimumRole(role: Role, minimum: Role): boolean {
  return ROLE_HIERARCHY.indexOf(role) >= ROLE_HIERARCHY.indexOf(minimum)
}
