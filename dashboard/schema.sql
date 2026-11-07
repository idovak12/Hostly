-- Run once in Supabase: SQL Editor -> New query -> paste -> Run.
-- One row per venue account. The whole venue (events, payments, vendor bills, expenses, settings) lives in `data`.
-- shortcut: one JSON document per venue, fine for one venue with a few people editing; move events and payments
-- into their own tables when you need reports across venues or several staff editing at the same moment.

create table if not exists public.halls (
  id         uuid primary key default gen_random_uuid(),
  owner      uuid not null unique default auth.uid() references auth.users on delete cascade,
  data       jsonb not null,
  version    integer not null default 1,     -- the page saves only if nobody else saved in between
  updated_at timestamptz not null default now()
);

alter table public.halls enable row level security;

-- every account sees and changes only its own venue; there is no delete policy, so data cannot be deleted from the page
create policy "read own hall"   on public.halls for select using (owner = auth.uid());
create policy "create own hall" on public.halls for insert with check (owner = auth.uid());
create policy "update own hall" on public.halls for update using (owner = auth.uid()) with check (owner = auth.uid());
