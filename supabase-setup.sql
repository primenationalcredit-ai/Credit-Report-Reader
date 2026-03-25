-- ─────────────────────────────────────────────────────────────
-- ASAP Credit Repair — Consultation Notes App
-- Run this entire script in your Supabase SQL Editor
-- ─────────────────────────────────────────────────────────────

-- 1. Create the consultations table
create table public.consultations (
  id           uuid default gen_random_uuid() primary key,
  user_id      uuid references auth.users(id) on delete cascade not null,
  client_name  text not null,
  report_source text,
  file_names   text,
  notes        text not null,
  created_at   timestamp with time zone default timezone('utc', now()) not null
);

-- 2. Enable Row Level Security (users only see their own records)
alter table public.consultations enable row level security;

-- 3. RLS Policies
create policy "Users can view own consultations"
  on public.consultations for select
  using (auth.uid() = user_id);

create policy "Users can insert own consultations"
  on public.consultations for insert
  with check (auth.uid() = user_id);

create policy "Users can delete own consultations"
  on public.consultations for delete
  using (auth.uid() = user_id);

-- 4. Index for fast history loading
create index consultations_user_id_created_at_idx
  on public.consultations (user_id, created_at desc);
