# ASP.NET Core Auth, Claims, Idempotency e EF Core - Referencias Oficiais

Data: 2026-05-15

## Best Practices

1. `ASP.NET Core [Authorize] em controllers`

- Referencia: https://learn.microsoft.com/en-us/aspnet/core/mvc/security/authorization/simple
- Resumo: Mostra como aplicar `[Authorize]` em controller/action e usar `[AllowAnonymous]` em excecoes.

2. `Claims do usuario autenticado`

- Referencia: https://learn.microsoft.com/en-us/aspnet/core/security/authentication/claims
- Resumo: Explica como claims sao carregadas no `ClaimsPrincipal` (`User`) e como mapear/acessar claims.

3. `POST idempotente (guidance oficial Microsoft)`

- Referencia: https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design
- Resumo: Guia de design REST da Microsoft com semantica de metodos HTTP e orientacoes relacionadas a idempotencia.
- Referencia complementar: https://github.com/microsoft/api-guidelines/blob/vNext/azure/ConsiderationsForServiceDesign.md
- Resumo: Guidance Microsoft de repeticao segura/idempotencia para operacoes de API.

4. `EF Core entity configuration`

- Referencia: https://learn.microsoft.com/en-us/ef/core/modeling
- Resumo: Cobre Fluent API, `IEntityTypeConfiguration<T>` e `ApplyConfigurationsFromAssembly` para configuracao de entidades.

5. `EF Core migrations`

- Referencia: https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/
- Resumo: Fluxo oficial para criar, revisar e aplicar migrations no EF Core.

## Example

- `[Authorize]` no controller:

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StudentsController : ControllerBase
{
    [HttpGet]
    public IActionResult Get() => Ok();
}
```

- Claims no endpoint:

```csharp
var userId = User.FindFirst("sub")?.Value;
var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
```

- EF Core entity configuration:

```csharp
public class StudentConfiguration : IEntityTypeConfiguration<Student>
{
    public void Configure(EntityTypeBuilder<Student> builder)
    {
        builder.ToTable("Students");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(200).IsRequired();
    }
}
```

## References

- https://learn.microsoft.com/en-us/aspnet/core/mvc/security/authorization/simple
- https://learn.microsoft.com/en-us/aspnet/core/security/authentication/claims
- https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design
- https://github.com/microsoft/api-guidelines/blob/vNext/azure/ConsiderationsForServiceDesign.md
- https://learn.microsoft.com/en-us/ef/core/modeling
- https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/
