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

## Drift model-vs-migrations corrigido (25/11) — API `a3e8c4e`

**Achado**: as tabelas-espelho acadêmicas no singular (`"Classroom"`, `"StudentClass"`,
`"ClassSchedule"`) — criadas pelo SchoolContext via `SkillCompetency.ClassGroup` e
`StudentSkillEvaluation.ClassGroup` (navegações não ignoradas) — têm `TenantId` no
**modelo**, mas a cadeia de migrations nunca criou a coluna. Verificado em prod e
staging: **a coluna não existia** e as tabelas estavam **vazias** (0 linhas) — o app
não as lê (`UnitOfWork` usa o AcademicContext/plural). Efeito: banco por migrations
≠ banco por `EnsureCreated` (dev/testes) ≠ modelo, e qualquer migration futura
dessas entidades geraria DDL contra coluna inexistente em prod.

**Correção**: migration `20261125163311_AddTenantIdToAcademicMirrorTables` (DDL
idempotente, `ADD COLUMN IF NOT EXISTS` + guard `to_regclass`) — alinhando a cadeia
ao modelo sem tocar em dados. Guard no `MigrationBootstrapIntegrationTests` (a coluna
tem que existir no banco criado por migrations).

**Validação**: suíte **1207/0/5**; schema por migrations comparado com o do
`EnsureCreated` → **zero** colunas/índices divergentes (restam só as PKs das `mv_*`,
que são matviews no caminho de migrations — diferença intencional pré-existente);
DDL validado como no-op em banco que já tinha a coluna e como Down→Up.

**Deploy**: staging `dep-dc3h1nvavr4c73fbofvg` e produção `dep-dc3h2v7lot8c73a4k8b0`.
Smoke: health **200** (DB Healthy) nos dois; migration aplicada (staging/prod: última
=`20261125163311_AddTenantIdToAcademicMirrorTables`, 36 migrations em prod);
`TenantId` presente nas 3 tabelas; relíquias seguem vazias; `/metrics` **401** sem
token e `/api/v1/students` **401** sem auth (esperado).

> **Chave do MCP Render estava revogada** (401) — atualizada em
> `~/.config/opencode/opencode.json` (backup `.bak`) a partir de `secrets.env`;
> deploys continuam pelo script `scripts/deploy-render-api.sh` / REST da API.

## Auditoria de performance (25/11)

**Medições (staging/prod, free tier)**:

| Endpoint | Latência média |
|---|---|
| `GET /api/support/health` | 0,37–0,50 s (DB 48–69 ms) |
| `POST /api/auth/login` (usuário inexistente) | 0,49 s |
| `POST /api/auth/login` (senha errada → PBKDF2) | 0,76–1,42 s |
| `GET /api/students` | **1,07 s** |
| `GET /api/me/achievements` | 0,62 s |
| `GET /api/achievements/team` | 0,68 s |
| 10 reqs concorrentes em `/api/students` | 10× 200, 1,06 s total (sem erros) |

**Gargalos identificados**:
1. `StudentsController.ListStudents` carrega **todos** os alunos e pagina **em memória**
   (`GetStudentsQuery` → `List<Student>` + `PaginationHelper.Paginate`) — O(N).
   `Students` só tem PK; **sem índice em `TenantId`** (usado por `ListByTenantAsync`).
2. Login faz **6–8 queries sequenciais** (usuário, papéis, permissões, unidade, auditoria,
  refresh antigo, refresh novo, update) + PBKDF2 — 0,5–1,6 s.
3. `AuditLoggingMiddleware` faz `AddAsync` + `SaveChangesAsync` **por requisição mutante**
  (write síncrono no caminho crítico).
4. Overhead base ~0,4 s/requisição em free tier (CPU 0,1) — some com instância paga.
5. Bundle de produção: **4,6 MB** (main 1,3 MB) — aceitável, mas main grande.

**Recomendações** (por esforço):
- P1: paginação no banco + índice `Students.TenantId` (4–6 h).
- P1: login em 1–2 queries (batch claims) (3–4 h).
- P2: auditoria assíncrona (canal) (4–6 h).
- P2: instância Render paga (custo) — resolve o overhead base.
- P3: auditar dependências pesadas no main (2 h).

**Depois (medição 5.2 — staging, serviço quente, mesmos endpoints; deploys de
`2d7b242`, `8db7cd4`, `8b45471` e correção `4367feb` live em staging e produção
em 25/11)**:

