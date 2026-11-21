## 1. Isolamento de tenant fail-closed

- [x] 1.1 `HasQueryFilter(e => e.TenantId == _tenantId)` para `ClassGroup`, `Classroom`, `ClassSchedule`, `StudentClass` no `AcademicContext.OnModelCreating` (ClassGroup deixou de usar `SchoolUnitId != null`)
- [x] 1.2 `TenantId` escalar em `StudentClass`/`Classroom`/`ClassSchedule` + migration `AddTenantIdToAcademicEntities` (Academic) com backfill do pai e índices `(TenantId, ...)`
- [x] 1.3 Flag `Tenant:FailClosed` (default `false`) usada no `HttpContextTenantProvider`
- [x] 1.4 Fallbacks `DefaultTenantId` em rotas `/api` caindo em `Guid.Empty` quando `FailClosed=true` (middleware já rejeita com 400)
- [x] 1.5 `DefaultTenantId` restrito a seed/migration/design-time via provider; `TenantConstants.DefaultTenantId` mantido só para esses
- [x] 1.6 Teste de integração: isolamento A↔B em `ClassGroup` (`AcademicTenantIsolationIntegrationTests`, 4) + unit `HttpContextTenantProviderTests` (4)
- [x] 1.7 (extra) `TenantAwareModelCacheKeyFactory` cobre `AcademicContext` (bug #4 latente: filtros desligados quando 1º model é sem tenant)

## 2. Checkout sem degradação silenciosa em produção

- [x] 2.1 `GatewayCheckoutRouter` só degrada para `MockPaymentCheckoutService` em `Development`/`Testing`
- [x] 2.2 Production/Staging sem credenciais → `UnavailableGateway` (falha explícita, nunca checkout simulado)
- [x] 2.3 Testes: degrada em dev, falha em prod/staging (`GatewayCheckoutRouterTests`, +4)

## 3. Entitlement enforcement (trial expirado)

- [x] 3.1 `SubscriptionEntitlementEvaluator` (trial vigente/vencido, ativa, past_due/suspended/cancelled/paused)
- [x] 3.2 `EntitlementEnforcementMiddleware`: escrita bloqueada (402 `subscription_expired`) para trial vencido/suspenso; leitura permitida (não prende dados)
- [x] 3.3 Flag `Entitlement:Enforce` (default `false`) + testes unit (9) e integração (3)

## 4. Gates de lançamento e higiene

- [x] 4.1 Step/job `openspec validate --strict` bloqueante no `ci-cd.yml` (e2e/deploy dependem dele)
- [x] 4.2 `docker-compose.prod.yaml` corrigido (env válido via `${ASAAS_API_KEY}`, Postgres só em `127.0.0.1`)
- [x] 4.3 README: aviso de status pré-lançamento, badge MIT removida (sem LICENSE), métrica "TTV 614ms" reescrita como latência de API, OnPush não mais superprometido
- [x] 4.4 Sanitizer unificado (util compartilhado) + `rel="noopener noreferrer"` + rejeição de `//host`/`javascript:`; `portal-dashboard` usa o util
- [x] 4.5 Endurecido `POST /api/auth/impersonate` para `Permission:owner.write` (era só `[Authorize]` — escalonamento de privilégio)

## 5. Validação

- [x] 5.1 `dotnet test` verde (1103/0, 5 skips) após query filters, fail-closed, entitlement
- [x] 5.2 `ng build` verde após unificação de sanitizer
- [x] 5.3 `openspec validate harden-tenant-isolation-and-monetization --strict` passa
- [x] 5.4 Migration `AddTenantIdToAcademicEntities` aplicada e validada contra Postgres 16 real (backfill + índices)
- [ ] 5.5 Promover flags `Tenant:FailClosed` e `Entitlement:Enforce` para `true` em staging/produção após janela de observação (rollout gradual, fora do escopo de código)