# EF Core: Migracao de SQL Server para PostgreSQL (Npgsql)

## Status da migração (2026-05-14)

- Provider EF Core trocado de SQL Server para PostgreSQL (Npgsql) em todos os pontos de registro de DbContext (runtime e design-time).
- Connection strings padrão atualizadas para formato PostgreSQL em todos os appsettings.
- Pacotes NuGet ajustados: Npgsql.EntityFrameworkCore.PostgreSQL ativo, Microsoft.EntityFrameworkCore.SqlServer mantido temporariamente apenas para compatibilidade de migrations legadas.
- Testes automatizados criados para garantir:
  - Provider Npgsql em runtime (Development)
  - Provider Npgsql em design-time (factory)
  - Nenhum provider registrado automaticamente em ambiente Testing
- Todos os testes passaram (3/3).

## Riscos e pendências

- Migrations antigas ainda dependem de SqlServerModelBuilderExtensions; por isso, o pacote SqlServer está presente apenas para build, não para uso em produção.
- Não há validação automatizada de execução real de migrations no PostgreSQL (dotnet ef database update).
- Não há teste automatizado para ambiente Production.
- Connection strings de exemplo ainda usam usuário/senha padrão (trocar em produção e usar variáveis de ambiente/secret manager).

## Próximos passos recomendados

1. Refatorar/regerar todas as migrations para o provider Npgsql, eliminando dependências de extensões SQL Server.
2. Remover o pacote Microsoft.EntityFrameworkCore.SqlServer do projeto assim que as migrations estiverem compatíveis.
3. Validar dotnet ef database update em um banco PostgreSQL limpo.
4. Adicionar testes de integração reais com PostgreSQL (criação de schema, execução de migrations, CRUD básico).
5. Revisar documentação de analytics/views caso haja dependências específicas de SQL Server.
6. Garantir uso de SSL Mode adequado em produção.

## Execução prática (gerar migrations PostgreSQL)

No diretório `school-management-api`, execute:

```powershell
./scripts/generate-postgres-migrations.ps1
```

Ou manualmente:

```powershell
$env:ConnectionStrings__DefaultConnection="Host=localhost;Port=5432;Database=SchoolManagementDb;Username=postgres;Password=postgres"
dotnet ef migrations add InitialPostgres --project src/SchoolManagement.Infrastructure/SchoolManagement.Infrastructure.csproj --startup-project src/SchoolManagement/SchoolManagement.csproj --context SchoolContext --output-dir PostgresMigrations --no-build
```

---

Data: 2026-05-14

## Best Practices

1. Alinhe pacotes e versoes

- Use `Npgsql.EntityFrameworkCore.PostgreSQL` para o provider PostgreSQL no EF Core.
- Mantenha major versions alinhadas entre EF Core runtime, `Microsoft.EntityFrameworkCore.Design` e provider Npgsql.
- Instale/atualize `dotnet-ef` para a mesma familia de versao do EF Core usado no projeto.

2. Troque provider de forma explicita

- Substitua `UseSqlServer(...)` por `UseNpgsql(...)` em `Program.cs` (ou `OnConfiguring`).
- Revise opcoes especificas do SQL Server e remova/adapte para Npgsql.

3. Revise mapeamento de tipos criticos

- `Guid` -> PostgreSQL `uuid` (mapeamento natural para `.NET Guid`).
- `decimal` -> PostgreSQL `numeric` (defina precisao/escala com `HasPrecision(...)` para evitar divergencias).
- `DateTimeOffset`:
  - SQL Server `datetimeoffset` preserva offset.
  - PostgreSQL `timestamp with time zone` (timestamptz) representa instante UTC e nao preserva offset original como no SQL Server.
- `DateTime` em `timestamp without time zone` tende a `Kind=Unspecified`.

4. Migrations sao provider-specific

