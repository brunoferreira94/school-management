# Proposal: add-support-chat-assistant

> Chat de suporte em-produto, focado exclusivamente no sistema, com respostas
> grounded em base de ajuda curada (RAG) e tom amistoso (persona "mascote" futura).

## Why

Usuários (diretor, professor, secretaria, responsável) têm dúvidas operacionais do
sistema que hoje viram ticket/e-mail. Um chat assistente reduz atrito de onboarding
(deflection de FAQ típico: 40–60%) — mas um LLM solto alucina e conversa fora do
assunto. A pesquisa (Zealoop, Splunk, Fern, Communicate 2026) é categórica: grounding
em base curada + recusa com threshold + citação de fonte é o que separa um assistente
útil de um gerador de alucinações.

## What Changes

- **Capability nova `support-chat`**: chat em-produto que responde SOMENTE sobre o
  School Management e o próprio portal, baseado em artigos de ajuda curados
  (`HelpArticle` — nova tabela, tenant-global, com metadados: área, audiência/papel,
  tags, ativo).
- **Retrieval v1 sem infra nova**: busca Postgres FTS/tsvector sobre `HelpArticle`
  (chunked por seção), filtrada por audiência/papel do usuário — sem pgvector no v1
  (boring pattern; embeddings ficam p/ v2 se FTS não sustentar).
- **Apontamento funcional (o "onde/como fazer")**: resposta do chat inclui
  `actions[]` reutilizando o catálogo contextual da busca global
  (`EntitySearchService` — label + Route filtrado por permissões) e cada artigo
  carrega `contentRoute` (caminho da tela de destino) — o chat não só explica,
  leva o usuário direto para onde a ação acontece.
- **Guardrails de escopo** (o "sem papear"): system prompt com escopo fechado +
  checagem de retrievals — pergunta fora do sistema/portal → recusa simpática e
  redireciona ao assunto; sem retrieval relevante (score < threshold) → "não sei,
  fale com o suporte humano" + botão de abrir ticket. ZERO ações de escrita
  (read-only; sem tools de mutate no v1).
- **Persona amistosa**: nome/saudação do mascote configurável
  (`SupportChat:BotName`, default "Zeca — assistente da escola"); tom simpático no
  prompt; mascote visual (ilustração) fica para a UI em follow-up.
- **Contrato**: `POST /api/support/chat` (mensagem → resposta com citações dos
  artigos + flag `needsHuman`), rate limited por tenant/usuário, custo controlado
  (limite diário de mensagens por plano, histórico curto de contexto only).
- **Provedor LLM**: reutiliza o padrão `AiDrafts` (OpenAI-compatible via
  `baseUrl`/`apiKey`/`model` — OpenRouter compatível) + fallback: sem chave
  configurada, o chat responde só com link de artigos (modo "FAQ puro").
- **UI**: widget flutuante no portal/staff (standalone component, histórico na sessão,
  citações clicáveis abrindo o artigo).
- **LGPD/segurança**: sem PII na conversa além do necessário; trilha no
  `AuditLog` (tenant, user, flag needsHuman); resposta retenção configurável
  (`SupportChat:ConversationRetentionDays`); revisão humana quando flagged.

## Impact

- Specs: **nova** `support-chat`
- Código: Domain (`HelpArticle`, repo), migration SchoolContext, Application
  (service + retrieval + prompt), Host (controller + rate limit), UI (widget)
- Reusa: padrão `AiDrafts` de config LLM; rate limiter existente; permissões
- Forma para v2: pgvector, ações guiadas (com confirmação), mascote visual
