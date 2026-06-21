-- ============================================================
-- Migration 006: Bookmarks
-- User-saved topics and resources
-- ============================================================

CREATE TABLE IF NOT EXISTS public.bookmarks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  topic_id    UUID REFERENCES public.topics(id) ON DELETE CASCADE,
  resource_id UUID REFERENCES public.resources(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Bookmark must target exactly one entity
  CONSTRAINT bookmark_target_check
    CHECK (
      (topic_id IS NOT NULL AND resource_id IS NULL) OR
      (topic_id IS NULL AND resource_id IS NOT NULL)
    ),

  -- Prevent duplicate bookmarks
  UNIQUE (user_id, topic_id),
  UNIQUE (user_id, resource_id)
);

-- Index for fast "my bookmarks" queries
CREATE INDEX IF NOT EXISTS bookmarks_user_idx
  ON public.bookmarks (user_id, created_at DESC);

-- ── Row-Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- Users can only see and manage their own bookmarks
CREATE POLICY "bookmarks_select_own"
  ON public.bookmarks FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "bookmarks_insert_own"
  ON public.bookmarks FOR INSERT
  WITH CHECK (user_id = auth.uid() AND auth.uid() IS NOT NULL);

CREATE POLICY "bookmarks_delete_own"
  ON public.bookmarks FOR DELETE
  USING (user_id = auth.uid());
