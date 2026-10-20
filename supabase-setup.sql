-- Run once in Supabase SQL Editor for Dodenwassing Quiz.
create extension if not exists pgcrypto;
create table if not exists public.quiz_submissions (
 id uuid primary key default gen_random_uuid(),
 participant_name text not null check (char_length(trim(participant_name)) between 2 and 100),
 answers jsonb not null check (jsonb_typeof(answers) = 'array' and jsonb_array_length(answers) = 15),
 score integer not null check (score between 0 and 15),
 created_at timestamptz not null default now()
);
create table if not exists public.quiz_admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.quiz_submissions enable row level security;
alter table public.quiz_admins enable row level security;
revoke all on public.quiz_submissions from anon, authenticated;
revoke all on public.quiz_admins from anon, authenticated;
grant insert on public.quiz_submissions to anon, authenticated;
grant select on public.quiz_submissions to authenticated;
grant select on public.quiz_admins to authenticated;
drop policy if exists "Anyone can submit a finished quiz" on public.quiz_submissions;
create policy "Anyone can submit a finished quiz" on public.quiz_submissions for insert to anon, authenticated with check (true);
drop policy if exists "Only admins can view results" on public.quiz_submissions;
create policy "Only admins can view results" on public.quiz_submissions for select to authenticated using (exists(select 1 from public.quiz_admins where user_id = (select auth.uid())));
drop policy if exists "Admin can see own role" on public.quiz_admins;
create policy "Admin can see own role" on public.quiz_admins for select to authenticated using (user_id = (select auth.uid()));
-- After creating your own user in Authentication > Users, add the user's UUID:
-- insert into public.quiz_admins(user_id) values ('YOUR-AUTH-USER-UUID');
-- IMPORTANT: quiz_admins must only be modified in SQL Editor by project owner.
