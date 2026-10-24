# Tasks — Provisionar assinatura trial no tenant

## 1. Plano Free no seed
- [x] 1.1 `SubscriptionPlanSeeder.SeedAsync()` cria o plano `Free` (slug `free`, price 0, `MaxStudents = 50` configurável) — verificado no seed atual (2026-10-24)

## 2. Trial no provisionamento de tenant
- [x] 2.1 `EnsureDefaultTenantAsync()` (Program.cs) cria `TenantSubscription Free/Trial` para o tenant default — **implementado 2026-10-24**: após criar o tenant default, chama `ITrialSubscriptionProvisioner.EnsureTrialAsync`; falha no provisioner é logada e não derruba o boot (`EnsureDefaultTenantTests`)
- [x] 2.2 Cadastro self-service (`OnboardingController.RegisterSchool`) reaproveita a mesma helper `EnsureTrialAsync(tenantId, planSlug: "free")` — **implementado 2026-10-24**: `TrialSubscriptionProvisioner` compartilhado (idempotente, fallback p/ plano default), bloco inline removido do controller

## 3. Exposição
- [x] 3.1 `GET /api/subscriptions/tenant` devolve trial para tenants sem assinatura paga — por construção: `TenantSubscriptionRepository.GetActiveByTenantIdAsync` já inclui `Trial`, e com 2.1/2.2 nenhum tenant nasce sem assinatura → 200 (não 404)

## 4. Testes
- [x] 4.1 API: após seed, tenant default tem assinatura Trial Free — `EnsureDefaultTenantTests` (cria+provisiona; já existente não reprovisiona; falha não derruba boot)
- [x] 4.2 API: após register-school, tenant tem Trial Free — `TrialSubscriptionProvisionerTests` (Trial/14d/free, idempotência, fallback) + `RegisterSchoolControllerTests` (provisioner chamado dentro da transação) + E2E real contra Postgres local: `POST /register-school` → 201 e linha `Trial | free | +14d` no banco ✅
