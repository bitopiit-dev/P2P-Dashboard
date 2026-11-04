-- P2P Material Collection Dashboard: Supabase setup
-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.
-- Result: anyone can READ the published tracker; only users listed in
-- dashboard_admins can publish or delete uploads.

-- 1. Uploaded tracker snapshots (the newest row is what everyone sees)
create table if not exists public.tracker_snapshots (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  uploaded_by uuid not null default auth.uid() references auth.users(id) on delete set null,
  source_name text,
  payload     jsonb not null
);
create index if not exists tracker_snapshots_created_at_idx
  on public.tracker_snapshots (created_at desc);

-- 2. Who is an admin
create table if not exists public.dashboard_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email   text,
  added_at timestamptz not null default now()
);

-- 3. Helper: is the signed-in user an admin?
create or replace function public.is_dashboard_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.dashboard_admins where user_id = auth.uid());
$$;
revoke all on function public.is_dashboard_admin() from public;
grant execute on function public.is_dashboard_admin() to anon, authenticated;

-- 4. Row Level Security
alter table public.tracker_snapshots enable row level security;
alter table public.dashboard_admins  enable row level security;

drop policy if exists "Anyone can read snapshots" on public.tracker_snapshots;
create policy "Anyone can read snapshots"
  on public.tracker_snapshots for select
  to anon, authenticated
  using (true);

drop policy if exists "Admins can publish" on public.tracker_snapshots;
create policy "Admins can publish"
  on public.tracker_snapshots for insert
  to authenticated
  with check (public.is_dashboard_admin() and uploaded_by = auth.uid());

drop policy if exists "Admins can delete" on public.tracker_snapshots;
create policy "Admins can delete"
  on public.tracker_snapshots for delete
  to authenticated
  using (public.is_dashboard_admin());

-- No update policy: uploads are never edited, only added or deleted.
-- dashboard_admins has no policies for anon/authenticated, so nobody can
-- read or change the admin list from the website. Manage it here in SQL.

-- 5. Table privileges
revoke all on public.tracker_snapshots from anon, authenticated;
revoke all on public.dashboard_admins  from anon, authenticated;
grant select on public.tracker_snapshots to anon, authenticated;
grant insert, delete on public.tracker_snapshots to authenticated;

-- 6. Make someone an admin (run after creating the user in Authentication -> Users).
--    Replace the email, then run just this statement:
-- insert into public.dashboard_admins (user_id, email)
-- select id, email from auth.users where email = 'admin@example.com'
-- on conflict (user_id) do nothing;

-- Remove an admin:
-- delete from public.dashboard_admins where email = 'admin@example.com';
