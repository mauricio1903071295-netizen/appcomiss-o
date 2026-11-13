-- Rode este script uma vez no SQL Editor do Supabase (New query > Run).
-- Adiciona o controle de despesas do negócio: despesas fixas recorrentes
-- (contador, INSS, registro de corretor etc, mensais ou anuais) e o DAS,
-- calculado automaticamente a partir do faturamento do mês anterior.

create table if not exists public.despesas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  mes text not null,
  nome text not null,
  valor numeric not null,
  tipo text not null default 'fixa',
  dia int,
  pago boolean not null default false,
  created_at timestamptz not null default now(),
  unique (user_id, mes, nome)
);

alter table public.despesas enable row level security;

create policy "despesas_select_own" on public.despesas
  for select using (auth.uid() = user_id);
create policy "despesas_insert_own" on public.despesas
  for insert with check (auth.uid() = user_id);
create policy "despesas_update_own" on public.despesas
  for update using (auth.uid() = user_id);
create policy "despesas_delete_own" on public.despesas
  for delete using (auth.uid() = user_id);

-- Configuração: lista de despesas fixas (nome, valor, dia, recorrência) e a
-- alíquota do DAS, usada pra estimar o valor do mês a partir do faturamento
-- (comissões + receita fixa) do mês anterior já registrado no app.
alter table public.configuracoes add column if not exists despesas_fixas jsonb not null default '[]'::jsonb;
alter table public.configuracoes add column if not exists das_aliquota numeric;
alter table public.configuracoes add column if not exists das_dia int not null default 20;
