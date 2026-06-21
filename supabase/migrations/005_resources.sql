-- ============================================================
-- Migration 005: Resources
-- Individual content items attached to a topic
-- ============================================================

CREATE TABLE IF NOT EXISTS public.resources (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id      UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
  title         TEXT NOT NULL,
  description   TEXT,
  resource_type TEXT NOT NULL
                  CHECK (resource_type IN (
                    'YOUTUBE', 'GOOGLE_DRIVE', 'PDF',
                    'PPT', 'DOC', 'EXTERNAL_URL'
                  )),
  url           TEXT NOT NULL,
  sort_order    INTEGER NOT NULL DEFAULT 0,
  deleted_at    TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by    UUID NOT NULL REFERENCES public.profiles(id),
  updated_by    UUID NOT NULL REFERENCES public.profiles(id)
);

-- Index for fast topic resource lookups
CREATE INDEX IF NOT EXISTS resources_topic_idx
  ON public.resources (topic_id, sort_order)
  WHERE deleted_at IS NULL;

-- Auto-update triggers
CREATE OR REPLACE TRIGGER resources_set_updated_at
  BEFORE UPDATE ON public.resources
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- ── Row-Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

-- Resources inherit access from their parent topic.
-- Users who can see a topic can see its resources.
CREATE POLICY "resources_select_via_topic"
  ON public.resources FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1 FROM public.topics t
      WHERE t.id = public.resources.topic_id
        AND t.deleted_at IS NULL
        -- The topic SELECT policy handles visibility;
        -- we just confirm the topic is accessible to auth.uid()
        -- by relying on RLS applied to the JOIN
    )
    AND auth.uid() IS NOT NULL
  );

-- INSERT: PREACHER+ for own topic, ADMIN+ for any topic
CREATE POLICY "resources_insert_preacher_own_or_admin_any"
  ON public.resources FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND created_by = auth.uid()
    AND (
      -- ADMIN+ can add to any topic
      (SELECT role FROM public.profiles WHERE id = auth.uid())
        IN ('ADMIN', 'SUPER_ADMIN')
      OR
      -- PREACHER can add to their own topics
      (
        (SELECT role FROM public.profiles WHERE id = auth.uid())
          IN ('PREACHER')
        AND EXISTS (
          SELECT 1 FROM public.topics
          WHERE id = topic_id AND created_by = auth.uid()
        )
      )
    )
  );

-- UPDATE: same rules as INSERT
CREATE POLICY "resources_update_preacher_own_or_admin_any"
  ON public.resources FOR UPDATE
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
CREATE POLICY "resources_delete_admin"
  ON public.resources FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );
