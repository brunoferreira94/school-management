# Referências oficiais para refatoração CQRS handlers -> application services

## Objetivo

Embasar a refatoração em ASP.NET Core/.NET onde handlers de CQRS (LiteBus) passam a depender de serviços de aplicação, e não de UseCases diretamente.

## Referências (curtas)

1. Dependency injection in ASP.NET Core  
   Link: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection  
   Resumo: Guia oficial para configurar e consumir DI no ASP.NET Core com foco em registro de serviços e resolução por abstração.

2. Dependency injection guidelines (.NET)  
   Link: https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection-guidelines  
   Resumo: Boas práticas e anti-padrões de DI (lifetime, escopo, descarte, acoplamento) para evitar problemas arquiteturais.

3. Common web application architectures  
   Link: https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures  
   Resumo: Define responsabilidades por camada (UI, aplicação, domínio, infraestrutura), apoiando a extração de orquestração para serviços de aplicação.

4. Architectural principles  
   Link: https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/architectural-principles  
   Resumo: Consolida princípios como SRP e separação de interesses para justificar handlers finos e serviços coesos.

5. Microservice application layer implementation (DDD/CQRS)  
   Link: https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-implementation-web-api  
   Resumo: Referência oficial de implementação da camada de aplicação com CQRS, incluindo papel de handlers e serviços.

6. Unit testing best practices  
   Link: https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices  
   Resumo: Orienta testes unitários isolados e estáveis, úteis para validar handlers com dependências mockadas.

7. Unit testing and mocking (Moq/NSubstitute examples)  
   Link: https://learn.microsoft.com/en-us/dotnet/azure/sdk/unit-testing-mocking  
   Resumo: Exemplos oficiais de mocking com Moq e NSubstitute aplicáveis a testes de handlers e serviços de aplicação.
