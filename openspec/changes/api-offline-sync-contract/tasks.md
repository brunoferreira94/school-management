# Tasks: Contrato de Sincronização Offline

## Bloco 1: Implementação da API (BACK)

- [x] 1.1 Criar middleware `IdempotencyMiddleware` para caching de chaves
- [x] 1.2 Implementar gerador de ETag com revision + content-hash
- [x] 1.3 Criar endpoint `POST /api/offline/sync-batch` (handler + controller)
- [x] 1.5 X-Server-Time (F3): header X-Server-Time em todas as respostas + serverTimeUtc no corpo de GET /api/support/health — middleware+controller com testes unitários
- [x] 1.4 Adicionar colunas `revision`, `version`, `etag` nas entidades expostíveis — Student (exemplo do design.md); demais entidades seguem o mesmo padrão quando forem expostas
- [x] Migrações EF para adicionar colunas (OfflineSyncRevisionColumns, SchoolContext) + retenção de 24h do cache (TTL nativo nos serviços Memory/Redis)

## Bloco 2: Integração e Testes (BACK)

- [x] 2.1 Testes do fluxo de idempotência do lote — marca IsProcessed só com lote 100% OK (verificado no registro Redis); replay → 422; sem-chave no-op; E2E HTTP no controller fica p/ hardening
- [x] 2.2 Testes unitários do ETag Manager
- [x] 2.3 Testes de integração para 422 (chave reutilizada) — cobertura no serviço contra Redis real (Testcontainers); E2E HTTP no controller fica p/ Bloco de hardening
- [x] 2.4 Testes de integração para 412 (conflito de revisão) — RedisETagManager coberto contra Redis real (Testcontainers); If-Match HTTP end-to-end fica p/ Bloco de hardening
- [x] 2.5 Testes de carência offline (30 alunos × 5 turmas, 3 concorrentes) — `OfflineSyncConcurrencyTests`: 150 ops com 3 remetentes concorrentes (nenhuma perdida/duplicada) + 3 remetentes com a MESMA chave (só 1 lote aplica); revelou e motivou a correção da corrida da reserva de chave (GET→SET → SET NX/TryAdd)
- [x] 2.6 Testes de lote batch (applied/unchanged/conflict/rejected) — handler evoluído p/ estados da spec (BatchId, Outcomes); 8 unitários + 4 integração Redis; doc offline-sync.md alinhada
- [x] 2.7 Testes de LGPD (logs sem PII) — handler loga só batchId/tenantId/contagens; métricas offline_sync.total/success/conflicts (F4) com testes

## Bloco 2b: Hardening (integração com a UI)

- [x] H.1 Idempotência global (F0) nos endpoints individuais — IdempotencyMiddleware opt-in por header (POST/PUT/PATCH/DELETE, rotas auth/webhooks/support/offline excluídas); 2xx consome a chave (reuso → 422), 4xx/5xx/exception LIBERA a chave (retry com a mesma chave); adesão medida em todo tráfego de mutação; counter idempotency_key.reused; RequireKey permanece escopado ao sync-batch; 8 testes middleware + 2 Redis (ReleaseAsync)
- [x] H.3 F1 HTTP nos endpoints individuais — OptimisticRevisionMiddleware genérico por path (chave `tenant:path`): GET em escopo devolve `ETag` corrente; mutação com `If-Match` stale → 412 `{message, code: revision-conflict, currentRevision}`; 2xx INCR a revisão e devolve ETag novo; sem If-Match passa (Enforce=false) ou 428 `revision-required` (Enforce=true); guard HasStarted (não tocar header em resposta streaming); counter revision.conflict; parser aceita "5", "5-1.0.0-hash", quoted e W/; 10 testes middleware + 2 Redis (persistência entre instâncias)
- [x] H.2 Revisão da integração com a UI (modo offline) — UI usa handlers por feature (não sync-batch): chave preservada em retries ✓, 412 sem retry ✓; pendência da UI: tratar 422 como "já processado" (hoje vira erro permanente); F1 HTTP (If-Match) segue pendente

## Bloco 3: Documentação e Runbook (BACK/FRONT)

- [x] 3.1 Atualizar `docs/api/offline-sync.md` com exemplos de uso — sync-batch real, X-Server-Time, métricas F4, Redis config, estado da implementação (POC), migração de revisões (3.3)
- [x] 3.2 Atualizar `docs/runbooks/offline-sync-rollout.md` — nota de estado atual, smoke tests com formato real, rollback sem endpoint inexistente, métricas implementadas vs. adesão (pré-requisito de hardening)
- [x] 3.3 Documentar migração de dados (revisões existentes) — seção em docs/api/offline-sync.md (defaults + consequências p/ clientes legados)
- [x] 3.4 Criar guia de troubleshooting do cliente — docs/client/offline-sync-troubleshooting.md (422/412/unchanged/rejected, relógio, falha de rede)

## Bloco 4: Desenvolvimento Frontend (FRONT)

- [x] 4.1 Implementar geração de Idempotency-Key no cliente — UUID v4 gerado no primeiro enfileiramento e **preservado nos retries** (`offline-draft.service.ts`); a API consome a chave em 2xx e a libera em 4xx/5xx (F0 global)
- [x] 4.2 Implementar armazenamento local de operações pendentes — IndexedDB (`offline-db.service.ts`, stores `drafts`/`meta`), TTL 14 dias, limite de 20 rascunhos/usuário, limpeza LGPD
- [x] 4.3 Implementar sync automático ao reconectar — `offline-sync.service.ts`: fila FIFO (≤3 em paralelo), backoff exponencial, pausa em 401/403, 422 = já processado (remove o rascunho), aba líder com `navigator.locks`, retomada de `syncing` interrompido
- [x] 4.4 Exibir estados de sync (pending/applied/conflict) na UI — `shared/offline-banner` + card "Rascunhos não enviados" em Minha área (com descarte e "Limpar dados salvos neste dispositivo")
- [x] 4.5 Notas e fórmulas offline (F3) — `features/grades` e `features/grading-formulas` enfileiram o rascunho no `save()` offline; handlers `grades`/`grading-formulas` reenviam com a `Idempotency-Key` (POST/PUT /api/grades, POST|PUT /api/grading-formulas); 5 testes de handler (spec `offline-sync.handlers.spec.ts`)

## Bloco 5: Ativação em Staging (OPS)

- [ ] 5.1 Ativar flags `RequireKey=true`, `Enforce=true` (via env)
- [ ] 5.2 Janela de observação 24h
- [ ] 5.3 Smoke test: 5 clientes, 10k ops/dia cada
- [ ] 5.4 Monitorar adesão (missing_key < 1%, revision_missing < 1%)
- [ ] 5.5 Aprovação para produção

## Status

- **Aguardando implementação**: 0
- **Em progresso**: 0
- **Nota**: Bloco 5 (staging) depende de janela de observação real (≥7 dias com adesão medida) e da M2 (If-Match) implementada na UI — hoje as telas listam via collection, então não há ETag por recurso para enviar.
- **Concluído**: 41
- **Pendente (Redis)**: 0

## Critérios de Aceitação

- Todos os testes de integração passam (815+ testes)
- Suíte de carência offline verde: 30×5=150 alunos, 3 concorrentes = 450 operações simultâneas
- Taxa de conflito < 1% em staging
- Logs não continham PII
- Documentação atualizada
- Runbook testado
