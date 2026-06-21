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

-- ── Row-Level Security ────────────────────────────────────────────────────────

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
