export const RESOURCE_TYPES = {
  YOUTUBE: 'YOUTUBE',
  GOOGLE_DRIVE: 'GOOGLE_DRIVE',
  PDF: 'PDF',
  PPT: 'PPT',
  DOC: 'DOC',
  EXTERNAL_URL: 'EXTERNAL_URL',
} as const

export type ResourceType = (typeof RESOURCE_TYPES)[keyof typeof RESOURCE_TYPES]

export const RESOURCE_TYPE_LABELS: Record<ResourceType, string> = {
  YOUTUBE: 'YouTube Video',
  GOOGLE_DRIVE: 'Google Drive',
  PDF: 'PDF Document',
  PPT: 'Presentation',
  DOC: 'Document',
  EXTERNAL_URL: 'External Link',
}
