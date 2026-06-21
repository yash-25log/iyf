-- ============================================================
-- Migration 004: Topics & Topic Batches
-- Core preaching subject unit with visibility model
-- ============================================================

CREATE TABLE IF NOT EXISTS public.topics (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  slug            TEXT NOT NULL UNIQUE,
  description     TEXT,
  category_id     UUID NOT NULL REFERENCES public.categories(id),
  subcategory_id  UUID REFERENCES public.subcategories(id),
  speaker         TEXT,
  location        TEXT,
  event_date      DATE,
  thumbnail_url   TEXT,
  tags            TEXT[] NOT NULL DEFAULT '{}',
  visibility      TEXT NOT NULL DEFAULT 'PUBLIC'
                    CHECK (visibility IN ('PUBLIC', 'BATCH', 'ADMIN_ONLY')),
  status          TEXT NOT NULL DEFAULT 'DRAFT'
                    CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
  search_vector   TSVECTOR,
  deleted_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by      UUID NOT NULL REFERENCES public.profiles(id),
  updated_by      UUID NOT NULL REFERENCES public.profiles(id)
);

-- Batch-visibility junction table
CREATE TABLE IF NOT EXISTS public.topic_batches (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id   UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
  batch_id   UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  UNIQUE (topic_id, batch_id)
);

-- ── Full-Text Search ──────────────────────────────────────────────────────────

-- Weighted: title (A) > speaker/tags (B) > location (C) > description (D)
CREATE OR REPLACE FUNCTION public.update_topics_search_vector()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.speaker, '')), 'B') ||
    setweight(to_tsvector('english', array_to_string(NEW.tags, ' ')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.location, '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'D');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER topics_search_vector_update
  BEFORE INSERT OR UPDATE ON public.topics
  FOR EACH ROW EXECUTE FUNCTION public.update_topics_search_vector();

-- ── Indexes ───────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS topics_search_idx    ON public.topics USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS topics_category_idx  ON public.topics (category_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_status_idx    ON public.topics (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_visibility_idx ON public.topics (visibility) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_slug_idx      ON public.topics (slug) WHERE deleted_at IS NULL;

-- Auto-update triggers
CREATE OR REPLACE TRIGGER topics_set_updated_at
  BEFORE UPDATE ON public.topics
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Row-Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topic_batches ENABLE ROW LEVEL SECURITY;

-- SELECT: visibility-aware policy
CREATE POLICY "topics_select_policy"
  ON public.topics FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND deleted_at IS NULL
    AND status = 'PUBLISHED'
    AND (
      -- Rule 1: PUBLIC topics visible to all authenticated users
      visibility = 'PUBLIC'
      OR
      -- Rule 2: ADMIN_ONLY visible only to ADMIN and SUPER_ADMIN
      (
        visibility = 'ADMIN_ONLY'
        AND (SELECT role FROM public.profiles WHERE id = auth.uid())
            IN ('ADMIN', 'SUPER_ADMIN')
      )
      OR
      -- Rule 3: BATCH visible only if user is in at least one assigned batch
      (
        visibility = 'BATCH'
        AND EXISTS (
          SELECT 1 FROM public.topic_batches tb
          JOIN public.batch_members bm ON bm.batch_id = tb.batch_id
          WHERE tb.topic_id = public.topics.id
            AND bm.user_id = auth.uid()
        )
      )
      OR
      -- Rule 4: Creators can always see their own topics (including DRAFT)
      created_by = auth.uid()
      OR
      -- Rule 5: ADMIN+ can see all topics regardless of visibility/status
      (SELECT role FROM public.profiles WHERE id = auth.uid())
        IN ('ADMIN', 'SUPER_ADMIN')
    )
  );

-- INSERT: PREACHER+ can create topics
CREATE POLICY "topics_insert_preacher"
  ON public.topics FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('PREACHER', 'ADMIN', 'SUPER_ADMIN')
    AND created_by = auth.uid()
  );

-- UPDATE: own topic (PREACHER+) or any topic (ADMIN+)
CREATE POLICY "topics_update_own_or_admin"
  ON public.topics FOR UPDATE
  USING (
    (
      created_by = auth.uid()
      AND (SELECT role FROM public.profiles WHERE id = auth.uid())
          IN ('PREACHER', 'ADMIN', 'SUPER_ADMIN')
    )
    OR
    (SELECT role FROM public.profiles WHERE id = auth.uid())
      IN ('ADMIN', 'SUPER_ADMIN')
  );

-- DELETE (soft): ADMIN+ only
CREATE POLICY "topics_delete_admin"
  ON public.topics FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

-- Topic batches: ADMIN+ manage, visibility follows topic access
CREATE POLICY "topic_batches_select"
  ON public.topic_batches FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "topic_batches_insert_admin"
  ON public.topic_batches FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

CREATE POLICY "topic_batches_delete_admin"
  ON public.topic_batches FOR DELETE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );
