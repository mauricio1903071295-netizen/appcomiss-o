-- Rode este script uma vez no SQL Editor do Supabase (New query > Run).
-- Adiciona suporte a uma receita fixa mensal (ex: um valor que você recebe
-- todo dia 5), separada das comissões de vendas, com o mesmo fluxo de
-- pedir nota / aguardar contador / faturado.

create table if not exists public.rendas_fixas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  mes text not null,
  valor numeric not null,
  confirmado boolean not null default false,
  nf_solicitada boolean not null default false,
  nf_recebida boolean not null default false,
  created_at timestamptz not null default now(),
  unique (user_id, mes)
);

alter table public.rendas_fixas enable row level security;

create policy "rendas_fixas_select_own" on public.rendas_fixas
  for select using (auth.uid() = user_id);
create policy "rendas_fixas_insert_own" on public.rendas_fixas
  for insert with check (auth.uid() = user_id);
create policy "rendas_fixas_update_own" on public.rendas_fixas
  for update using (auth.uid() = user_id);
create policy "rendas_fixas_delete_own" on public.rendas_fixas
  for delete using (auth.uid() = user_id);

-- Configuração da receita fixa (valor, dia do mês e nome) na tabela que já existe.
alter table public.configuracoes add column if not exists renda_fixa_valor numeric;
alter table public.configuracoes add column if not exists renda_fixa_dia int not null default 5;
alter table public.configuracoes add column if not exists renda_fixa_nome text not null default 'Receita fixa';
