# Auditoria de Prontidão — Plano de Execução e Progresso

> Origem: auditoria independente de 24/11/2026 (14 seções, notas e veredito
> `CONDITIONAL GO`). Este arquivo é a **fonte de verdade do progresso**: cada
> tarefa só é marcada como concluída com evidência verificável (teste + suíte).

## Ordem de execução (gravidade × impacto × dependência)

| # | Tarefa | Gravidade | Dependência | Status |
|---|---|---|---|---|
| 1 | IDOR no boletim do aluno (`student-report-card`) | CRÍTICA | — | **Concluída** |
| 2 | Webhook Asaas fail-open | CRÍTICA | — | **Concluída** |
| 3 | Guard do segredo JWT padrão | CRÍTICA | — | **Concluída** |
| 4 | `/metrics` público | ALTA | — | **Concluída** |
| 5 | Conciliação financeira stub | CRÍTICA | — | **Concluída** |
| 6 | Docker não-root | MÉDIA | — | Pendente |
| 7 | Backup automático + restore | ALTA | 5 | Pendente (infra) |
| 8 | `TenantId` em Assessment/Grade | MÉDIA | 1 | Pendente (grande) |
| 9 | Token em localStorage → cookie httpOnly | MÉDIA | — | Pendente |
| 10 | Versionamento `/api/v1` | MÉDIA | — | Pendente |

## Tarefa 1 — IDOR no boletim (CRÍTICA) — **Concluída**

**Problema**: `GET /api/GradesReports/student-report-card?cpf=...` (e
`/api/students/{cpf}/report-card`) não validava tenant; qualquer escola com
`reports.academic.read` lia notas de aluno de outra escola por CPF.

**Alteração**:
- `AssessmentService` agora recebe `ITenantContext` e:
  - `GetStudentReportCardAsync` usa `GetByCpfForTenantAsync(cpf, tenantId)` +
    `ListByStudentForTenantAsync(cpf, tenantId)`;
  - `GetClassGradesReportAsync` valida `classGroup.TenantId == tenantId`
    explicitamente (não confia só no query filter).
- `GradesReportsController` mapeia falha para 404 (antes devolvia 200 com corpo
  vazio).

**Evidência**:
- `tests/.../Integration/AssessmentReportCardTenantIsolationTests.cs` — 3/3:
  escola A → 404 para boletim/turma de B; 200 para o próprio boletim.
- Suíte API: **1147 aprovados, 0 falhas, 5 skips** (1.152 total).

**Riscos residuais**:
- `Assessment`/`Grade` seguem sem `TenantId` (isolamento indireto) — tarefa 8.
- Outros serviços em background usam `GetByCpf` global (baixo risco, pois partem
  de um aluno já resolvido no tenant).

## Tarefa 2 — Webhook Asaas fail-open (CRÍTICA) — **Concluída**

**Problema**: `SubscriptionsController.ValidateWebhookToken` retornava `true`
quando `Asaas__WebhookToken` não estava configurado — qualquer POST forjava
pagamento.

**Alteração**: sem segredo → **fail-closed** (401) em Testing/Staging/Production;
exceção apenas em Development. Comparação em tempo constante
(`CryptographicOperations.FixedTimeEquals`).

**Evidência**: `SubscriptionsWebhookSecurityTests` 2/2 (sem token → 401; token
errado → 401).

## Tarefa 3 — Guard do segredo JWT (CRÍTICA) — **Concluída**

**Problema**: `appsettings.json` com segredo default de 49 chars passava no
guard de tamanho; qualquer ambiente sem `Jwt__Secret` aceitava token forjado.

**Alteração**: `JwtSecretGuard` rejeita default/placeholder (`${...}`, `{{...}}`)
e segredos < 32 chars fora de Development/Testing.

**Evidência**: `JwtSecretGuardTests` 9/9 (default em Production/Staging rejeitado;
placeholder rejeitado; curto rejeitado; válido aceito).

## Tarefa 4 — `/metrics` público (ALTA) — **Concluída**

**Problema**: `PrometheusController` com `[AllowAnonymous]` e rewrite público no
`vercel.json`.

**Alteração**: `Metrics:AccessToken` + header `X-Metrics-Token`/Bearer; sem token
→ 401 fora de Development (fail-closed).

**Evidência**: `PrometheusControllerTests` 6/6 (3 novos: sem token 401, token
errado 401, token válido 200).

**Ação de deploy pendente**: definir `Metrics__AccessToken` no Render e
configurar o Prometheus (header) — documentar no runbook.

## Tarefa 5 — Conciliação stub (CRÍTICA) — **Concluída**

**Problema**: `ManualMatchAsync` retornava sucesso sem persistir; a conquista
`PaymentReconciled` desbloqueava em cima de uma baixa inexistente.

**Alteração**: persiste `Installment.IsPaid = true`; valida que a parcela
pertence à unidade do chamador (`StudentPlan → SchoolUnit`) — fecha IDOR
financeiro; controller devolve 404 e só registra a conquista em sucesso real.

**Evidência**: `ReconciliationManualMatchTests` 2/2 (baixa persiste; parcela
inexistente → 404) + `AchievementListenersIntegrationTests` 6/6.

## Problemas ainda pendentes

- ALTA: backup automático + restore (7) — infra, não código.
- MÉDIA: Docker root (6), `TenantId` em Assessment/Grade (8), token em
  localStorage (9), versionamento (10).
- **Ação de deploy**: definir `Metrics__AccessToken` e `Jwt__Secret` reais nos
  ambientes; configurar o Prometheus com o header do `/metrics`.
- Não auditado: UX em navegador, carga/performance, acessibilidade, upload,
  integrações reais Asaas/Auth0, restore de backup.