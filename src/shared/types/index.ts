import { type Role } from '@/shared/constants/roles'
import { type ResourceType } from '@/shared/constants/resourceTypes'
import { type Visibility, type TopicStatus } from '@/shared/constants/visibilityLevels'

// ─── Database Row Types ───────────────────────────────────────────────────────

export interface Profile {
  id: string
  full_name: string
  avatar_url: string | null
  role: Role
  is_active: boolean
  created_at: string
  updated_at: string
  created_by: string | null
  updated_by: string | null
}

export interface Batch {
  id: string
  name: string
  description: string | null
  is_active: boolean
  deleted_at: string | null
  created_at: string
  updated_at: string
  created_by: string
  updated_by: string
}

export interface BatchMember {
  id: string
  batch_id: string
  user_id: string
  created_at: string
  created_by: string
}

export interface Category {
  id: string
  name: string
  slug: string
  description: string | null
  icon: string | null
  sort_order: number
  deleted_at: string | null
  created_at: string
  updated_at: string
  created_by: string
  updated_by: string
}

export interface Subcategory {
  id: string
  category_id: string
  name: string
  slug: string
  sort_order: number
  deleted_at: string | null
  created_at: string
  updated_at: string
  created_by: string
  updated_by: string
}

export interface Topic {
  id: string
  title: string
  slug: string
  description: string | null
  category_id: string
  subcategory_id: string | null
  speaker: string | null
  location: string | null
  event_date: string | null
  thumbnail_url: string | null
  tags: string[]
  visibility: Visibility
  status: TopicStatus
  deleted_at: string | null
  created_at: string
  updated_at: string
  created_by: string
  updated_by: string
}

export interface Resource {
  id: string
  topic_id: string
  title: string
  description: string | null
  resource_type: ResourceType
  url: string
  sort_order: number
  deleted_at: string | null
  created_at: string
  updated_at: string
  created_by: string
  updated_by: string
}

export interface Bookmark {
  id: string
  user_id: string
  topic_id: string | null
  resource_id: string | null
  created_at: string
}

// ─── Enriched / Joined Types ──────────────────────────────────────────────────

export interface TopicWithCategory extends Topic {
  category: Pick<Category, 'id' | 'name' | 'slug'>
  subcategory: Pick<Subcategory, 'id' | 'name' | 'slug'> | null
}

export interface TopicWithResources extends TopicWithCategory {
  resources: Resource[]
}

export interface BookmarkWithTopic extends Bookmark {
  topic: TopicWithCategory | null
}

export interface BookmarkWithResource extends Bookmark {
  resource: Resource | null
}

// ─── API Envelope Types ───────────────────────────────────────────────────────

export interface PaginationMeta {
  total: number
  page: number
  limit: number
  totalPages: number
}

export interface ApiSuccess<T> {
  data: T
  meta?: PaginationMeta
}

export interface ApiError {
  error: {
    code: string
    message: string
  }
}

export type ApiResponse<T> = ApiSuccess<T> | ApiError

// ─── Query Param Types ────────────────────────────────────────────────────────

export interface PaginationParams {
  page?: number
  limit?: number
  sort?: string
  order?: 'asc' | 'desc'
}

export interface TopicFilters extends PaginationParams {
  category_id?: string
  subcategory_id?: string
  speaker?: string
  year?: number
  resource_type?: ResourceType
  location?: string
  status?: TopicStatus
  visibility?: Visibility
}

export interface SearchParams extends PaginationParams {
  q: string
  category_id?: string
  speaker?: string
  year?: number
  resource_type?: ResourceType
  location?: string
}
