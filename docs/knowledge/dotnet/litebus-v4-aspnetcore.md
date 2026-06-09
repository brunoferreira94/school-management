# LiteBus v4 — API Reference Completa (.NET 9)

> Fonte: Context7 + documentação oficial do repositório litenova/LiteBus  
> Data: 2026-04-22

---

## 1. Pacotes NuGet

```xml
<!-- Microsoft DI (recomendado para .NET 9) -->
<PackageReference Include="LiteBus.Commands.Extensions.Microsoft.DependencyInjection" Version="4.0.0" />
<PackageReference Include="LiteBus.Queries.Extensions.Microsoft.DependencyInjection" Version="4.0.0" />
<PackageReference Include="LiteBus.Events.Extensions.Microsoft.DependencyInjection" Version="4.0.0" />
```

```shell
dotnet add package LiteBus.Commands.Extensions.Microsoft.DependencyInjection
dotnet add package LiteBus.Queries.Extensions.Microsoft.DependencyInjection
dotnet add package LiteBus.Events.Extensions.Microsoft.DependencyInjection
```

> Não existe um pacote único `LiteBus.Extensions.MicrosoftDependencyInjection`. Os pacotes são separados por módulo (Commands, Queries, Events).

---

## 2. DI Registration

```csharp
// Program.cs
builder.Services.AddLiteBus(liteBus =>
{
    var appAssembly = typeof(Program).Assembly;

    liteBus.AddCommandModule(module => module.RegisterFromAssembly(appAssembly));
    liteBus.AddQueryModule(module => module.RegisterFromAssembly(appAssembly));
    liteBus.AddEventModule(module => module.RegisterFromAssembly(appAssembly));
});
```

> `AddCommandModule` / `AddQueryModule` / `AddEventModule` registram automaticamente o `MessageModule`. Novidade v4.0.

---

## 3. Assembly Scanning

```csharp
// Scan do assembly principal
module.RegisterFromAssembly(typeof(Program).Assembly);

// Registrar open generic explicitamente + scan assembly
module.Register(typeof(CommandLoggingPreHandler<>));
module.RegisterFromAssembly(typeof(Program).Assembly);

// Registrar tipo específico
module.Register<CreateProductCommandHandler>();
```

---

## 4. Command Definition

```csharp
// Sem retorno (fire-and-forget)
public sealed class UpdateStockLevelCommand : ICommand
{
    public required Guid ProductId { get; init; }
    public required int NewQuantity { get; init; }
}

// Com retorno — record
public sealed record CreateProductCommand(string Name, decimal Price) : ICommand<Guid>;

// Com retorno — classe
public sealed class CreateProductCommand : ICommand<ProductDto>
{
    public required string Name { get; init; }
    public required decimal Price { get; init; }
}
```

---

## 5. CommandHandler Definition

```csharp
// Interfaces exatas:
// ICommandHandler<TCommand>              → sem retorno
// ICommandHandler<TCommand, TResult>     → com retorno

// Handler sem retorno
public sealed class UpdateStockCommandHandler : ICommandHandler<UpdateStockLevelCommand>
{
    public Task HandleAsync(UpdateStockLevelCommand command, CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }
}

// Handler com retorno
public sealed class CreateProductCommandHandler : ICommandHandler<CreateProductCommand, Guid>
{
    private readonly IProductRepository _repository;

    public CreateProductCommandHandler(IProductRepository repository) => _repository = repository;

    public async Task<Guid> HandleAsync(CreateProductCommand command, CancellationToken cancellationToken = default)
    {
        var product = new Product(command.Name, command.Price);
        await _repository.AddAsync(product, cancellationToken);
        return product.Id;
    }
}
```

---

## 6. Query Definition

```csharp
// Query de resultado único
public sealed record GetProductByIdQuery(Guid Id) : IQuery<ProductDto>;

// Query streaming
public sealed class StreamProductsBySearchQuery : IStreamQuery<ProductDto>
{
    public required string SearchTerm { get; init; }
}
```

---

## 7. QueryHandler Definition

