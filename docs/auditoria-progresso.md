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
| 6 | Docker não-root | MÉDIA | — | **Concluída** |
| 7 | Backup + restore testável | ALTA | 5 | **Concluída (local)** — automação em produção pendente |
| 8 | `TenantId` em Assessment/Grade | MÉDIA | 1 | **Concluída** |
| 9 | Token em localStorage → cookie httpOnly | MÉDIA | — | **Concluída** |
| 10 | Versionamento `/api/v1` | MÉDIA | — | **Concluída** |

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

## Tarefa 6 — Docker não-root (MÉDIA) — **Concluída**

**Alteração**: `school-management-api/Dockerfile` cria `appuser` (uid 10001) e
`USER appuser`; `/app` com ownership do appuser.

**Evidência**:
- `docker build` OK;
- `docker run --rm --entrypoint id sma-api-nonroot` → `uid=10001(appuser)`;
- `/app` gravável pelo appuser;
- app inicia como não-root (falha só na conexão DB, sem erro de permissão).

## Tarefa 7 — Backup + restore (ALTA) — **Concluída localmente**

**Alteração**: `scripts/backup-db.sh` (dump comprimido com timestamp) e
`scripts/restore-db.sh` (cria banco destino e restaura); `DEPLOY.md` atualizado;
`backups/` no `.gitignore`.

**Evidência**: ciclo real — backup 183 KB → restore em
`SchoolManagementDb_RestoreTest` → contagens idênticas (7 alunos, 12 conquistas,
9 contas) → banco de teste removido.

**Pendente (infra)**: automação em produção (Supabase Pro ou cron diário) e
retenção — não é código.

## Tarefa 8 — `TenantId` em Assessment/Grade (MÉDIA/ALTA) — **Concluída**

**Problema**: isolamento indireto (Grade → Assessment → AcademicYear). Qualquer
query que esquecesse o join via aluno/turma; o `GradeRepository.ListByStudentAsync`
era global.

**Alteração**:
- `Assessment.TenantId` e `Grade.TenantId` (domínio + `SchoolContext` com índice).
- Query filters globais em `Assessment`/`Grade` (bloco `_tenantFilterEnabled`).
- Migration `AssessmentGradeTenantScope`: colunas + **backfill**
  (`Assessments` ← `AcademicYears`; `Grades` ← `Assessments`); 0 linhas órfãs.
- Escrita: `AssessmentService.CreateAsync` e `GradeService.UpsertAsync` carimbam
  o tenant do servidor; `FrontendDemoDataSeeder` semeia com `TenantId`.

**Evidência**:
- Migration aplicada no dev: 8 avaliações / 48 notas, **0** com `TenantId` vazio.
- `CrossTenantSurfaceSamplingIntegrationTests` + `GradingFormulasIntegrationTests`
  **13/13** (dados com TenantId; cross-tenant continua 404).
- Suíte API **1162/0, 5 skips**.

**Riscos residuais**: dados legados sem vínculo (nenhum no dev) ficam invisíveis;
novos fluxos que criem `Assessment`/`Grade` precisam carimbar `TenantId`
(garantido nos dois pontos de escrita atuais).

## Tarefa 9 — Token em cookie HttpOnly (MÉDIA) — **Concluída**

**Problema**: access/refresh em `localStorage` (`sma_auth`) — XSS rouba sessão.

**Alteração**:
- API: login/refresh gravam `sma_access_token`/`sma_refresh_token` com
  `HttpOnly`, `SameSite=Lax`, `Path=/api`, `Secure` em HTTPS; `JwtBearer`
  lê o token do cookie quando não há `Authorization`; novo `POST /api/auth/logout`
  limpa os cookies.
- UI: `AuthService` para de gravar token/refresh no storage (só metadados);
  `refresh()` envia corpo vazio (cookie); `logout()` chama o backend;
  bootstrap restaura a sessão via refresh.

