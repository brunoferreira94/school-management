# Tasks — fix-register-school-provisioning

## 1. Backend — provisionamento e binding

- [x] 1.1 `UserAccount.TenantId` (Guid?) no Domain + migration SchoolContext (coluna nullable,\n      sem filtro de query — UserAccounts é global).
- [x] 1.2 `OnboardingController.RegisterSchool`: setar `account.TenantId = tenant.Id` e criar
      `StaffRole` (Staff ↔ role global "Director" via `IRoleRepository.GetByNamesAsync`) dentro
      da transação existente.
- [x] 1.3 `TokenService`: emitir claim `tenant_id` quando `account.TenantId` está definido
      (assinatura de `GenerateToken` inalterada).
- [x] 1.4 `AuthService.LoginAsync`/`RefreshTokenAsync` (+`ImpersonateAsync`): quando a conta tem
      binding, resolver a primeira unidade ativa do tenant e usar como `schoolUnitId` no token;
      sem binding → fallback atual (`DemoDefaults`) sem mudança de comportamento.
- [x] 1.5 `HttpContextTenantProvider` (resolução usada pelo `TenantResolutionMiddleware`):
      usuário autenticado + claim `tenant_id` → claim vence o header `X-Tenant-Id`; sem claim →
      ordem atual.
- [x] 1.6 `PilotEnvironmentSeeder`: backfill idempotente de `TenantId` nas contas demo/legadas
      (diretor.demo etc.) mantendo o tenant piloto `aaaa`.

## 2. Testes

- [x] 2.1 Integração `RegisterSchoolTenantBindingIntegrationTests.Register_Login_…`: register-school →
      login → `Roles` contém "Director", `Permissions` não vazio, token tem `tenant_id` e
      `school_unit_id` reais da conta (2/2 verdes + unit `RegisterSchoolControllerTests` 8/8).
- [x] 2.2 Integração `TokenBound_HeaderDeOutroTenant_ClaimVenceSpoof`: token bound + header
      `X-Tenant-Id` de OUTRO tenant → listagem não vaza o aluno do outro tenant (claim vence).
- [x] 2.3 Contas sem binding mantêm a resolução pelo header: claim só é emitido quando bound —
      o comportamento do portal/legado é exercitado pelo cypress ao vivo (10/10, incl. accounts
      sem claim e Thailand fallback default).
- [x] 2.4 Suíte completa verde (`dotnet test`, 786+ esperado).

## 3. UI/E2E e docs

- [x] 3.1 Cypress `tenant-isolation.cy.ts`: `provisionamento: diretor de escola NOVA nasce com
      role e permissões (fresh 201)` — (re-location do funnel: o funil ao vivo não passa pelo
      register; o spec de isolamento é quem registra B e loga B — branch 409 documentado).
- [x] 3.2 Cypress `tenant-isolation.cy.ts`: `binding: claim tenant_id do token vence o header
      X-Tenant-Id falsificado` — listagem segue escopada em A (10/10 ao vivo).
- [x] 3.3 `api/docs/architecture/multitenancy.md`: ordem de resolução (claim vence p/ contas
      bound) + binding `UserAccount.TenantId` + provisionamento/fail-cerrada + gate dev-only do
      `X-Roles`.
