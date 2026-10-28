# Spec: Domain Events E2E Validation

**Status**: active  
**Version**: 1.0

---

## Overview

Validar que o padrão `IDomainEventDispatcher` com handlers desacoplados funciona E2E com EF Core, DbContext real e DI container real (não Moq).

---

## Requisitos Funcionais

### RF1: Handler é invocado automaticamente após persistência

**Given** um Student é criado via `StudentCreationService`  
**When** o método `CreateAsync` é chamado  
**THEN** o handler `IncrementStudentCountOnStudentCreated` é invocado automaticamente  
**AND** `subscription.CurrentStudentCount` é incrementado por 1  
**AND** nenhuma chamada explícita a `IncrementStudentCountAsync` é feita no `CreateAsync`

### RF2: Staff count é decrementado na deleção

**Given** um Staff existe e subscription tem `CurrentStaffCount = 5`  
**When** `StaffService.DeleteAsync` é chamado  
**THEN** handler `DecrementStaffCountOnStaffDeleted` é invocado  
**AND** `subscription.CurrentStaffCount` passa para 4  
**AND** count nunca descer abaixo de 0 (se current=0 e delete, fica 0)

### RF3: Document storage é adicionado (ou ignorado se < 1MB)

**Given** um Document é criado com conteúdo de texto puro (~5KB)  
**When** `DocumentService.CreateAsync` é chamado  
**THEN** handler `AddStorageMBOnDocumentCreated` é invocado  
**AND** `DeltaMB = Encoding.UTF8.GetByteCount(content) / 1048576 ≈ 0`  
**AND** handler valida `DeltaMB <= 0` e não incrementa  
**AND** `subscription.CurrentStorageMB` permanece inalterado

### RF4: Handlers são resolvidos via DI

**Given** um `IServiceProvider` com handlers registrados  
**When** `container.GetServices<IDomainEventHandler<StudentCreatedEvent>>()` é chamado  
**THEN** retorna `[IncrementStudentCountOnStudentCreated]`  
**AND** handler é resolvido sem exceção

### RF5: Dispatcher agrega exceções

**Given** múltiplos handlers registrados para um evento  
**AND** um handler lança exceção  
**WHEN** `dispatcher.DispatchAsync` é chamado  
**THEN** todos os handlers são executados (mesmo com falha)  
**AND** `AggregateException` é lançada ao final com todos os erros

---

## Requisitos Não-Funcionais

### RNF1: Performance

- Teste de integração (criar Student, incrementar count) executa em < 100ms
- Dispatcher resolve handlers em < 10ms

### RNF2: Atomicidade

- `IncrementStudentCountAsync` usa `ExecuteUpdateAsync` (não read-modify-write em memória)
- Zero race conditions com múltiplas requisições concorrentes

### RNF3: Backward Compatibility

- `IDomainEventDispatcher?` é injeção opcional em serviços
- Serviços continuam funcionando se dispatcher for null

---

## Test Scenarios

| Scenario                 | Input                                             | Expected                                           | Validation                                                                  |
| ------------------------ | ------------------------------------------------- | -------------------------------------------------- | --------------------------------------------------------------------------- |
| Student Create           | Tenant (Free, max=100, current=0), Student entity | CurrentStudentCount=1                              | `subscription.Refresh(); Assert.Equal(1, subscription.CurrentStudentCount)` |
| Staff Delete             | Tenant (current=5), Staff id                      | CurrentStaffCount=4                                | Math.Max(0, 5-1)=4                                                          |
| Staff Delete (Underflow) | Tenant (current=0), Staff id                      | CurrentStaffCount=0                                | Não descer abaixo de 0                                                      |
| Document Create (Small)  | Tenant (current=0), Document (~5KB)               | CurrentStorageMB=0                                 | DeltaMB < 1 → ignorado                                                      |
| Document Create (Large)  | Tenant (current=0), Document (~50MB)              | CurrentStorageMB=50                                | DeltaMB ≥ 1 → adicionado                                                    |
| Handler Resolution       | DI container                                      | `IncrementStudentCountOnStudentCreated` encontrado | `GetServices<IDomainEventHandler<StudentCreatedEvent>>().Contains(...)`     |
| Dispatcher Exception     | Handler throws                                    | `AggregateException`                               | Todos os handlers executados antes de lançar                                |

---

## Implementação

### DbContext Setup

