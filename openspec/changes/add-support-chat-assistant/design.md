# Design — add-support-chat-assistant

## Context

O sistema já possui: provedor LLM OpenAI-compatible por config (`LlmAiDraftProvider`,
padrão `AiDrafts`), rate limiter com políticas dedicadas, permissões por policy,
AuditLog com tenant. O chat reusa tudo isso — sem infra nova além da tabela
`HelpArticles`.

## Pesquisa aplicada (2026)

Referências: Zealoop (arquitetura grounded p/ SaaS pequeno), Splunk (redução de
alucinação — retrieval>output-guardrails>prompting, nessa ordem), Fern (FTS por
task/área com metadados e filtro de papel), Communicate (citar fontes = confiança),
Ownex (escopo estreito primeiro, read-only primeiro, handoff humano sempre aberto),
Aiflowiz (medir o handoff, não só a resposta), Aiflowiz/Ownex (cota + analytics de
perguntas sem resposta).

## Goals / Non-Goals

- **Goals**: respostas consistentes sobre o sistema; recusa limpa fora de escopo;
  custo previsível (cota + top-k pequeno); caminho humano sempre disponível;
  curadoria simples do conteúdo.
- **Non-Goals (v1)**: ações de escrita via chat; embeddings/pgvector; multi-turn
  longo (contexto = sessão curta); mascote visual (só placeholder-avatar).

## Decisions

1. **FTS/tsvector em vez de pgvector no v1** — corpus pequeno (dezenas de artigos),
   zero infra nova; embeddings só se FTS não sustentar (deixa exato no design).
   Boring pattern per OpenSpec guidance.
2. **Recusa de escopo no Prompt + checagem determinística** — o retrieval vazio/
   baixo-score é o trigger principal de recusa (não depende do LLM "querer" recusar;
   determinístico e testável).
3. **Read-only** — sem tools/no mutate: menor risco, conforme Ownex (v1 read-only).
4. **Reutilizar padrão AiDrafts** — um único local de config LLM-convenção no codebase.
5. **Cota por plano** — `MaxDailyMessages` low default (20/dia) + rate limit;
   mensagens excedidas recusam antes do LLM (custo previsível no plano Free).

## Riscos / Trade-offs

- FTS pode perder sinônímos (ex.: "boleto" vs "fatura") → curadoria de tags +
  avaliações 4.4; embeddings v2 se necessário.
- Alucinação residual mesmo com grounding → citação obrigatória + threshold;
  dataset de avaliação antes do go-live.
- Custo por tenant grande → cota + top-k pequeno (≤3 chunks) + contexto curto.

## Migração/Rollback

Aditivo; rota nova rate-limited; rollback = desativar widget via flag
(`SupportChat:WidgetEnabled`) ou remover deploy do controller.

## Open Questions

- Nome/mascote definitivo (currentUser persona "Zeca" configurável).
- Cota por plano: Free 20/dia, pago maior — validar com pricing.
