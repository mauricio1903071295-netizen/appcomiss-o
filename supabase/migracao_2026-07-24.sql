-- Rode este script uma vez no SQL Editor do Supabase se você já executou o
-- schema.sql antes desta data (24/07/2026). Ele só adiciona o que falta,
-- sem apagar nada.

-- Campo para guardar o WhatsApp do contador (usado no botão "Fechar mês").
alter table public.configuracoes add column if not exists whatsapp_contador text;

-- As vendas antigas já recebidas (confirmado = true) já tiveram nota fiscal
-- emitida há tempos; marca todas como nf_solicitada = true de uma vez.
update public.vendas set nf_solicitada = true where confirmado = true and nf_solicitada = false;