- Nao reutilize cegamente migrations geradas para SQL Server.
- Gere novas migrations para PostgreSQL ou mantenha conjuntos separados por provider (padrao oficial para multi-provider).
- Em migrations customizadas, use branch por provider (`ActiveProvider`).
- Revise SQL de migration/script antes de aplicar em ambiente produtivo.

5. Conexao PostgreSQL

- Use string de conexao Npgsql com `Host`, `Port`, `Database`, `Username`, `Password`.
- Parametros comuns: `Timeout`, `Command Timeout`, `Keepalive`, `Search Path`, `Application Name`.

6. ASP.NET Core Identity

- Preservar indices/chaves padrao (NormalizedUserName unico, indice em NormalizedEmail, chaves compostas de logins/tokens).
- Preservar tamanhos padrao das colunas de Identity para evitar regressao de indice/performance.
- Se customizar nomes de tabela/colunas, faça via `OnModelCreating` com migration dedicada e validada.

## Example

### Program.cs (UseSqlServer -> UseNpgsql)

```csharp
builder.Services.AddDbContextPool<AppDbContext>(options =>
    options.UseNpgsql(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        npgsql => npgsql.SetPostgresVersion(16, 0)));
```

### Modelagem explicita para pontos sensiveis

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Order>()
        .Property(x => x.Total)
        .HasPrecision(18, 2);

    modelBuilder.Entity<AuditEvent>()
        .Property(x => x.OccurredAtUtc)
        .HasColumnType("timestamp with time zone");
}
```

### Pacotes e migrations

```bash
dotnet tool update --global dotnet-ef
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL

dotnet ef migrations add InitialPostgres
dotnet ef database update
```

### Connection string (Npgsql)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=school_mgmt;Username=app_user;Password=strong_pwd;Timeout=15;Command Timeout=30;Application Name=SchoolManagementApi"
  }
}
```

## Checklist Objetivo

- [ ] Alinhar versoes de EF Core runtime, Design e provider Npgsql.
- [ ] Adicionar `Npgsql.EntityFrameworkCore.PostgreSQL` e validar restore/build.
- [ ] Trocar `UseSqlServer` por `UseNpgsql` e remover opcoes SQL Server-only.
- [ ] Revisar propriedades `decimal` e aplicar `HasPrecision(...)` onde necessario.
- [ ] Revisar `DateTime`/`DateTimeOffset` e decidir estrategia UTC para `timestamptz`.
- [ ] Validar mapeamento de `Guid` para `uuid`.
- [ ] Gerar migrations especificas para PostgreSQL (ou separar por provider).
- [ ] Gerar script SQL e revisar DDL/alteracoes sensiveis antes de producao.
- [ ] Configurar connection string Npgsql por ambiente (Dev/Test/Prod).
- [ ] Validar esquema do Identity (indices/chaves/tamanhos) apos migration.
- [ ] Executar smoke tests de autenticacao/registro e consultas criticas.

## References

1. EF Core Providers (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/providers

2. Install EF Core (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/get-started/overview/install

3. Migrations Overview (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/

4. Migrations with Multiple Providers (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/providers

5. Custom Migration Operations / ActiveProvider (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/operations

6. EF Core Entity Properties (Microsoft Learn)

- https://learn.microsoft.com/en-us/ef/core/modeling/entity-properties

7. Customize ASP.NET Core Identity Model (Microsoft Learn)

- https://learn.microsoft.com/en-us/aspnet/core/security/authentication/customize-identity-model

8. Npgsql EF Core Provider Docs

- https://www.npgsql.org/efcore/

9. Npgsql Connection String Parameters

- https://www.npgsql.org/doc/connection-string-parameters.html

10. Npgsql Basic Type Mappings

- https://www.npgsql.org/doc/types/basic.html

11. Npgsql Date and Time Handling

- https://www.npgsql.org/doc/types/datetime.html

12. Npgsql 6.0 Release Notes (timestamp migration cautions)

- https://www.npgsql.org/doc/release-notes/6.0.html
