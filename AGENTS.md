---
title: "Mock do Auth0 para Ambiente de Desenvolvimento"
description: "Estratégia para contornar a limitação do Auth0 (apenas um ambiente) usando mock local"
schema: openspec
version: 1.0
status: draft
author: Bruno Ferreira
tags:
  - auth0
  - mock
  - desenvolvimento
  - authentication
---

## 🌟 Motivação
O Auth0 só permite Criar **um ambiente principal**, que será definido como **produção**. Como precisamos testar em desenvolvimento sem impactar a produção, precisamos de uma solução de mock que simule as respostas do Auth0 localmente.

## 📝 Proposta
Criar uma solução de mock local substituindo as chamadas à API do Auth0 real durante o desenvolvimento.

## 📋 Especificações do Mock
### 1. Configuração no .NET
- Alternância automática:  
  - Em desenvolvimento: Usar mock  
  - Em produção: Usar endpoints reais do Auth0

- **Atualização no `appsettings.Development.json`**:  
  ```json
  "Auth0": {
    "Domain": "mock-auth0.local",
    "Audience": "http://localhost:5066/api",
    "ManagementClientId": "mock-client-id",
    "ManagementClientSecret": "mock-secret"
  }
  ```

### 2. Implementação do Mock Service
**Interface (`IAuth0Service.cs`):** 
```csharp
public interface IAuth0Service
{
    Task<string> GetAccessTokenAsync(string clientId, string clientSecret, string audience, string domain);
    Task<Dictionary<string, object>> GetUserInfoAsync(string accessToken);
    bool IsMockEnabled { get; }
}
```

**Mock Service (`MockAuth0Service.cs`):** Retorna token mockado e dados de usuário fictícios.

### 3. Estratégia de Alternância
```csharp
// Program.cs
var authMode = Environment.GetEnvironmentVariable("AUTH_MODE");

if (authMode == "***")
{
    builder.Services.AddSingleton<IAuth0Service, MockAuth0Service>();
}
else
{
    builder.Services.AddHttpClient<IAuth0Service, ProductionAuth0Service>();
}
```

## ✅ Verificação  
- [ ] O mock retorna tokens válidos para chamadas frequentes do Auth0  
- [ ] Frontend conecta-se ao mock sem falhas  
- [ ] Backend não exibe erros relacionados ao Auth0 em desenvolvimento  

## 📚 Referências
- [Auth0 SDK for .NET](https://github.com/auth0/auth0-aspnetcore)  
- [.NET Dependency Injection](https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection)  
- [JSON Server](https://github.com/typicode/json-server)

## 📁 Arquivos Criados
| Arquivo | Descrição |
|---------|-----------|
| `/home/bruno/workspace/school-management/school-management-api/src/SchoolManagement.Infrastructure/Auth0/IAuth0Service.cs` | Interface comum + `Auth0AuthModeResolver` (decadência por `AUTH_MODE`) |
| `/home/bruno/workspace/school-management/school-management-api/src/SchoolManagement.Infrastructure/Auth0/MockAuth0Service.cs` | Implementação do mock (tokens `mock|management-token-*`) |
| `/home/bruno/workspace/school-management/school-management-api/src/SchoolManagement.Infrastructure/Auth0/ProductionAuth0Service.cs` | Implementação produção (client_credentials + /userinfo) |

## 🚀 Status da implementação
1. ~~**Registrar no DI container**~~ ✅ `RepositoryAndInfrastructureRegistration` — `AUTH_MODE=mock` força o mock mesmo com credenciais; sem `AUTH_MODE` haverá decadência automática pelo mock em desenvolvimento sem credenciais e Auth0 real em produção.
2. **Atualizar `appsettings.Development.json`**: desnecessário — o mock não depende de credenciais; não colocar valores falsos no config para evitar ativar o serviço real.
3. **Testar autenticação local** com mock ativado ✅ 9 testes (Auth0MockTests/ProductionAuth0ServiceTests).
4. **Documentar uso no README principal**: `AUTH_MODE` documentado no próprio AGENTS.md e nos testes.