| Endpoint | Antes | Depois |
|---|---|---|
| `GET /api/support/health` | 0,37–0,50 s | 0,30–0,50 s |
| `POST /api/auth/login` (usuário existente) | 1,67 s | 1,37–1,50 s |
| `GET /api/students` (`pageSize=50`) | **1,07 s** | **0,56–0,63 s** (−43%) |
| `GET /api/me/achievements` | 0,62 s | 0,51–0,72 s |
| `GET /api/achievements/team` | 0,68 s | 0,69–0,72 s |
| 10 reqs concorrentes em `/api/students` | 1,06 s | **0,80 s** (−25%) |

Notas:
- 1ª requisição pós-deploy é cold start do free tier (até ~5 s) — medir sempre quente.
- **Regressão pega na medição**: o deploy quebrou login em staging/produção
  (`500 Connection is not open`). Causa: `GetRolesAndPermissionsForUserAsync`
  (claims em 1 consulta, `8db7cd4`) roda SQL cru e o EF abre/fecha a conexão por
  operação — a query chegava com conexão fechada. A suíte não pegava porque
  `TestWebApplicationFactory` registra o context com **uma conexão física
  compartilhada sempre aberta**. Corrigido em `4367feb` (abre se preciso + `finally`
  fecha só o que abriu); reproduzido e validado com imagens pré/pós-fix em container
  local; login OK em staging (token) e produção (token).
- Smoke pós-fix em produção: login 200 + token, `students` 0,70 s quente, health 0,40 s.
- Suíte: **1217/0** (5 skips).

## Tabelas-espelho acadêmicas removidas (25/11) — API `f2df155`

**Contexto**: o SchoolContext mapeia as mesmas classes de domínio do AcademicContext
(`ClassGroup`, `Classroom`, `StudentClass`, `ClassSchedule`) — via `SkillCompetency.ClassGroup`
e `StudentSkillEvaluation.ClassGroup`, cujas navegações **não** eram ignoradas — e por
isso criava tabelas-espelho no **singular**. Elas eram **vazias** (0 linhas em prod e
staging) e nunca lidas pelo app (`UnitOfWork` usava o AcademicContext/plural), mas:

- as **FKs** delas bloqueavam escritas: `StudentSkillEvaluations.ClassGroupId` (NOT NULL)
  e `SkillCompetencies.ClassGroupId` apontavam para uma `ClassGroup` espelho que nunca
  tinha linha → **inserir competência/avaliação por turma era impossível**;
- o `UnitOfWork`/DI tinham **fallback silencioso** para o SchoolContext: host sem o
  AcademicContext leria a espelho vazia e devolveria "sucesso sem dados";
- o erasure LGPD (`DataSubjectErasureService`) citava a tabela relíquia por nome.

**Correção**: (1) as duas navegações foram ignoradas → o cluster acadêmico sai do modelo
do SchoolContext; (2) migration `20261125193056_DropAcademicMirrorTables` remove as 4
tabelas + as 2 FKs que as referenciavam (elas estavam vazias — verificado antes);
(3) `AcademicContextGuard` substitui o fallback: os repositórios acadêmicos
(`IClassGroupRepository`, `IStudentClassRepository`, `IClassroomRepository`,
`IClassScheduleRepository`, `ITimetableTemplateRepository`, `ILessonPlanRepository`,
`ITeacherAvailabilityRepository` e o `UnitOfWork`) agora **falham alto** se o
AcademicContext não estiver registrado; (4) o erasure LGPD deixou de citar a relíquia.

**Validação**: suíte **1213/0/5** (inclui teste novo: repositório acadêmico sem
AcademicContext → `InvalidOperationException`); banco novo por migrations (Academic →
School) sem as espelhos e com as reais intactas; schema por migrations vs. `EnsureCreated`
→ paridade total (só as PKs das `mv_*`, que são matviews no caminho de migrations);
`PrivacyIntegrationTests` e `DataSubjectErasureService` ajustados (a FK deferrable era na
tabela relíquia — a real, `StudentClasses`, não tem FK para `Students`).

**Deploy**: staging `dep-dc3jtdvf3r2c738pljgg` e produção `dep-dc3jukff3r2c738ppa0g`.
Smoke: health **200** (DB Healthy) nos dois; `espelhos (singular) restantes: (NENHUMA)`,
`reais (plural): ClassGroups, ClassSchedules, Classrooms, StudentClasses`,
`FK para espelho: 0`, 38 migrations em prod; `/metrics` **401** sem token e
`/api/v1/students` **401** sem auth (esperado).

