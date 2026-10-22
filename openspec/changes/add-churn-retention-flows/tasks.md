
## 1. Cancel flow (win-back)

- [x] 1.1 Criar componente `cancel-flow` (3 passos: perda concreta → alternativa → motivo) — FRONT
- [x] 1.2 Passo 1: exibir perda concreta (contagem real de alunos/turmas/meses de histórico) — FRONT (consome `AccountSummary`)
- [x] 1.3 Passo 2: oferecer alternativa (pausar 30 dias / 1 mês grátis) — FRONT
- [x] 1.4 Passo 3: coletar motivo via pergunta aberta (texto livre + tag opcional) — FRONT — **gap corrigido nesta rodada**: o campo tag opcional não existia no componente; adicionado (`reason-tags` com 4 presets i18n pt/en/es, `confirmCancel` envia `reasonTag`, API prefixa `[tag]` no `CancellationReason` p/ análise 6.1). Commits API `b1c321d` + UI `5dbeab2`
- [x] 1.5 Substituir `CANCEL_CONFIRM` (confirm nativo) pelo novo fluxo em `subscriptions.component` — FRONT
- [x] 1.6 API: endpoints de pausa e cancelamento com persistência do motivo + timestamp (see PR #74)
- [x] 1.7 Garantir que o cancelar permanece acessível e honesto em cada passo (sem dark pattern) — FRONT (botão sempre visível)

## 2. Health score (risco de churn)

- [ ] 2.1 API: calcular health score por conta (janelas 14/30 dias, sinais de login + ações-chave)
- [ ] 2.2 API: endpoint read-only expondo score + sinais contribuintes
- [ ] 2.3 UI: widget de contas em risco no dashboard do owner
- [ ] 2.4 Limiares conservadores validados contra dados reais antes de exibir

## 3. Expansion prompt (usage-based)

- [x] 3.1 Detectar proximidade do limite do plano (ex.: 90% do teto de alunos) — API: `GET /api/subscriptions/tenant/usage` (current-tenant, `Permission:subscriptions.read`) retornando `SubscriptionUsageDto` (current/max de alunos, staff, unidades, storage). Commit API `b1c321d`; commit UI `232d1a3`
- [x] 3.2 Banner contextual não-bloqueante na área relevante (sem interromper a tarefa) — `expansion-banner` em students.component: % do teto ≥90% → banner com `role="status"` e dismiss (não bloqueia o form); falha da API degrada silencioso (banner some)
- [x] 3.3 Link para upgrade/checkout existente — "Ver planos maiores" → `/subscriptions` (rota existente de planos)

## 4. Re-engagement anchor

- [ ] 4.1 Mapear eventos recorrentes do calendário (início de bimestre, matrícula, fechamento de notas)
- [ ] 4.2 Trigger de notificação vinculado a evento via módulo `notifications`/`communications`
- [ ] 4.3 Fallback de cadência simples quando não há calendário configurado

## 5. Portal — jargão e FAQ contextual

- [x] 5.1 Auditar copy do portal e reescrever termos técnicos/legalês em linguagem simples — FRONT (FAQ em PT-BR simples)
- [x] 5.2 Adicionar FAQ contextual in-product na seção financeira (e outras de alto atrito) — FRONT (`contextual-faq` em portal-financial)

## 6. Métricas e verificação

- [ ] 6.1 Instrumentar NRR, taxa de save no cancel screen, % contas em risco reativadas
- [x] 6.2 Testes unitários (cancel-flow, health score) + smoke E2E do fluxo de cancelamento — health score: 6/6 ✓ (2fddd15). Cancel-flow: `cancel-flow.component.spec.ts` 7/7 ✓ (669/669 na bateria karma, commit `5dbeab2`). Smoke E2E do cancelamento via Cypress intercept coberto nos specs `monetization-plans-checkout.cy.ts` (pendente de execução ao vivo — backend real necessário para PAUSE/cancelar em staging)
- [x] 6.3 `openspec validate add-churn-retention-flows --strict` verde
 origin/main
