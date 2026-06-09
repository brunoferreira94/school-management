# Test Fixes (school-management-api)

---

## EF Core SQL Server → PostgreSQL (Npgsql) Migration

- **Decisão:** Migrar o provider EF Core de SQL Server para PostgreSQL (Npgsql) para padronização do ambiente e compatibilidade futura.
- **Testes adicionados:** `PostgreSqlMigrationRegistrationTests` cobrindo 3 cenários principais de registro/configuração do provider Npgsql.
- **Resultado dos testes:** 3/3 cenários passaram com sucesso.
- **Risco residual:** Algumas migrations legadas ainda referenciam `SqlServerModelBuilderExtensions`, exigindo dependência temporária do pacote `Microsoft.EntityFrameworkCore.SqlServer` até refatoração completa das migrations.
- **Referências oficiais:**
  - [EF Core Database Providers](https://learn.microsoft.com/en-us/ef/core/providers/)
  - [EF Core Migrations Providers](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/providers)
  - [Npgsql Entity Framework Core Provider](https://www.npgsql.org/efcore/index.html)

# Test Fixes (school-management-api)

- CS0118 em `DomainEventsIntegrationTests`: resolver conflito namespace/tipo com alias explícito `using StaffEntity = SchoolManagement.Domain.Staff;`.
- CS8604 em testes (`Assert.Single`): validar não nulo antes (`Assert.NotNull(result.Value)` e `Assert.NotNull(result.Value.Items)`).
- xUnit1012 em Theory: usar parâmetro `string?` quando houver `[InlineData(null)]`.
- 401 nos testes Portal: `TestingAuthenticationHandler` precisa autenticar por headers `X-Test-*` (ex.: `X-Test-UserId`, `X-Test-Roles`, `X-Test-Permissions`) além de Bearer.
- Referências oficiais usadas: CS0118 e `using` alias (Microsoft Docs), nullable warnings (Microsoft Docs).

---

## Fechamento da migracao para PostgreSQL (2026-05-14)

- **Status:** Fechamento concluido do ciclo de migracao EF Core para PostgreSQL no projeto de infraestrutura.
- **Migration gerada:** `src/SchoolManagement.Infrastructure/PostgresMigrations/20260514182103_InitialPostgres.cs` e arquivo designer correspondente em `PostgresMigrations`.
- **Pacote SQL Server removido:** `src/SchoolManagement.Infrastructure/SchoolManagement.Infrastructure.csproj` nao referencia mais `Microsoft.EntityFrameworkCore.SqlServer`; provider ativo permanece `Npgsql.EntityFrameworkCore.PostgreSQL`.
- **Migrations legadas excluidas da compilacao:** `Compile Remove="Migrations\**\*.cs"` e `Compile Remove="Data\Migrations\**\*.cs"` configurados em `SchoolManagement.Infrastructure.csproj`.
- **Script de suporte incluido:** `scripts/generate-postgres-migrations.ps1` para gerar novas migrations no diretorio `PostgresMigrations` com `dotnet ef`.
- **Validacao de testes:** 5 testes unitarios do escopo PostgreSQL validados (3 em `PostgreSqlMigrationRegistrationTests` + 2 em `PostgreSqlMigrationsComplianceTests`), todos passando.

---

## Duplicidade de tipos Search no compile (2026-05-14)

- **Problema:** erros `CS0101`, `CS0111` e `CS8863` no `SchoolManagement.Application` causados por tipos duplicados de Search coexistindo entre pastas `UseCases` e `Commands/Queries`.
- **Causa raiz:** manutencao paralela do mesmo contrato/record/comando em duas organizacoes de pastas durante migracao para padrao CQRS.
- **Correcao aplicada:** remocao de 4 arquivos duplicados em `UseCases`:
  - `ClearSearchHistoryCommand`
  - `RecordSearchHistoryCommand`
  - `TrackSearchAnalyticsCommand`
  - `GetSearchHistoryQuery`
- **Referencias oficiais usadas:**
  - `CS0101`: https://learn.microsoft.com/en-us/dotnet/csharp/misc/cs0101
  - `CS0111`: https://learn.microsoft.com/en-us/dotnet/csharp/misc/cs0111
  - `record` (contexto `CS8863`): https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/record
- **Validacao:** build do `SchoolManagement.csproj` passou; execucao de testes manteve 3 falhas preexistentes de integracao (`AsaasCheckoutService` DI e Sanitizer permissive `img`) sem evidencia de regressao direta desta correcao.

### Prevencao de recorrencia (compile)

- Definir regra de ownership: tipos Search de aplicacao devem existir em apenas um eixo (preferencialmente `Commands/Queries`).
- Em PR de migracao/refatoracao, incluir checklist obrigatorio de duplicidade por nome de tipo (`rg` por `class|record|command|query` antes do merge).
- Ao mover tipos entre pastas, remover os antigos no mesmo PR (evitar janela de coexistencia).
- Executar `dotnet build` do projeto alvo como gate minimo antes de rodar suites longas.
