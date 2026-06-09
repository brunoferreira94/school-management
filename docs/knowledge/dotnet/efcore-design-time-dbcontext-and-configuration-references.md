# EF Core - Design-time DbContext e Configuration (Referencias Oficiais)

Data: 2026-05-14

## Referencias

1. Design-time DbContext Creation (EF Core)
- URL: https://learn.microsoft.com/en-us/ef/core/cli/dbcontext-creation
- Resumo: Explica como as ferramentas EF Core criam o DbContext em design-time, incluindo uso de IDesignTimeDbContextFactory.

2. DbContext Configuration (EF Core)
- URL: https://learn.microsoft.com/en-us/ef/core/dbcontext-configuration
- Resumo: Mostra configuracao do DbContext com DI, AddDbContext e leitura de connection string via IConfiguration/GetConnectionString.

3. Connection Strings (EF Core)
- URL: https://learn.microsoft.com/en-us/ef/core/miscellaneous/connection-strings
- Resumo: Centraliza orientacoes de armazenamento e uso de connection strings em appsettings, variaveis de ambiente e cenarios de scaffold.

4. Configuration in ASP.NET Core
- URL: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/
- Resumo: Documentacao base do sistema IConfiguration com providers, precedencia e binding de configuracoes.

5. .NET Configuration Providers
- URL: https://learn.microsoft.com/en-us/dotnet/core/extensions/configuration-providers
- Resumo: Detalha providers oficiais (JSON, variaveis de ambiente, linha de comando) e como compor a cadeia de configuracao.

6. ASP.NET Core Environments
- URL: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/environments
- Resumo: Define como ambientes (Development/Staging/Production) afetam appsettings.{Environment}.json e comportamento da aplicacao.

7. Safe storage of app secrets in development in ASP.NET Core
- URL: https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets
- Resumo: Recomenda Secret Manager para segredos em desenvolvimento, evitando expor connection strings no codigo e em arquivos versionados.
