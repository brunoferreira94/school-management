# Tasks — Provisionar assinatura trial no tenant

## 1. Plano Free no seed
- [ ] 1.1 Garantir `SubscriptionPlanSeeder.SeedAsync()` cria o plano `Free` (slug `free`, price 0,
      `MaxStudents` configurável) — verificar no seed atual

## 2. Trial no provisionamento de tenant
- [ ] 2.1 `EnsureDefaultTenantAsync()` (Program.cs) cria `TenantSubscription Free/Trial` para o
      tenant default
- [ ] 2.2 `TenantProvisioningService.RegisterSchoolAsync()` (do change self-service) reaproveita
      a mesma helper `CreateTrialSubscriptionAsync(tenantId, planSlug="free")`

## 3. Exposição
- [ ] 3.1 `GET /api/subscriptions/tenant` já devolve trial/free para tenants sem assinatura ativa —
      validar e garantir 200 (não 404) quando só existe trial

## 4. Testes
- [ ] 4.1 API: após seed, tenant default tem assinatura Trial Free
- [ ] 4.2 API: após register-school, tenant tem Trial Free
