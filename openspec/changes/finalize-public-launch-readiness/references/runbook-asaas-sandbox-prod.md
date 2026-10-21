# Runbook — Asaas sandbox → produção (implementação do checkout)

> Tarefa 4.2 (Validar fluxo ponta-a-ponta sandbox → produção com fallback). Passo 0: decidir Asaas-only (Stripe fica locked/code-disabled) — rodar quando a decisão for do founder.

## Pré-requisitos

- [ ] Asaas prod: conta verificada, webhook `whprod_TOKEN` documentado, whitelist de IP/API webhook secret.
- [ ] `Asaas__ApiBaseUrl` = api.asaas.com (prod); `Asaas__ApiKey` = prod (no cargo-costa, user-secrets/env Render — NUNCA commitado).
- [ ] Idempotência: `Asaas__TimeoutSeconds` ≥ 12 -retry policy em trabalho; TESTES: retry watch de checkout intent re-entrego sem duplicar cobrança.
- [ ] Feature flag: env `Asaas__EnabledStage = sandbox|prod`.

## Fluxo a validar (terminal → write plan)

1. Checkout intent (sandbox) → cria provider subscription → recebe callback de confirmação → grava plano no tenant.
2. Webhook: pagamento confirmado/vencido/deletado → sync de subscription plans (`sync-subscriptionplans` endpoint) → estado final coerente (sem drift).
3. Cancelamento via RCD: pausa (30 dias) muda status do provider subscription → retorno para clientes afetados healthScore não-penal.
4. Reconciliação diária (job Reconciliation): divergências listadas em metric `reconciliation_mismatches_total` == 0.

## Fallback (produção)

| Falha | Ação |
|-------|------|
| Asaas indisponível >5 min (validade> http 5xx rate) | Modo "degrunde": bloquear NOVOS checkouts, manter gestão de matrículas (feature flag `Asaas__Paused=true`), exibir aviso no app |
| Webhook não entrega | Baixo: reconciliação das 02:00 UTC reprocessa pendências; alerta após 24 h de não-delivery |
| Cobrança duplicada detectada | Estregar autom. crédito via API sandbox-safe script `tools/asaas-refund.sh` (protótipo, validar com financeiro) |
| Roll forward em queda de Asaas prod | Devolver em processos-pending queue (Asaas inbox) na recuperação |

## Checklist de aceite

- [ ] Sandbox: 5 assinaturas E2E criadas + 2 pausas + 1 cancelamento (mixed ), zerada divergência.
- [ ] Load leve: 50 concurrent checkouts, p95 < 1.2 s (mesmo com timeout reduzido).
- [ ] Runbook testado em turno "turro local": pausa Asaas na rede do staging → modo degradado ativa e recupera automaticamente.
- [ ] Assinado por financeiro + tech lead.
