## 1. Infra compartilhada (sem mudar comportamento existente)

- [x] 1.1 API: helper `TestPermissions`/matriz de headers no `TestClientFactory` para montar 401/403/404 de forma parametrizada (se ainda faltar) — BACK
- [x] 1.2 UI: criar `cypress/support/live.ts` com `liveLogin()`, `psqlExec()` idempotente e `authHeader()` (import explícito por spec; **não** ligar `supportFile` global) — FRONT
- [x] 1.3 Migrar 1 spec live existente para o helper como prova (ex.: `tenant-isolation.cy.ts`) e confirmar 14/14 verde — FRONT

## 2. Matriz de status HTTP (401/403/404/400) — back

- [x] 2.1 Spec `[Theory]` de matriz de rotas: sem token → 401 em amostra de controllers `[Authorize]` (students, grades, subscriptions, reports, roles) — BACK
- [x] 2.2 Autenticado com permissão errada → 403 (guardian `92000000001`/role sem `students.write`, `finance.manage`, `grades.write`) — BACK
- [x] 2.3 ID inexistente → 404 em CRUDs (students, guardians, classgroups, classrooms, subscriptions, notices) — BACK
- [x] 2.4 Cross-tenant (IDOR) → 404/403 em amostra além de students (subscriptions, grades, notices) — BACK
- [x] 2.5 Corrigir bugs encontrados nos blocos 2.1–2.4 (reproduzir → fix → regressão) — BACK

## 3. Validação de entrada (400 problem-details) — back

- [x] 3.1 Provar wiring dos validators existentes via HTTP: guardian, classroom, assignment, submission, lesson-plan → 400 com problem-details — BACK
- [x] 3.2 Payloads malformados: JSON inválido, campos obrigatórios ausentes, tipos errados, enum inválido, GUID não-UUID — BACK
- [x] 3.3 CPF/e-mail com formato inválido (inclui gate gov.br já coberto só em E2E) — BACK
- [x] 3.4 Corrigir bugs encontrados no bloco 3 — BACK (nenhum bug P0/P1: wiring completo nos 5 CRUDs; corpo de erro é ErrorDto {message,code}, não RFC7807 — contrato aceito pelo teste; CPF sem dígito verificador é P2 em 6.3)

## 4. Valores de fronteira e concorrência — back

