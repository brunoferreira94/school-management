# Tasks — add-support-chat-assistant

## 1. Domínio e persistência

- [ ] 1.1 Entidade `HelpArticle` (área, slug/título, corpo, audiência: staff|guardian|all,
      tags[], ativo, **contentRoute** — rota da tela de destino) + `IHelpArticleRepository`.
- [ ] 1.2 Migration SchoolContext: `HelpArticles` com índice tsvector (FTS) +
      índice de audiência/ativo.
- [ ] 1.3 Seed inicial: 10–15 artigos essenciais (cadastrar aluno, matrícula em turma,
      lançar notas, boletim, cobrança/2ª via, comunicados, consentimentos LGPD...) —
      cada um com `contentRoute` real do roteamento da UI.
- [ ] 1.4 Extrair catálogo de ações contextuais compartilhado da busca global
      (provedor a partir de `EntitySearchService`/`EntitySearchAction` — mesmo
      label + Route, filtrado por permissões) para reuso pelo chat.

## 2. Backend do chat

- [ ] 2.1 `SupportChatOptions` (Provider/BaseUrl/ApiKey/Model/BotName/MaxDailyMessages/
      ScoreThreshold/ConversationRetentionDays) — mesmo padrão `AiDrafts`.
- [ ] 2.2 `SupportChatService`: retrieval FTS (top-k filtrado por audiência/permissões),
      montagem de prompt grounded com escopo fechado, chamada LLM quando configurado,
      fallback FAQ puro sem chave, threshold → needsHuman.
- [ ] 2.3 `POST /api/support/chat` (mensagem → resposta + citações + **actions[]**
      do catálogo compartilhado + contentRoute do artigo) +
      `GET /api/support/chat/articles` (artigos elegíveis) — permissões: todos os
      autenticados; cota diária + rate limit dedicado (`SupportChat`).
- [ ] 2.4 Trilha de auditoria: mensagens flagged needsHuman no AuditLog (tenant, user).

## 3. UI

- [ ] 3.1 Widget flutuante (standalone) no portal/staff: histórico de sessão,
      saudação com BotName, citações clicáveis, **cards de ação** (label → Route,
      navegação direta via router), aviso de cota, botão "falar com suporte" quando needsHuman.
- [ ] 3.2 Espaço para mascote (avatar placeholder configurável) — visual fica p/ follow-up.

## 4. Docs e QA

- [ ] 4.1 Guia do chat (docs/idx/chat-support.md): escopo, config, curadoria de artigos,
      cota, thresholds.
- [ ] 4.2 Testes: retrieval filtrado por audiência/papel; recusa fora de escopo;
      threshold → needsHuman; cota diária; modo FAQ puro; citações na resposta;
      **actions[] filtrado por permissão (ação financeira nunca aparece para
      quem não pode) e contentRoute presente**.
- [ ] 4.3 Suíte completa verde + `ng build`.
- [ ] 4.4 Dataset de avaliação inicial (15–20 perguntas reais típicas + respostas
      esperadas) para backtest do retrieval antes do go-live.
