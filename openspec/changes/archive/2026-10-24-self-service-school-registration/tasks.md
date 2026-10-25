# Tasks — Cadastro self-service de escola

## 1. API — endpoint
- [x] 1.1 `POST /api/onboarding/register-school` (`[AllowAnonymous]`, rate-limited "PortalRegister") — existente, verificado 2026-10-24
- [x] 1.2 DTO: `RegisterSchoolRequest { schoolName, principalName, principalCpf, principalEmail, password, segment? }` — existente (+ segment opcional do change de templates)
- [x] 1.3 Cadastro atômico em transação (`IUnitOfWork` begin/commit/rollback cobrindo School+Academic contexts): cria `Tenant` (slug suave) + `SchoolUnit` + `Staff`/`UserAccount` (hash) + `AcademicYear` ativo default + `TenantSubscription` Free com `Status = Trial`, `TrialEndsAtUtc = +14 dias` + `SetupProgress` (segmento) — **transação implementada 2026-10-24** (antes eram SaveChanges independentes que deixavam tenant parcial em falha); validação de segmento movida para antes das escritas (fail fast)
- [x] 1.4 Idempotência por CPF/e-mail: já cadastrado → conflito 409 com mensagem (não vaza dados) — existente, verificado

## 2. Seed de plano Free
- [x] 2.1 `SubscriptionPlanSeeder.SeedAsync()` cria o plano `Free` (slug `free`, price 0) — existente, verificado

## 3. UI — cadastro
- [x] 3.1 `features/onboarding/ui/register-school-form.component` (standalone) — existente
- [x] 3.2 Rota pública `/cadastro` (sem guarda) em `app.routes.ts` — existente
- [x] 3.3 Form: schoolName, segment (opcional), principalName, cpf, email, senha + repetir senha + aceitar termos — existente
- [x] 3.4 POST `/api/onboarding/register-school`; 201 navega (com planId da pricing vai para `/checkout/:planId`, senão `/login?registered=1`); 409 mostra erro de e-mail/cpf já usado — existente (com testes karma)
- [x] 3.5 Pricing "Iniciar" → `/cadastro/:planId` — existente

## 4. Testes
- [x] 4.1 API: `RegisterSchoolControllerTests` (6 testes: criação transacionada, 409 sem transação, 400 segmento, persistência do segmento, rollback em falha, campos vazios) + **E2E real contra Postgres local**: falha no meio (FK) → 0 tenants/0 órfãos (rollback atômico ✅); sucesso → 201 com tenant+unidade+conta+trial+ano letivo+progresso persistidos
- [x] 4.2 E2E `school-self-service-signup.cy.ts` (2026-10-25, cypress 15 contra dev server e2e config, mock-based): 3 testes — signup → 201 → login?registered=1 → autenticado; cadastro vindo da pricing preserva o plano pelo login até /checkout/:plan; 409 exibe erro sem sair da tela. Nota honesta: mocks via cy.intercept; o caminho com backend real está coberto pelos testes de API + E2E curl local

## Ordem de implementação
Seed Free → endpoint API → UI cadastro → CTAs apontando para /cadastro → E2E
