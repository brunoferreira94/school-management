# Proposal: fix-register-school-provisioning

## Why

O principal criado pelo **register-school** fica inutilizável: nasce sem `StaffRole`
(nenhuma role) e, portanto, com `permissions: []`/`roles: []` — todo `[Authorize(Policy = "Permission:…")]`
responde 403. Além disso, o claim `school_unit_id` do JWT é **estático** (`DemoDefaults:SchoolUnitId`,
mesmo valor `00000000-…9101` para qualquer usuário) e o JWT não carrega `tenant_id`
— a resolução de tenant da request depende exclusivamente do **header `X-Tenant-Id`
declarado pelo cliente** (ou cai no tenant default). Um token válido consegue declarar
o tenant de outra escola via header; diretores de tenants não-default recebem o claim
demo e filtram fins de listagem pelo unidade errado.

## What Changes

- **Provisionamento de papel**: o principal do register-school recebe a role **global**
  "Director" (mesma do piloto, 32 permissões via `RolePermissions`), via `StaffRole`.
- **Binding conta↔tenant**: `UserAccount` ganha `TenantId` (nullable, migration SchoolContext).
  O register grava o tenant no Principal + o Pessoa física Staff permanece como está (catálogo).
- **JWT**: quando a conta tem binding, o login emite claim **`tenant_id`** real e
  `school_unit_id` = primeira unidade ativa do tenant; contas SEM binding (demo/legado/
  portal) seguem o comportamento atual (fallback `DemoDefaults`) — zero regressão.
- **Resolução de tenant**: com usuário autenticado E claim `tenant_id`, o **claim vence**
  o header `X-Tenant-Id` (header não pode mais declarar outro tenant para contas bound);
  contas sem binding mantêm a ordem atual (header → claim → default).

**BREAKING**: nenhuma (novos claims são aditivos; ordem de resolução muda só quando o
novo claim existe — contas bound ainda não existem fora do register).

## Impact

- Specs: `security` (binding no JWT + anti-spoofing), `self-service-onboarding` (papel do principal).
- Código: `OnboardingController.RegisterSchool` (role + tenantId), `UserAccount` + migration,
  `AuthService.LoginAsync/RefreshTokenAsync` (resolução de claims), `TokenService` (claim
  `tenant_id`), `TenantResolutionMiddleware` (claim vence header), `PilotEnvironmentSeeder`
  (backfill idempotente `TenantId` dos legados demo).
- Testes: integração (register→login→claims/ações do diretor; spoof de header bloqueado),
  Cypress (funil: diretor com permissões; isolamento: claim vence header), `multitenancy.md`.