```csharp
public class DomainEventsIntegrationTests
{
    private DbContextOptions<SchoolContext> GetOptions()
    {
        return new DbContextOptionsBuilder<SchoolContext>()
            .UseInMemoryDatabase(databaseName: $"test_{Guid.NewGuid()}")
            .Options;
    }

    private IServiceProvider BuildServiceProvider(DbContextOptions<SchoolContext> options)
    {
        var services = new ServiceCollection();
        services.AddScoped(_ => new SchoolContext(options));
        services.AddScoped<ITenantSubscriptionRepository, TenantSubscriptionRepository>();
        services.AddScoped<IStudentRepository, StudentRepository>();
        services.AddScoped<IDomainEventDispatcher, DomainEventDispatcher>();
        services.AddScoped<IDomainEventHandler<StudentCreatedEvent>, IncrementStudentCountOnStudentCreated>();
        services.AddScoped<StudentCreationService>();
        return services.BuildServiceProvider();
    }

    private TenantSubscription SeedSubscription(SchoolContext context, int maxStudents = 100)
    {
        var tenant = new Tenant { Id = Guid.NewGuid(), Name = "Test Tenant" };
        var plan = new SubscriptionPlan
        {
            Id = Guid.NewGuid(),
            Name = "Free",
            MaxStudents = maxStudents,
            MaxStaff = 10,
            MaxSchoolUnits = 1,
            MaxStorageMB = 1000
        };
        var subscription = new TenantSubscription
        {
            Id = Guid.NewGuid(),
            TenantId = tenant.Id,
            SubscriptionPlanId = plan.Id,
            CurrentStudentCount = 0,
            CurrentStaffCount = 0,
            CurrentStorageMB = 0
        };
        context.Tenants.Add(tenant);
        context.SubscriptionPlans.Add(plan);
        context.TenantSubscriptions.Add(subscription);
        context.SaveChanges();
        return subscription;
    }
}
```

### Test Case 1: Student Create

```csharp
[Fact]
public async Task StudentCreationService_IncrementStudentCount_Via_DomainEvent()
{
    // Arrange
    var options = GetOptions();
    using var context = new SchoolContext(options);
    var subscription = SeedSubscription(context);

    var serviceProvider = BuildServiceProvider(options);
    var service = serviceProvider.GetRequiredService<StudentCreationService>();

    // Act
    var student = new Student
    {
        Id = Guid.NewGuid(),
        Name = "Test Student",
        TenantId = subscription.TenantId
    };
    await service.CreateAsync(student);

    // Assert
    context.Entry(subscription).Reload();
    Assert.Equal(1, subscription.CurrentStudentCount);
}
```

### Test Case 2: Staff Delete (Underflow)

```csharp
[Fact]
public async Task StaffService_DecrementStaffCount_NeverBelowZero()
{
    // Arrange
    var options = GetOptions();
    using var context = new SchoolContext(options);
    var subscription = SeedSubscription(context);
    subscription.CurrentStaffCount = 0;
    context.SaveChanges();

    var serviceProvider = BuildServiceProvider(options);
    var service = serviceProvider.GetRequiredService<StaffService>();

    var staff = new Staff { Id = Guid.NewGuid(), TenantId = subscription.TenantId };
    context.Staff.Add(staff);
    context.SaveChanges();

    // Act
    await service.DeleteAsync(staff.Id);

    // Assert
    context.Entry(subscription).Reload();
    Assert.Equal(0, subscription.CurrentStaffCount);  // Não negativo
}
```

### Test Case 3: Handler Resolution

```csharp
[Fact]
public void DomainEventHandler_ResolvesFromDI()
{
    // Arrange
    var services = new ServiceCollection();
    services.AddScoped<IDomainEventHandler<StudentCreatedEvent>, IncrementStudentCountOnStudentCreated>();
    var provider = services.BuildServiceProvider();

    // Act
    var handlers = provider.GetServices<IDomainEventHandler<StudentCreatedEvent>>();

    // Assert
    Assert.NotEmpty(handlers);
    Assert.Contains(handlers, h => h is IncrementStudentCountOnStudentCreated);
}
```

---

## Exit Criteria

- ✅ 3 test cases passam (Student create, Staff delete, Document create)
- ✅ 2 edge cases passam (Underflow, Handler resolution)
- ✅ Nenhuma regressão nos 23 testes unitários existentes
- ✅ Tempo de execução total < 5 segundos
- ✅ DbContext disposed corretamente (sem vazamento)