```csharp
// IQueryHandler<TQuery, TResult>
public sealed class GetProductByIdQueryHandler : IQueryHandler<GetProductByIdQuery, ProductDto>
{
    public async Task<ProductDto> HandleAsync(GetProductByIdQuery query, CancellationToken cancellationToken = default)
    {
        return new ProductDto(query.Id, "Nome", 99.99m);
    }
}

// IStreamQueryHandler<TQuery, TResult>
public sealed class StreamProductsBySearchQueryHandler : IStreamQueryHandler<StreamProductsBySearchQuery, ProductDto>
{
    public async IAsyncEnumerable<ProductDto> StreamAsync(
        StreamProductsBySearchQuery query,
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        await foreach (var product in _repository.SearchAsync(query.SearchTerm, cancellationToken))
            yield return new ProductDto { /* ... */ };
    }
}
```

---

## 8. ICommandMediator — Assinaturas Exatas

```csharp
public interface ICommandMediator
{
    Task SendAsync(ICommand command, CommandMediationSettings? settings = null, CancellationToken cancellationToken = default);

    Task<TCommandResult> SendAsync<TCommandResult>(ICommand<TCommandResult> command, CommandMediationSettings? settings = null, CancellationToken cancellationToken = default);
}
```

---

## 9. IQueryMediator — Assinaturas Exatas

```csharp
public interface IQueryMediator
{
    Task<TQueryResult> QueryAsync<TQueryResult>(IQuery<TQueryResult> query, QueryMediationSettings? settings = null, CancellationToken cancellationToken = default);

    IAsyncEnumerable<TQueryResult> StreamAsync<TQueryResult>(IStreamQuery<TQueryResult> query, QueryMediationSettings? settings = null, CancellationToken cancellationToken = default);
}
```

---

## 10. Pipeline Behaviors — Pre/Post Handlers

### Ordem de execução do pipeline:

```
1. Global Pre-Handlers    (open generic: ICommandPreHandler<T> where T : ICommand)
2. Specific Pre-Handlers  (ICommandPreHandler<MinhaCommand>)
3. Validators             (ICommandValidator<MinhaCommand>)
4. Main Handler           (ICommandHandler<TCommand, TResult>)
5. Specific Post-Handlers (ICommandPostHandler<TCommand, TResult>)
6. Global Post-Handlers   (open generic: ICommandPostHandler<T>)
```

### Interfaces de Pipeline — Commands

```csharp
// Pre-handler
public interface ICommandPreHandler<TCommand>
{
    Task PreHandleAsync(TCommand command, CancellationToken cancellationToken = default);
}

// Validator (açúcar sintático para pré-handler de validação)
public interface ICommandValidator<TCommand>
{
    Task ValidateAsync(TCommand command, CancellationToken cancellationToken = default);
}

// Post-handler sem resultado tipado
public interface ICommandPostHandler<TCommand>
{
    Task PostHandleAsync(TCommand message, object? messageResult, CancellationToken cancellationToken = default);
}

// Post-handler com resultado tipado
public interface ICommandPostHandler<TCommand, TResult>
{
    Task PostHandleAsync(TCommand command, TResult? result, CancellationToken cancellationToken = default);
}
```

### Interfaces de Pipeline — Queries

```csharp
// Pre-handler de query
public interface IQueryPreHandler<TQuery>
{
    Task PreHandleAsync(TQuery query, CancellationToken cancellationToken = default);
}

// Post-handler de query
public interface IQueryPostHandler<TQuery, TResult>
{
    Task PostHandleAsync(TQuery query, TResult? result, CancellationToken cancellationToken = default);
}

// Post-handler de stream query
public interface IStreamQueryPostHandler<TQuery, TQueryResult>
    : IQueryPostHandler<TQuery, IAsyncEnumerable<TQueryResult>>
{
}
```

### Open Generic — Aplicado a todos os commands/queries

```csharp
// Logging pre-handler global
public sealed class CommandLoggingPreHandler<TCommand> : ICommandPreHandler<TCommand>
    where TCommand : ICommand
{
    private readonly ILogger<CommandLoggingPreHandler<TCommand>> _logger;

    public CommandLoggingPreHandler(ILogger<CommandLoggingPreHandler<TCommand>> logger) => _logger = logger;

    public Task PreHandleAsync(TCommand message, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Executing command: {CommandType}", typeof(TCommand).Name);
        return Task.CompletedTask;
    }
}

// Metrics post-handler global
public sealed class CommandMetricsPostHandler<TCommand> : ICommandPostHandler<TCommand>
    where TCommand : ICommand
{
    public Task PostHandleAsync(TCommand message, object? messageResult, CancellationToken cancellationToken = default)
    {
        // registrar métrica
        return Task.CompletedTask;
    }
}
```

### Registro com open generics

