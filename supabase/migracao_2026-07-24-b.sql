-- Rode este script uma vez no SQL Editor do Supabase (New query > Run) se você
-- já rodou o schema.sql e/ou a migração anterior antes desta mudança. Ele
-- adiciona o novo campo "nf_recebida" (etapa "aguardando contador" antes de
-- virar "Faturado") sem apagar nada do que já existe.

alter table public.vendas add column if not exists nf_recebida boolean not null default false;

-- As vendas antigas que já estavam marcadas como nf_solicitada = true são
-- histórico de anos anteriores: considerar a nota como já recebida também,
-- ou seja, totalmente faturadas.
update public.vendas set nf_recebida = true where confirmado = true and nf_solicitada = true and nf_recebida = false;
