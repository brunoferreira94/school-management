# ADR: Domain Event Dispatcher

**Data:** 2026-05-02  
**Status:** Implementado

---

## Problema

`CurrentStudentCount` em `TenantSubscription` nunca era incrementado/decrementado quando alunos eram criados/deletados — deixando o limite de assinatura inoperante ao longo do tempo.

---

## Decisão

Implementar padrão `IDomainEventDispatcher` centralizado em vez de chamadas explícitas nos use cases.

---

## Arquivos criados/modificados

### Novos — Domain Layer

- `SchoolManagement.Domain/IDomainEvent.cs` — interface marcadora
- `SchoolManagement.Domain/IDomainEventHandler.cs` — `IDomainEventHandler<TEvent>`
- `SchoolManagement.Domain/IDomainEventDispatcher.cs` — interface do dispatcher
- `SchoolManagement.Domain/Events/StudentCreatedEvent.cs` — `record StudentCreatedEvent(Guid TenantId)`
- `SchoolManagement.Domain/Events/StudentDeletedEvent.cs` — `record StudentDeletedEvent(Guid TenantId)`

### Novos — Application Layer

- `SchoolManagement.Application/Students/Events/IncrementStudentCountOnStudentCreated.cs`
- `SchoolManagement.Application/Students/Events/DecrementStudentCountOnStudentDeleted.cs`
- `SchoolManagement.Application/Staff/Events/IncrementStaffCountOnStaffCreated.cs` _(2026-05-02)_
- `SchoolManagement.Application/Staff/Events/DecrementStaffCountOnStaffDeleted.cs` _(2026-05-02)_
- `SchoolManagement.Application/Documents/Events/AddStorageMBOnDocumentCreated.cs` _(2026-05-02)_
- `SchoolManagement.Application/Documents/Events/SubtractStorageMBOnDocumentDeleted.cs` _(2026-05-02)_

### Novos — Infrastructure Layer

- `SchoolManagement.Infrastructure/DomainEventDispatcher.cs` — resolve `IEnumerable<IDomainEventHandler<TEvent>>` via `IServiceProvider`

### Modificados

- `ITenantSubscriptionRepository` — adicionados `IncrementStudentCountAsync(Guid, CancellationToken)` e `DecrementStudentCountAsync(Guid, CancellationToken)`
- `TenantSubscriptionRepository` — implementação com `ExecuteUpdateAsync` (atômico, sem race condition)
- `StudentCreationService` — injeta `IDomainEventDispatcher?`, despacha `StudentCreatedEvent` após `Add`
- `StudentService.DeleteStudentAsync` — injeta `IDomainEventDispatcher?`, despacha `StudentDeletedEvent` após `Delete`
- `RepositoryAndInfrastructureRegistration.cs` — registra dispatcher + handlers

---

## Decisões de design

1. **Operações atômicas**: `ExecuteUpdateAsync` gera `UPDATE ... SET count = count + 1 WHERE ...` — sem race condition read-modify-write
2. **Dispatcher agrega exceções**: todos os handlers são invocados mesmo se um falhar; `AggregateException` é lançada ao final
3. **Null guard**: `ArgumentNullException.ThrowIfNull(domainEvent)` no dispatcher
4. **CancellationToken propagado**: todos os handlers passam token aos repositórios
5. **Parâmetros opcionais no DI**: `IDomainEventDispatcher?` e `ITenantContext?` são injetados como opcionais para manter compatibilidade retroativa

---

## Testes (11 unitários + 5 integração E2E)

- `IncrementStudentCountOnStudentCreatedTests` (3 testes)
- `DecrementStudentCountOnStudentDeletedTests` (3 testes)
- `DomainEventDispatcherTests` (5 testes)
- `DomainEventsIntegrationTests` (5 testes E2E com DbContext InMemory real, sem Moq nos repos) _(2026-05-03)_
  - Cenário 1: `StudentCreationService.CreateAsync` → `CurrentStudentCount` de 0 para 1
  - Cenário 2: `StaffService.DeleteAsync` → `CurrentStaffCount` de 5 para 4
  - Cenário 3: `StaffService.DeleteAsync` com current=0 → permanece 0 (floor)
  - Cenário 4: `DocumentService.CreateAsync` com texto puro → `CurrentStorageMB` = 0 (DeltaMB=0 ignorado)
  - Cenário 5: Resolução de todos os 6 handlers via DI reflexão

---

## Próximos passos

- ~~Aplicar mesmo padrão para Staff (`StaffCreated`/`StaffDeleted` → `CurrentStaffCount`)~~ ✅ Concluído em 2026-05-02
- ~~Aplicar para Documents (`DocumentCreated`/`DocumentDeleted` → `CurrentStorageMB`)~~ ✅ Concluído em 2026-05-02
- **Nota Documents**: `DeltaMB = Encoding.UTF8.GetByteCount(content) / 1048576` — para docs de texto puro o delta é 0 (< 1 MB). Infraestrutura pronta para quando uploads de arquivo forem adicionados ao `Document` entity.
- Todos os 3 contadores de `TenantSubscription` agora têm domain events: `CurrentStudentCount`, `CurrentStaffCount`, `CurrentStorageMB`