**Evidência**:
- `AuthCookieSessionTests` 2/2 (login com HttpOnly/Path=/api; logout limpa).
- **Ponta a ponta real** (API Development + curl): login 200 → cookie
  `sma_access_token` → `GET /api/students` **sem Authorization** 200 → logout
  204 → `GET /api/students` 401.
- Karma **820/820** (spec de logout ajustada).

**Risco residual**: em `ng serve` cross-origin (localhost:4200 → 127.0.0.1:5067)
o cookie depende do proxy same-origin; em produção (Vercel rewrite) é same-origin.

## Tarefa 10 — Versionamento `/api/v1` (MÉDIA) — **Concluída**

**Problema**: 209 endpoints sem versão — breaking change quebra cliente.

**Alteração**:
- `ApiVersioningMiddleware`: `/api/v1/...` → `/api/...` (canônico); `/api/...`
  segue como alias legado.
- `UseRouting` explícito **depois** do rewrite (o `WebApplication` adiciona o
  roteamento no início; sem isso o endpoint era selecionado pelo path original → 404).
- UI: `apiBaseUrl` → `/api/v1` em todos os environments.
- `docs/api-versioning.md` + política (v2 futura, alias deprecated).

**Evidência**:
- `ApiVersioningMiddlewareTests` 5/5 + `ApiVersioningIntegrationTests` 4/4
  (v1 200, alias 200, v2 404, rota autenticada em v1).
- Real: `/api/v1/support/health` 200, `/api/support/health` 200, `/api/v2/...` 404.
- API **1173/0**; Karma **820/820**.

**Risco residual**: versionamento é por prefixo (sem implementações paralelas);
v2 exigirá controllers/handlers próprios ou branch explícito.

## Smoke pós-deploy (25/11)

| Checagem | Resultado |
|---|---|
| UI (Vercel) raiz | 200 |
| UI → API (proxy `/api/support/health`) | 200 |
| `/api/v1/students` sem auth | 401 |
| `/api/v1/offline/sync-batch` sem auth | 401 |
| `/api/students` (alias legado) sem auth | 401 |
| `/metrics` sem/com token | 401 / 200 |
| Prometheus targets prod/staging | UP |
| **Banco de produção** | **0 usuários**, 12 conquistas (baseline aplicado) |

> **Produção ainda não tem nenhum usuário cadastrado** — o produto não é utilizável
> até o primeiro diretor/secretaria ser provisionado (fluxo de cadastro/registro
> ou criação manual). O baseline (permissões/papéis/catálogo) já roda no startup.

## Onboarding pela UI (25/11) — validado em produção

| Etapa | Resultado |
|---|---|
| `/cadastro` (UI) → submit | **201** → `/login?registered=1` |
| Login (UI) | **200** → dashboard |
| `/my-area` | **sem 428**; Central de Conquistas renderiza (Nível 1, 0/12) |

**Bug encontrado e corrigido**: o cadastro não gravava o aceite de termos
(`TermsOfUseAcceptance`) — o checkbox da UI não virava registro no backend e o
novo diretor nascia preso em 428 sem ação de aceite. Corrigido no
`OnboardingController.RegisterSchool` (commit `752954c`).

> Dados de teste criados em produção: `Escola Piloto E2E`
> (diretor@escolapiloto.com, preso no 428 antigo) e `Escola Piloto 3`
> (diretor3@escolapiloto.com, funcional). Posso removê-los se quiser.

## Bootstrap de banco novo corrigido (25/11) — API `e609631`

**Bug**: qualquer banco **novo** quebrava no startup — `42P07: relation
"AdhesionContractAudits" already exists` (a migration `20260715174210_AddSetupProgress`,
gerada pelo EF, recriava tabelas que as migrations irmãs
`20260712180000`/`20260712190000`/`20260713100000` já criam) e, corrigido isso,
`42P01: relation "StudentClasses" does not exist` (a chain do School cria a matview
`mv_retention_by_cohort`, que lê tabelas do Academic).

**Correção** (API `e609631`, submicronô):
- `AddSetupProgress` não recria mais as tabelas das migrations irmãs (PKs/FKs/índices
  idênticos — conferidos por teste); o `Down` também deixa de derrubá-las.
