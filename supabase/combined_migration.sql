-- ============================================================
-- Migration 001: Profiles
-- Extends auth.users with role and display information
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL DEFAULT '',
  avatar_url  TEXT,
  role        TEXT NOT NULL DEFAULT 'USER'
                CHECK (role IN ('SUPER_ADMIN', 'ADMIN', 'PREACHER', 'USER')),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID REFERENCES public.profiles(id),
  updated_by  UUID REFERENCES public.profiles(id)
);

-- Auto-create a profile row when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email, ''),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER profiles_set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can read all active profiles (needed for author display)
CREATE POLICY "profiles_select_all"
  ON public.profiles FOR SELECT
  USING (auth.uid() IS NOT NULL AND is_active = TRUE);

-- Users can update their own profile
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Super admins can update any profile (role management)
CREATE POLICY "profiles_update_super_admin"
  ON public.profiles FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );
-- ============================================================
-- Migration 002: Batches & Batch Members
-- Named cohorts for visibility-gated content
-- ============================================================

CREATE TABLE IF NOT EXISTS public.batches (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  description TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  deleted_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID NOT NULL REFERENCES public.profiles(id),
  updated_by  UUID NOT NULL REFERENCES public.profiles(id)
);

CREATE TABLE IF NOT EXISTS public.batch_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_id   UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES public.profiles(id),
  UNIQUE (batch_id, user_id)
);

-- Auto-update triggers
CREATE OR REPLACE TRIGGER batches_set_updated_at
  BEFORE UPDATE ON public.batches
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batch_members ENABLE ROW LEVEL SECURITY;

-- Only SUPER_ADMIN can manage batches
CREATE POLICY "batches_select_super_admin"
  ON public.batches FOR SELECT
  USING (
    deleted_at IS NULL
    AND (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

CREATE POLICY "batches_insert_super_admin"
  ON public.batches FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

CREATE POLICY "batches_update_super_admin"
  ON public.batches FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

CREATE POLICY "batches_delete_super_admin"
  ON public.batches FOR DELETE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

-- Batch members: super admin manages, users can see their own membership
CREATE POLICY "batch_members_select"
  ON public.batch_members FOR SELECT
  USING (
    user_id = auth.uid()
    OR (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

CREATE POLICY "batch_members_insert_super_admin"
  ON public.batch_members FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );

CREATE POLICY "batch_members_delete_super_admin"
  ON public.batch_members FOR DELETE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) = 'SUPER_ADMIN'
  );
-- ============================================================
-- Migration 003: Categories & Subcategories
-- ============================================================

CREATE TABLE IF NOT EXISTS public.categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  slug        TEXT NOT NULL UNIQUE,
  description TEXT,
  icon        TEXT,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  deleted_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID NOT NULL REFERENCES public.profiles(id),
  updated_by  UUID NOT NULL REFERENCES public.profiles(id)
);

CREATE TABLE IF NOT EXISTS public.subcategories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  deleted_at  TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by  UUID NOT NULL REFERENCES public.profiles(id),
  updated_by  UUID NOT NULL REFERENCES public.profiles(id),
  UNIQUE (category_id, slug)
);

-- Indexes
CREATE INDEX IF NOT EXISTS categories_slug_idx ON public.categories (slug) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS subcategories_category_idx ON public.subcategories (category_id) WHERE deleted_at IS NULL;

-- Auto-update triggers
CREATE OR REPLACE TRIGGER categories_set_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE TRIGGER subcategories_set_updated_at
  BEFORE UPDATE ON public.subcategories
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subcategories ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read categories
CREATE POLICY "categories_select_authenticated"
  ON public.categories FOR SELECT
  USING (auth.uid() IS NOT NULL AND deleted_at IS NULL);

-- ADMIN+ can create/edit/delete categories
CREATE POLICY "categories_insert_admin"
  ON public.categories FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

CREATE POLICY "categories_update_admin"
  ON public.categories FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

CREATE POLICY "categories_delete_admin"
  ON public.categories FOR DELETE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

-- Subcategories mirror category policies
CREATE POLICY "subcategories_select_authenticated"
  ON public.subcategories FOR SELECT
  USING (auth.uid() IS NOT NULL AND deleted_at IS NULL);

CREATE POLICY "subcategories_insert_admin"
  ON public.subcategories FOR INSERT
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

CREATE POLICY "subcategories_update_admin"
  ON public.subcategories FOR UPDATE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );

CREATE POLICY "subcategories_delete_admin"
  ON public.subcategories FOR DELETE
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid())
    IN ('ADMIN', 'SUPER_ADMIN')
  );
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

-- â”€â”€ Full-Text Search â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

-- â”€â”€ Indexes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

CREATE INDEX IF NOT EXISTS topics_search_idx    ON public.topics USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS topics_category_idx  ON public.topics (category_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_status_idx    ON public.topics (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_visibility_idx ON public.topics (visibility) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS topics_slug_idx      ON public.topics (slug) WHERE deleted_at IS NULL;

-- Auto-update triggers
CREATE OR REPLACE TRIGGER topics_set_updated_at
  BEFORE UPDATE ON public.topics
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

-- â”€â”€ Row-Level Security â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
