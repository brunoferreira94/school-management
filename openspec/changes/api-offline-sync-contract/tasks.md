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
- [ ] 2.5 Testes de carência offline (30 alunos × 5 turmas, 3 concorrentes)
- [x] 2.6 Testes de lote batch (applied/unchanged/conflict/rejected) — handler evoluído p/ estados da spec (BatchId, Outcomes); 8 unitários + 4 integração Redis; doc offline-sync.md alinhada
- [x] 2.7 Testes de LGPD (logs sem PII) — handler loga só batchId/tenantId/contagens; métricas offline_sync.total/success/conflicts (F4) com testes

## Bloco 3: Documentação e Runbook (BACK/FRONT)

- [x] 3.1 Atualizar `docs/api/offline-sync.md` com exemplos de uso — sync-batch real, X-Server-Time, métricas F4, Redis config, estado da implementação (POC), migração de revisões (3.3)
- [x] 3.2 Atualizar `docs/runbooks/offline-sync-rollout.md` — nota de estado atual, smoke tests com formato real, rollback sem endpoint inexistente, métricas implementadas vs. adesão (pré-requisito de hardening)
- [x] 3.3 Documentar migração de dados (revisões existentes) — seção em docs/api/offline-sync.md (defaults + consequências p/ clientes legados)
- [x] 3.4 Criar guia de troubleshooting do cliente — docs/client/offline-sync-troubleshooting.md (422/412/unchanged/rejected, relógio, falha de rede)

## Bloco 4: Desenvolvimento Frontend (FRONT)

- [ ] 4.1 Implementar geração de Idempotency-Key no cliente
- [ ] 4.2 Implementar armazenamento local de operações pendentes
- [ ] 4.3 Implementar sync automático ao reconectar
- [ ] 4.4 Exibir estados de sync (pending/applied/conflict) na UI

## Bloco 5: Ativação em Staging (OPS)

- [ ] 5.1 Ativar flags `RequireKey=true`, `Enforce=true` (via env)
- [ ] 5.2 Janela de observação 24h
- [ ] 5.3 Smoke test: 5 clientes, 10k ops/dia cada
- [ ] 5.4 Monitorar adesão (missing_key < 1%, revision_missing < 1%)
- [ ] 5.5 Aprovação para produção

## Status

- **Aguardando implementação**: 0
- **Em progresso**: 0
- **Concluído**: 32
- **Pendente (Redis)**: 0

## Critérios de Aceitação

- Todos os testes de integração passam (815+ testes)
- Suíte de carência offline verde: 30×5=150 alunos, 3 concorrentes = 450 operações simultâneas
- Taxa de conflito < 1% em staging
- Logs não continham PII
- Documentação atualizada
- Runbook testado