- [x] 4.1 Paging: `page=0`, `pageSize=0/negativo`, `pageSize` gigante, `page` além do fim — BACK (sanitização correta em guardians/studentguardians/notices)
- [x] 4.2 Regras de negócio: pesos de avaliação somando ≠ 100, arredondamento de moeda (billing/checkout), janelas de data invertidas/limites — BACK (janelas invertidas em academic-years/events → 400; plano valor≤0/parcelas fora 1–36 → 400 após bug #7; peso fora de [0,1]/MaxScore≤0 → 400)
- [x] 4.3 Concorrência: escritas paralelas na mesma entidade / limite de assinatura (SubscriptionLimit) → comportamento determinístico (409 ou último-escrito documentado) — BACK (escritas rápidas sequenciais: último-escrito, sem duplicatas; limite exato/±1 determinístico no serviço; requests HTTP paralelos impossíveis na factory de teste — conexão física única, produção usa pool)
- [x] 4.4 Idempotência de re-run: operações repetidas (cancel, pay, seed) não corrompem estado — BACK (pagamento duplo → 400 "já está paga" + estado preservado; delete duplo → 404)
- [x] 4.5 Corrigir bugs encontrados no bloco 4 — BACK (bugs #6 e #7)

## 5. E2E ao vivo de escrita + negação na UI — front

- [ ] 5.1 Spec live de CRUD students (create → update → delete) com validação de form exibindo erros 400 — FRONT
- [ ] 5.2 Spec live de grades/attendance: escrita com valores inválidos → erro visível; happy path permanece verde — FRONT
- [ ] 5.3 Spec live de finance (installments/pay): pagamento repetido/expirado → recusa com mensagem clara — FRONT
- [ ] 5.4 Spec de negação de UI: guardian sem permissão acessando rotas admin → expulso/guard 403 (hoje só documentado, não testado) — FRONT
- [ ] 5.5 Spec live de roles/permissions: troca de role reflete no acesso (admin → limitado) — FRONT
- [ ] 5.6 Corrigir bugs de front encontrados nos blocos 5.1–5.5 — FRONT

## 6. Triagem e correção de bugs encontrados

- [x] 6.1 Listar todos os bugs descobertos pela bateria neste checklist, com severidade (P0/P1/P2) e origem (bloco) — ambos
  1. **P0 (bloco 2)** — 91 actions de controllers sem `[Authorize]`/`[AllowAnonymous]`; PII (CPF/e-mail/telefone) acessível sem token → fix em 21 controllers + teste invariante de classificação.
  2. **P0 (bloco 2)** — guardians cross-tenant: `Guardian` sem escopo (`GetAll()` global) vazava PII de todos os tenants → coluna `TenantId` + regra OR vínculo + migration `GuardianTenantScope` (backfill) + gates no service/controller.
  3. **P0 (bloco 2)** — grades/assessments IDOR cross-tenant (lookup global por GUID/CPF) → gates via `Assessment→AcademicYear→TenantId` + `StudentPlan→SchoolUnit→TenantId` + mapeamento 404.
  4. **P0 (bloco 2)** — EF model cache: primeiro model sem tenant fixava **todos** os query filters de tenant DESLIGADOS no processo (Notice/Event/Document/etc. vazavam) → `TenantAwareModelCacheKeyFactory` + `IgnoreQueryFilters` nos métodos explícitos-por-tenant.
  5. **P1 (bloco 2)** — login de tenant recém-registrado emitia `school_unit_id` vazio (leitura da unidade sob filtro do tenant ambiente) → `SchoolUnitRepository` explícitos com `IgnoreQueryFilters`.
  6. **P1 (bloco 4)** — `POST /api/classgroups/{id}/assessments`: falha de validação/turma inexistente virava exceção → 500 → command/handler retornam `Result` + controller mapeia 400/404.
  7. **P1 (bloco 4)** — `POST /api/plans` com valor/parcelas fora da regra: `ArgumentException` → 500 **com `ex.Message` vazado no corpo** → `PlanService.CreateAsync` retorna `Result` + controller mapeia 400.
- [x] 6.2 Fix de P0/P1: teste vermelho → correção → verde → commit (mensagem detalhada PT-BR com escopo `test`) — ambos (bugs 1–5 no commit do bloco 2; bugs 6–7 no commit do bloco 4)
- [x] 6.3 Fix de P2 ou justificativa registrada para adiamento — ambos
  - **P2 (bloco 3)** — CPF sem dígito verificador é aceito (validação só de tamanho, `CpfValidationService`); enforce de DV exigiria decisão de produto + auditoria de CPFs sintéticos em seeds/E2Es (documentado em `InputValidationIntegrationTests.Guardian_CpfComDígitosRepetidos_AceitoPorDesign_Sem5xx`).
  - **P2 (bloco 2)** — granularidade de policies `Permission:x.y` nos 17 controllers com `[Authorize]` de classe (consumidores cruzados impedem policies hoje; registrado como follow-up).
  - **P2 (bloco 4)** — FK violations em payloads válidos com GUIDs inexistentes retornam 500 (ex.: submission com `AssignmentId` inexistente); handler global de exceção mapeando `DbUpdateException` → 409/400 é follow-up.

## 7. Validação final

- [ ] 7.1 `dotnet test tests/SchoolManagement.Tests` verde (nova bateria incluída; 0 falhas) — BACK
- [ ] 7.2 `npx ng build --configuration development` + `npm test` (Karma) verdes — FRONT
- [ ] 7.3 Bateria Cypress live completa verde contra API `:5067` (specs novas + migradas) — FRONT
- [ ] 7.4 Commits: submodules (api/ui) + bump no root com mensagem resumida — ambos
- [ ] 7.5 `openspec validate add-adversarial-test-battery --strict` verde — ambos
