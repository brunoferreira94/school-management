# Activation Security Report - 2026-05-12

## Escopo do dia

1. Validacao de autorizacao cross-tenant com retorno 403.
2. E2E minimo do portal.
3. Bateria critica de testes com consolidado de regressao.

## Evidencia tecnica

### Backend - Cross-tenant (token Tenant A x recurso Tenant B)

- Endpoint critico: `GET /api/subscriptions/tenants/{tenantId}`.
- Estado inicial (RED): teste negativo falhou com `Expected 403, Actual 200`.
- Correcao aplicada: validacao explicita de tenant no controller para endpoints por tenant.
- Estado apos correcao (GREEN): `2/2` testes passando na classe focada.

Comando executado:

- `dotnet build SchoolManagement.Tests/SchoolManagement.Tests.csproj`
- `dotnet test SchoolManagement.Tests/SchoolManagement.Tests.csproj --no-build --filter FullyQualifiedName~SubscriptionsTenantAuthorizationIntegrationTests`

Resultado:

- Total: 2
- Passou: 2
- Falhou: 0

### Frontend E2E - suites executadas hoje

1. Suite `e2e:ci:services`

- Comando: `npm run e2e:ci:services`
- Resultado: `1/1` passando

1. Suite `e2e:ci:portal-registration`

- Comando: `npm run e2e:ci:portal-registration`
- Resultado: `6/6` passando

1. Suite `e2e:ci:portal-minimal-auth-flow`

- Ultima execucao registrada: `1/1` falhando
- Falha registrada: fluxo ficou em `/portal/login` ao inves de `/portal/dashboard`.
- Observacao: houve ajuste de stub Auth0 para e2e apos a falha, mas reexecucao bloqueada por allowlist do executor de testes nesta sessao.

## Consolidado de regressao (unico)

## Totais

- Suites executadas: 3
- Testes totais executados: 9
- Testes passando: 8
- Testes falhando: 1

## Status por suite

- `SubscriptionsTenantAuthorizationIntegrationTests`: PASS
- `services.spec.ts`: PASS
- `portal-registration.spec.ts`: PASS
- `portal-minimal-auth-flow.spec.ts`: FAIL (pendente reexecucao no executor permitido)

## Falhas novas detectadas

- 1 falha nova/aberta: `Portal minimal auth flow > covers callback, dashboard, protected endpoint and logout`.

## Decisao operacional

- Seguranca cross-tenant no backend: FECHADO (verde e com evidencia).
- Gate de ativacao E2E minimo: PARCIAL (suites principais verdes, fluxo minimo novo pendente de reexecucao final no ambiente com comando permitido).
