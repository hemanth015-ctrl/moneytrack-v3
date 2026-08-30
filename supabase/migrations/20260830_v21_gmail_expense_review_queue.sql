create table if not exists public.gmail_expense_candidates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  gmail_message_id text not null,
  gmail_thread_id text,
  sender text,
  subject text,
  received_at timestamptz,
  transaction_date date,
  amount numeric(14,2) not null check (amount >= 0),
  currency text not null default 'INR',
  merchant text,
  category text,
  payment_method text,
  card_last4 text,
  direction text not null default 'expense' check (direction in ('expense','income','refund','reversal')),
  confidence numeric(5,4) not null default 0 check (confidence >= 0 and confidence <= 1),
  status text not null default 'pending' check (status in ('pending','approved','rejected','duplicate','ignored')),
  parser_version text not null default 'v21',
  raw_meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  unique(user_id, gmail_message_id)
);
alter table public.gmail_expense_candidates enable row level security;
create policy "users_read_own_gmail_candidates" on public.gmail_expense_candidates for select using (auth.uid() = user_id);
create policy "users_insert_own_gmail_candidates" on public.gmail_expense_candidates for insert with check (auth.uid() = user_id);
create policy "users_update_own_gmail_candidates" on public.gmail_expense_candidates for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create index if not exists gmail_expense_candidates_user_status_idx on public.gmail_expense_candidates(user_id,status,created_at desc);
create index if not exists gmail_expense_candidates_date_idx on public.gmail_expense_candidates(user_id,transaction_date desc);