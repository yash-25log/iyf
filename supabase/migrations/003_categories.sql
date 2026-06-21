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

-- ── Row-Level Security ────────────────────────────────────────────────────────

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