```csharp
liteBus.AddCommandModule(module =>
{
    module.Register(typeof(CommandLoggingPreHandler<>));    // open generic primeiro
    module.Register(typeof(CommandMetricsPostHandler<>));
    module.RegisterFromAssembly(typeof(Program).Assembly); // handlers concretos via scan
});
```

> A ordem de `Register` vs `RegisterFromAssembly` **não afeta o comportamento**. LiteBus resolve a ordem corretamente.

---

## 11. Exemplo Mínimo Funcional Completo

```csharp
// Command
public sealed record CreateProductCommand(string Name, decimal Price) : ICommand<Guid>;

// Handler
public sealed class CreateProductCommandHandler : ICommandHandler<CreateProductCommand, Guid>
{
    public Task<Guid> HandleAsync(CreateProductCommand command, CancellationToken cancellationToken = default)
    {
        var id = Guid.NewGuid();
        // persistir...
        return Task.FromResult(id);
    }
}

// Validator (pre-handler de validação)
public sealed class CreateProductValidator : ICommandValidator<CreateProductCommand>
{
    public Task ValidateAsync(CreateProductCommand command, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(command.Name))
            throw new ValidationException("Name is required.");
        if (command.Price <= 0)
            throw new ValidationException("Price must be positive.");
        return Task.CompletedTask;
    }
}

// Post-handler (side effect)
public sealed class ProductCreatedNotifier : ICommandPostHandler<CreateProductCommand, Guid>
{
    private readonly IEventPublisher _eventPublisher;
    public ProductCreatedNotifier(IEventPublisher eventPublisher) => _eventPublisher = eventPublisher;

    public Task PostHandleAsync(CreateProductCommand command, Guid productId, CancellationToken cancellationToken = default)
        => _eventPublisher.PublishAsync(new ProductCreatedEvent(productId, command.Name), cancellationToken);
}

// DI Registration — Program.cs
builder.Services.AddLiteBus(liteBus =>
{
    liteBus.AddCommandModule(module => module.RegisterFromAssembly(typeof(Program).Assembly));
    liteBus.AddQueryModule(module => module.RegisterFromAssembly(typeof(Program).Assembly));
    liteBus.AddEventModule(module => module.RegisterFromAssembly(typeof(Program).Assembly));
});

// Controller
[ApiController]
[Route("products")]
public class ProductsController : ControllerBase
{
    private readonly ICommandMediator _commandMediator;
    private readonly IQueryMediator _queryMediator;

    public ProductsController(ICommandMediator commandMediator, IQueryMediator queryMediator)
    {
        _commandMediator = commandMediator;
        _queryMediator = queryMediator;
    }

    [HttpPost]
    public async Task<ActionResult<Guid>> Create(CreateProductCommand command)
    {
        var productId = await _commandMediator.SendAsync(command);
        return CreatedAtAction(nameof(GetById), new { id = productId }, productId);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDto>> GetById(Guid id)
    {
        var product = await _queryMediator.QueryAsync(new GetProductByIdQuery(id));
        return Ok(product);
    }
}
```

---

## Resumo das Interfaces Injetáveis

| Interface          | Método                                             | Uso                         |
| ------------------ | -------------------------------------------------- | --------------------------- |
| `ICommandMediator` | `SendAsync(ICommand, ...)`                         | Comando sem retorno         |
| `ICommandMediator` | `SendAsync<TResult>(ICommand<TResult>, ...)`       | Comando com retorno         |
| `IQueryMediator`   | `QueryAsync<TResult>(IQuery<TResult>, ...)`        | Query resultado único       |
| `IQueryMediator`   | `StreamAsync<TResult>(IStreamQuery<TResult>, ...)` | Query streaming             |
| `IEventPublisher`  | `PublishAsync(IEvent, ...)`                        | Publicar eventos de domínio |

---

## References

- [GitHub: litenova/LiteBus](https://github.com/litenova/LiteBus)
- [Wiki: Getting Started](https://github.com/litenova/LiteBus/wiki/Getting-Started)
- [Wiki: Command Module](https://github.com/litenova/LiteBus/wiki/Command-Module)
- [Wiki: Query Module](https://github.com/litenova/LiteBus/wiki/Query-Module)
- [Wiki: Migration Guide v4](https://github.com/litenova/LiteBus/wiki/Migration-Guide-v4)
- [Wiki: LiteBus Cheat Sheet](https://github.com/litenova/LiteBus/wiki/LiteBus-Cheat-Sheet)