- `Program.cs` migra **Academic antes de School** (ordem obrigatória: a matview do
  School lê `StudentClasses`/`ClassGroups` do Academic).
- Backfill de `TenantId` do Academic passou a tolerar `SchoolUnits` ausente
  (`to_regclass`), já que a chain do Academic roda antes da do School.
- Novo guard: `MigrationBootstrapIntegrationTests` aplica a **cadeia completa** em
  banco vazio (tabelas, índices, FKs e matviews) — a suíte usava `EnsureCreated`, por
  isso nunca exercitou o histórico de migrations.

**Validação**: suíte **1207/0/5**; banco novo via `dotnet ef` (Academic → School) com
107 tabelas + 2 matviews; API subindo contra ele → `/api/support/health` **200**,
baseline e default tenant aplicados; schema das migrations comparado com o do
`EnsureCreated` (só difere nas 3 colunas `TenantId` das tabelas-legada singulares —
drift pré-existente, o dev DB também não tem).

**Deploy**: staging `dep-dc3asd0m7kps73dnt2u0` e produção `dep-dc3ategm7kps73do01q0`
(commit `e6096312`, auto-deploy desligado → manual). Smoke: `/api/support/health`
**200** em staging e produção, `database: Healthy`; `/metrics` **401** sem token
(comportamento esperado — exige `metrics_token`).

## Limpeza e restore (25/11)

- **Produção limpa**: removidos os tenants de teste `escola-piloto-e2e` e
  `escola-piloto-3` (com usuários, unidades, períodos e vínculos) em transação.
  Restou apenas o `default` (placeholder da plataforma) — **0 usuários**.
- **Restore validado**: dump de produção (pg_dump 17, 80 KB) restaurado em
  Postgres 17 descartável; contagens idênticas (1 tenant, 12 conquistas,
  38 permissões, 4 papéis). Procedimento documentado no `DEPLOY.md`.

## Auditoria de acessibilidade/responsividade (25/11)

**Corrigido**:
- **Overflow horizontal no mobile** (390px → scrollWidth 610): `.layout__main`
  sem `min-width:0` + topbar com seletor de ano letivo/busca. Agora
  `min-width:0`, topbar com `flex-wrap` e seletor oculto <900px. Verificado:
  `scrollWidth == clientWidth == 390` em `/`, `/students`, `/my-area`, `/finance`.
- **Login sem rótulo associado**: `<label>` sem `for` + input sem `id` (2 campos
  não anunciados por leitor de tela). Agora `for`/`id` + `autocomplete`
  (`username`/`current-password`). Verificado: 0 inputs sem label.

**Verificado**: `lang="pt-BR"`, landmarks header/nav/footer, 0 botões sem texto,
0 overflow nas 4 telas em 390px, cadastro com 7 inputs todos rotulados.

**Menores (não corrigidos)**: H1 duplicado em algumas telas; ausência de
`<main>`; saltos de heading (H2→H3). **Não auditado**: contraste (precisa de
axe/visual), leitor de tela completo, armadilha de foco, foco visível.

## Problemas ainda pendentes

- ALTA: **automação** do backup em produção (7) — código/script pronto, falta
  agendamento/retenção.
- Nenhuma tarefa do plano de auditoria pendente (1–10 concluídas).
- **Env vars**: `school-management-api/.env` (novos segredos) e
  `scripts/render-env-vars.sh` (GET→merge→PUT; dry-run por padrão).
  **Staging aplicado (21/21, banco `SchoolManagementDBDev`)** e
  **produção aplicada (21/21, 7/7 valores conferidos)**.
- **Aplicado e verificado (24/11)**: serviços reiniciados e re-deployados;
  `/metrics` **401 sem token** e **200 com token** em prod e staging; health 200.
  `prometheus.yml` validado com `promtool` e usando `credentials_file`
  (`monitoring-package-api/observability/metrics_token`, gitignored).
- Não auditado: UX em navegador, carga/performance, acessibilidade, upload,
  integrações reais Asaas/Auth0, restore de backup.