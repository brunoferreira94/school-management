## Context

A camada Application atual usa o padrão Use Case com injeção direta de dependências. Com 80+ Use Cases distribuídos em pastas por domínio, os problemas acumulados são: construtores com até 5+ parâmetros em cada Use Case e 7+ injeções em controllers, código transversal (logging, métricas, tenant resolution) duplicado em cada classe, e assinaturas variadas sem convenção (`Execute()` vs `ExecuteAsync()`, com e sem interface). A migração para CQRS com LiteBus centraliza preocupações transversais em Pipeline Behaviors e impõe convenção uniforme sem alterar os contratos HTTP externos da API.

## Goals / Non-Goals

- **Goals:**
  - Centralizar logging, validação, métricas e tenant resolution em Pipeline Behaviors
  - Eliminar construtores inchados em controllers (injetar apenas `ICommandMediator` e `IQueryMediator`)
  - Separar semanticamente Commands (mutação de estado) de Queries (leitura)
  - Padronizar retorno de todos os handlers: `Result<T>`
  - Suportar migração incremental sem regressão (Use Cases antigos coexistem durante a transição)

- **Non-Goals:**
  - Alterar contratos HTTP da API (endpoints, DTOs de entrada/saída)
  - Adotar CQRS com stores separados (read model vs write model)
  - Migrar para Event Sourcing ou arquitetura Event-Driven neste escopo
  - Substituir o padrão `Result<T>` por exceções ou `ProblemDetails`
  - Implementar mediator próprio

## Decisions

### LiteBus vs Implementação Própria

**Decisão**: Adotar LiteBus.  
**Razão**: Biblioteca OSS com licença MIT, integração nativa com `Microsoft.Extensions.DependencyInjection`, suporte a Command/Query/Event e hooks de pipeline (pre/post/error handlers), além de boa aderência ao estilo atual de Use Cases. O custo de dependência externa é justificado pela maturidade e pela eliminação de infraestrutura de dispatching customizada.  
**Alternativa descartada**: Implementar mediator próprio aumentaria carga de manutenção sem benefício mensurável.

### Padrão de Result

**Decisão**: Manter `Result<T>` atual como tipo de retorno dos handlers de command/query.  
**Razão**: Evitar mudança dupla no mesmo ciclo (CQRS + tratamento de erros). Compatibilidade total com a lógica de mapeamento HTTP dos controllers existentes.  
**Migração futura**: Avaliar adoção de `ErrorOr<T>` ou `OneOf<T, Error>` em change separado após a migração CQRS ser concluída.

### Convenções de Nomenclatura

| Artefato  | Padrão                    | Exemplo                       |
| --------- | ------------------------- | ----------------------------- |
| Command   | `[Verb][Entity]Command`   | `CreateAcademicYearCommand`   |
| Query     | `[Verb][Entity]Query`     | `GetAcademicYearByIdQuery`    |
| Handler   | `[Verb][Entity]Handler`   | `CreateAcademicYearHandler`   |
| Validator | `[Verb][Entity]Validator` | `CreateAcademicYearValidator` |

### Estrutura de Pastas Alvo

```
SchoolManagement.Application/
├── Abstractions/
│   ├── ICommand.cs          # contrato command alinhado ao LiteBus
│   └── IQuery.cs            # contrato query alinhado ao LiteBus
├── Behaviors/
│   ├── LoggingBehavior.cs
│   ├── TenantBehavior.cs
│   ├── ValidationBehavior.cs
│   └── MetricsBehavior.cs
├── AcademicYears/
│   ├── Commands/
│   │   ├── CreateAcademicYear/
│   │   │   ├── CreateAcademicYearCommand.cs
│   │   │   ├── CreateAcademicYearHandler.cs
│   │   │   └── CreateAcademicYearValidator.cs
│   │   └── UpdateAcademicYear/
│   │       ├── UpdateAcademicYearCommand.cs
│   │       ├── UpdateAcademicYearHandler.cs
│   │       └── UpdateAcademicYearValidator.cs
│   └── Queries/
│       └── GetAcademicYearById/
│           ├── GetAcademicYearByIdQuery.cs
│           └── GetAcademicYearByIdHandler.cs
└── [outros domínios com mesma estrutura]
```

### Ordem dos Pipeline Behaviors

```
Request → LoggingBehavior → TenantBehavior → ValidationBehavior → MetricsBehavior → Handler
```

**Justificativa:**

- `LoggingBehavior` primeiro: captura toda a cadeia incluindo erros de validação e tenant
- `TenantBehavior` antes da validação: TenantId deve estar disponível para validators que precisam de contexto de tenant
- `ValidationBehavior` antes do Handler: bloqueia requests inválidas antes de qualquer acesso ao banco
- `MetricsBehavior` mais interno: mede somente o tempo real de execução do Handler (sem overhead de validação)

### Coexistência Durante a Migração

Durante a transição, Use Cases antigos e handlers CQRS coexistem no mesmo assembly:

- Use Cases antigos permanecem registrados no DI e funcionais
- Controllers migrados substituem injeção de Use Cases por `ICommandMediator` e `IQueryMediator`
- Nenhum Use Case é removido até que **todo o domínio** esteja migrado e validado
- A fronteira de migração é sempre o Controller: quando o controller é migrado, o Use Case pode ser deletado

### Impacto em Testes

- Testes unitários existentes de Use Cases **não são alterados** durante a migração do domínio
- Novos testes de handlers CQRS são escritos em paralelo ao lado dos antigos
- Após validação do comportamento idêntico, os testes antigos são removidos junto com os Use Cases

## Risks / Trade-offs

| Risco                                                                               | Mitigação                                                                                         |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Regressão de comportamento durante migração incremental                             | Testes de integração obrigatórios antes de remover cada Use Case                                  |
| `ValidationBehavior` silenciando erros de validação existentes                      | Mapear validações inline dos Use Cases atuais para FluentValidation antes de migrar               |
| `TenantBehavior` quebrando edge cases de resolução de tenant                        | Portar exatamente a lógica de `ResolveTenantId()` atual; cobrir com testes unitários              |
| Complexidade de configuração inicial do LiteBus (commands/queries/events separados) | Criar template interno único de registro DI e usar domínio piloto (AcademicYears) como referência |
| Behaviors ocultando contexto de erro em diagnóstico                                 | `LoggingBehavior` deve logar a request completa e o `Result.Error` quando falha                   |

## Migration Plan

1. **Instalar e configurar** LiteBus sem remover nada existente
2. **Implementar e testar** os 4 Pipeline Behaviors isoladamente
3. **Migrar AcademicYears** como domínio piloto e validar em staging
4. **Documentar o padrão** (`docs/cqrs-migration-guide.md`) para o time antes de prosseguir
5. **Migrar domínios** um por um, com testes de integração a cada etapa
6. **Remover Use Cases antigos** somente após toda a suite de testes passar sem modificação

**Rollback**: Em caso de problema em qualquer domínio, reverter apenas o Controller daquele domínio para injetar o Use Case concreto novamente. Use Cases antigos são preservados até o final da migração.

## Open Questions

- FluentValidation já está instalado em `SchoolManagement.Application.csproj`? Confirmar antes da task 1.1.
- Algum Use Case possui side effects assíncronos que precisariam de eventos (`IEvent`) no LiteBus?
- A separação Read/Write deve influenciar otimizações EF Core (ex.: `AsNoTracking()` em todas as Queries)?
