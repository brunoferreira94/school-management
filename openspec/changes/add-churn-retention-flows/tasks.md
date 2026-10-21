
## 1. Cancel flow (win-back)

- [x] 1.1 Criar componente `cancel-flow` (3 passos: perda concreta → alternativa → motivo) — FRONT
- [x] 1.2 Passo 1: exibir perda concreta (contagem real de alunos/turmas/meses de histórico) — FRONT (consome `AccountSummary`)
- [x] 1.3 Passo 2: oferecer alternativa (pausar 30 dias / 1 mês grátis) — FRONT
- [x] 1.4 Passo 3: coletar motivo via pergunta aberta (texto livre + tag opcional) — FRONT
- [x] 1.5 Substituir `CANCEL_CONFIRM` (confirm nativo) pelo novo fluxo em `subscriptions.component` — FRONT
- [x] 1.6 API: endpoints de pausa e cancelamento com persistência do motivo + timestamp (see PR #74)
- [x] 1.7 Garantir que o cancelar permanece acessível e honesto em cada passo (sem dark pattern) — FRONT (botão sempre visível)

## 2. Health score (risco de churn)

- [x] 2.1 API: calcular health score por conta (janelas 14/30 dias, sinais de login + ações-chave) ✅ 2026-10-21 commit 2fddd15 — `ChurnHealthScore` pura (pesos login≤45/ações≤40/volume30d≤15) + 6 testes unitários
- [x] 2.2 API: endpoint read-only expondo score + sinais contribuintes ✅ 2fddd15 — GET /api/owner/retention/health e /api/owner/tenants/{id}/retention-health (Permission:owner.read); fonte = AuditLogs.TenantId (migration AddTenantIdToAuditLogs)
- [x] 2.3 UI: widget de contas em risco no dashboard do owner ✅ 2026-10-21 commit 88df6a5 — app-retention-risk-widget na aba Prontidão; ship-dark controlado por `ChurnHealth:WidgetEnabled` (staging/dev=true, prod=false)
- [ ] 2.4 Limiares conservadores validados contra dados reais antes de exibir (iniciado: limiares versionados + flag ship-dark; falta coletar dados reais no staging e flipar a flag em prod)

## 3. Expansion prompt (usage-based)

- [ ] 3.1 Detectar proximidade do limite do plano (ex.: 90% do teto de alunos)
- [ ] 3.2 Banner contextual não-bloqueante na área relevante (sem interromper a tarefa)
- [ ] 3.3 Link para upgrade/checkout existente

## 4. Re-engagement anchor

- [ ] 4.1 Mapear eventos recorrentes do calendário (início de bimestre, matrícula, fechamento de notas)
- [ ] 4.2 Trigger de notificação vinculado a evento via módulo `notifications`/`communications`
- [ ] 4.3 Fallback de cadência simples quando não há calendário configurado

## 5. Portal — jargão e FAQ contextual

- [x] 5.1 Auditar copy do portal e reescrever termos técnicos/legalês em linguagem simples — FRONT (FAQ em PT-BR simples)
- [x] 5.2 Adicionar FAQ contextual in-product na seção financeira (e outras de alto atrito) — FRONT (`contextual-faq` em portal-financial)

## 6. Métricas e verificação

- [ ] 6.1 Instrumentar NRR, taxa de save no cancel screen, % contas em risco reativadas
- [ ] 6.2 Testes unitários (cancel-flow, health score) + smoke E2E do fluxo de cancelamento (parcial: health score 6/6 ✅; falta cancel-flow + smoke E2E)
- [x] 6.3 `openspec validate add-churn-retention-flows --strict` verde
 origin/main
