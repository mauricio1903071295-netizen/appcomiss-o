-- Rode este script uma vez no Supabase: painel do projeto > SQL Editor > New query > Run.
-- Cria as tabelas de vendas e configurações, com segurança (RLS) para que cada
-- usuário só veja e edite os próprios dados.

create table if not exists public.vendas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data_venda date not null,
  cliente text not null,
  plano text not null,
  valor numeric not null,
  primeiro_vencimento date not null,
  comissao numeric not null,
  confirmado boolean not null default false,
  nf_solicitada boolean not null default false,
  nf_recebida boolean not null default false,
  mes_corrigido text,
  created_at timestamptz not null default now()
);

alter table public.vendas enable row level security;

create policy "vendas_select_own" on public.vendas
  for select using (auth.uid() = user_id);
create policy "vendas_insert_own" on public.vendas
  for insert with check (auth.uid() = user_id);
create policy "vendas_update_own" on public.vendas
  for update using (auth.uid() = user_id);
create policy "vendas_delete_own" on public.vendas
  for delete using (auth.uid() = user_id);

create table if not exists public.configuracoes (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  regra text not null default 'mes_seguinte',
  dias_pagamento int not null default 60,
  whatsapp_contador text
);

alter table public.configuracoes enable row level security;

create policy "config_select_own" on public.configuracoes
  for select using (auth.uid() = user_id);
create policy "config_insert_own" on public.configuracoes
  for insert with check (auth.uid() = user_id);
create policy "config_update_own" on public.configuracoes
  for update using (auth.uid() = user_id);
