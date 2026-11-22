-- Выполните весь SQL в Supabase → SQL Editor → New query → Run
create extension if not exists pgcrypto;
create table if not exists public.groups (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 name text not null, created_at timestamptz not null default now()
);
create table if not exists public.students (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 group_id uuid not null references public.groups(id) on delete cascade, name text not null, created_at timestamptz not null default now()
);
create table if not exists public.homeworks (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 group_id uuid not null references public.groups(id) on delete cascade, title text not null, description text default '',
 lesson_date date not null, created_at timestamptz not null default now()
);
create table if not exists public.marks (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 homework_id uuid not null references public.homeworks(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade,
 status text not null check(status in ('done','missed')), created_at timestamptz not null default now(),
 unique(homework_id,student_id)
);
alter table public.groups enable row level security;
alter table public.students enable row level security;
alter table public.homeworks enable row level security;
alter table public.marks enable row level security;
create policy "owner groups" on public.groups for all to authenticated using (auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "owner students" on public.students for all to authenticated using (auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "owner homeworks" on public.homeworks for all to authenticated using (auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "owner marks" on public.marks for all to authenticated using (auth.uid()=user_id) with check(auth.uid()=user_id);
-- В Supabase Authentication → Providers → Anonymous Sign-Ins включите Anonymous sign-ins.
