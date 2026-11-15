# Tasks: Contrato de Sincronização Offline

## Bloco 1: Implementação da API (BACK)

- [ ] 1.1 Criar middleware `IdempotencyMiddleware` para caching de chaves
- [ ] 1.2 Implementar gerador de ETag com revision + content-hash
- [ ] 1.3 Criar endpoint `POST /api/offline/sync-batch` (handler + controller)
- [ ] 1.4 Adicionar colunas `revision`, `version`, `etag` nas entidades expostíveis
- [ ] Migrações EF para adicionar colunas + política de retenção de 24h no cache

## Bloco 2: Integração e Testes (BACK)

- [ ] 2.1 Testes unitários do IdempotencyMiddleware
- [ ] 2.2 Testes unitários do ETag Manager
- [ ] 2.3 Testes de integração para 422 (chave reutilizada)
- [ ] 2.4 Testes de integração para 412 (conflito de revisão)
- [ ] 2.5 Testes de carência offline (30 alunos × 5 turmas, 3 concorrentes)
- [ ] 2.6 Testes de lote batch (applied/unchanged/conflict/rejected)
- [ ] 2.7 Testes de LGPD (logs sem PII)

## Bloco 3: Documentação e Runbook (BACK/FRONT)

- [ ] 3.1 Atualizar `docs/api/offline-sync.md` com exemplos de uso
- [ ] 3.2 Atualizar `docs/runbooks/offline-sync-rollout.md`
- [ ] 3.3 Documentar migração de dados (revisões existentes)
- [ ] 3.4 Criar guia de troubleshooting do cliente

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
- **Concluído**: 17

## Critérios de Aceitação

- Todos os testes de integração passam (815+ testes)
- Suíte de carência offline verde: 30×5=150 alunos, 3 concorrentes = 450 operações simultâneas
- Taxa de conflito < 1% em staging
- Logs não continham PII
- Documentação atualizada
- Runbook testado