# Intervenção em RepositoryAndInfrastructureRegistration.cs (2026-05-14)

## Contexto

Após corrigir duplicidade de tipos, restavam 3 testes falhando:

- 2 em SubscriptionsTenantAuthorizationIntegrationTests (DI de AsaasCheckoutService)
- 1 em SanitizerProfileManagementIntegrationTests (options monitor sem img)

## Mudanças aplicadas

1. Substituído AddHttpClient<IPaymentCheckoutService, AsaasCheckoutService>() por AddScoped<IPaymentCheckoutService, AsaasCheckoutService>()
2. Corrigido Configure<SchoolManagement.Options.SanitizerOptions>(...) para Configure<SchoolManagement.Application.Options.SanitizerOptions>(...)

## Resultado

Testes filtrados passaram 3/3.

## Nota de prevenção

- Evitar uso de typed client (AddHttpClient) para serviços sem construtor HttpClient.
- Manter consistência entre tipo de options configurado e tipo consumido por IOptionsMonitor.

## Atualização: SchoolContextFactory (design-time)

- Correção aplicada: prioridade para `ConnectionStrings__DefaultConnection` via env var e fallback para `appsettings.json` + `appsettings.{ENV}.json` em design-time.
- Teste unitário: adicionado teste cobrindo o fluxo de fallback.
- Validação: `PostgreSqlMigrationRegistrationTests` passando; comando `dotnet ef` avançou além do erro de env var e passou a falhar apenas por autenticação no banco.
