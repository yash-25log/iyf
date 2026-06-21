-- ============================================================
-- Seed: Test users and initial data
-- Run AFTER migrations in development only.
-- ============================================================

-- NOTE: You must create auth users via Supabase Dashboard or CLI first,
-- then update their UUIDs here. These are placeholder UUIDs.
--
-- Example flow:
-- 1. Create user in Supabase Auth (Dashboard > Authentication > Users)
-- 2. Copy the UUID
-- 3. Update the profile below

-- Update role for your Super Admin user
-- UPDATE public.profiles
-- SET role = 'SUPER_ADMIN'
-- WHERE id = 'REPLACE_WITH_YOUR_USER_UUID';

-- Seed categories
INSERT INTO public.categories (id, name, slug, description, icon, sort_order, created_by, updated_by)
VALUES
  (gen_random_uuid(), 'Bhagavad Gita', 'bhagavad-gita', 'Resources related to Bhagavad Gita study and preaching', 'book', 1, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1)),
  (gen_random_uuid(), 'Youth Seminars', 'youth-seminars', 'Materials for youth outreach seminars', 'users', 2, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1)),
  (gen_random_uuid(), 'Outreach', 'outreach', 'Street outreach and campus programs', 'map-pin', 3, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1)),
  (gen_random_uuid(), 'Leadership', 'leadership', 'Leadership training and mentorship resources', 'star', 4, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1)),
  (gen_random_uuid(), 'Festivals', 'festivals', 'Festival organization and kirtan resources', 'music', 5, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1)),
  (gen_random_uuid(), 'Bhakti Shastri', 'bhakti-shastri', 'Bhakti Shastri course materials', 'graduation-cap', 6, (SELECT id FROM public.profiles LIMIT 1), (SELECT id FROM public.profiles LIMIT 1))
ON CONFLICT (slug) DO NOTHING;
