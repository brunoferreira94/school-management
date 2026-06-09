## Why

A camada Application acumula 80+ Use Cases com assinaturas inconsistentes (`Execute()` vs `ExecuteAsync()`, com e sem interfaces), construtores com até 5+ dependências injetadas diretamente em cada classe, e código transversal (logging, métricas, resolução de tenant) duplicado individualmente em cada Use Case. Controllers injetam Use Cases concretos individualmente, gerando construtores inchados (ex.: `StudentsController` com 7 Use Cases). Não há separação semântica entre operações de leitura e escrita, dificultando manutenção, testabilidade e onboarding.

## What Changes

- Adoção do **LiteBus** como dispatcher de Commands e Queries na camada Application
- Introdução de **Pipeline Behaviors** centralizando logging, validação FluentValidation, métricas e tenant resolution
- Padronização de estrutura de pastas por domínio com subpastas `Commands/<Verb><Entity>/` e `Queries/<Verb><Entity>/`
- Migração **incremental por domínio** (piloto: `AcademicYears`); Use Cases antigos coexistem durante a transição
- Controllers refatorados para injetar `ICommandMediator` e `IQueryMediator`, eliminando construtores inchados
- Todos os handlers retornam `Result<T>`, mantendo compatibilidade com o padrão atual
- Registro automático de handlers via extensões de DI do LiteBus em `Program.cs` (`AddLiteBus`)
- **BREAKING (interno)**: DI muda de Use Cases concretos para `ICommandMediator`/`IQueryMediator` + handlers — sem impacto nos contratos HTTP externos

## Impact

- Affected specs: `application-layer`
- Affected code:
  - `SchoolManagement.Application/` — estrutura interna de todos os domínios
  - `SchoolManagement.Api/Controllers/` — todos os controllers (substituição da injeção)
  - `SchoolManagement.Api/Program.cs` — registro do LiteBus e pipeline behaviors
  - `SchoolManagement.Tests/Application/` — testes unitários migrados para handlers