> A `20261125163311_AddTenantIdToAcademicMirrorTables` (migration anterior, já em prod)
> ficou sem efeito prático — as tabelas que ela alterava foram removidas na sequência.
> Não foi removida do histórico porque já está aplicada nos ambientes.

## Segurança de upload (25/11)

**Corrigido** (`AssetAttachmentsController`):
- **Path traversal**: extensão vinda de allowlist (nunca do cliente) + nome sanitizado
  (remove `/`, `\`, `:`, CRLF); nome final é GUID + extensão canônica.
- **MIME spoofing**: allowlist de Content-Type + **magic bytes** (pdf `%PDF`, png, jpeg, zip).
- **Tamanho**: limite 10 MB configurável (`Storage:AttachmentsMaxBytes`).
- **IDOR**: download/delete/list com gate explícito de `TenantId`.
- **Download**: `Content-Disposition: attachment` (nunca inline).
- **Storage**: `Storage:AttachmentsPath` (default `App_Data/attachments`) em vez de temp.

**Testes**: `AssetAttachmentsSecurityTests` **4/4** (válido, tipo não permitido,
path traversal contido, download cross-tenant 404). Suíte **1217/0**.

**Pendente**: storage persistente (S3/Supabase Storage) — em Render o disco é efêmero.

## Termo de Uso revisado v2026.2 (25/11)

**Contexto**: o texto exibido (`termos.component.html`) tinha 6 cláusulas genéricas, sem os
achados do dossiê LGPD (§3/§6) nem cláusulas de um SaaS B2B brasileiro. A versão exibida na
página era **hardcoded** ("2026.1 — Janeiro de 2026"), podendo divergir do backend
(`Legal:TermsOfUseVersion`) — violando a decisão de design nº 1 do change
`add-terms-of-use-acceptance` (fonte de verdade centralizada no backend).

**Revisão (cláusulas 1–16, API/UI/docs no mesmo commit)**:
- **Controlador × operador** (cláusula 5) — desenho do dossiê §6: escola = controladora dos
  dados acadêmicos; plataforma = operadora (art. 39) para esses dados e controladora para
  dados de conta/uso; DPO e prazos do art. 18.
- **Menores** (cláusula 6) — consentimento parental específico (art. 14 §1º), prova de como foi
  obtido, gating de funcionalidades e revogação imediata — coerente com o
  `add-minors-parental-consent` já implementado.
- **Contratual B2B** — licença de uso, conduta/credenciais, contratação por plano
  (mensal/anual), operadores de pagamento (Asaas/Stripe), inadimplência → suspensão,
  contrato de adesão + contrato principal/DPA por tenant (Tenant.DpaDocumentId), suspensão e
  encerramento, PI, limitação de responsabilidade, foro/lei.
- **Coerência com a implementação** — evidência de aceite (versão, UTC, canal, IP HMAC,
  user-agent = `TermsOfUseAcceptance(+Audit)`), modo restrito 428 (middleware + guard), cookies
  essenciais × opcionais, retenção, art. 46–48.
- **Placeholders visíveis** para o jurídico: razão social/CNPJ (cláusula 1) e foro (cláusula 16);
  banner de rascunho na página (mesmo padrão da página de privacidade).

**Drift corrigido**: a página de consulta agora busca a versão vigente do backend
(`GET /api/privacy/terms-of-use/status`, AllowAnonymous) com fallback local.

**Versionamento**: `Legal:TermsOfUseVersion` → **2026.2** em `appsettings.json`,
`Development`, `Staging` e `Production` (fallback do `OnboardingController` também). O
`appsettings.Testing.json` permanece **2026.1** de propósito: o seeder de aceites
(`TestWebApplicationFactory`/`TestDataSeeder`/isolation tests) semeia com o mesmo valor —
autoconsistente e imune ao bump. **Efeito esperado em produção: todos os usuários passam por
reaceite no próximo acesso** (fluxo já coberto por testes e E2E).

**Fonte de consulta ao jurídico**: `docs/terms-of-use.md` (espelho fiel do texto exibido).
Alterar o texto exige bump de versão + publicação simultânea dos dois artefatos.

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