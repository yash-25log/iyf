export const VISIBILITY = {
  PUBLIC: 'PUBLIC',
  BATCH: 'BATCH',
  ADMIN_ONLY: 'ADMIN_ONLY',
} as const

export type Visibility = (typeof VISIBILITY)[keyof typeof VISIBILITY]

export const VISIBILITY_LABELS: Record<Visibility, string> = {
  PUBLIC: 'Public',
  BATCH: 'Batch Only',
  ADMIN_ONLY: 'Admin Only',
}

export const TOPIC_STATUS = {
  DRAFT: 'DRAFT',
  PUBLISHED: 'PUBLISHED',
  ARCHIVED: 'ARCHIVED',
} as const

export type TopicStatus = (typeof TOPIC_STATUS)[keyof typeof TOPIC_STATUS]

export const TOPIC_STATUS_LABELS: Record<TopicStatus, string> = {
  DRAFT: 'Draft',
  PUBLISHED: 'Published',
  ARCHIVED: 'Archived',
}
