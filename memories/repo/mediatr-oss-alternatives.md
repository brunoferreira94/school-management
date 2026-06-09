# MediatR OSS alternatives (.NET backend)

- Context: MediatR v13+ moved to a commercial license model; v12 and earlier were Apache-2.0.
- OSS alternatives verified for .NET with MIT license: Cortex.Mediator, Wolverine, LiteBus, DispatchR.Mediator, ModernMediator.
- Concordia is ambiguous for .NET: strong namesake overlap with Python/DeepMind Concordia; related .NET effort appears renamed toward Synaptrix.
- Recommendation for this project (ASP.NET Core, 80+ use cases, incremental migration):
  - LiteBus as the most practical OSS replacement.
  - Wolverine when advanced messaging/workflow capabilities are required.
  - DispatchR.Mediator and ModernMediator for PoC before broad adoption.

## Session decision note (2026-04-22)

- OpenSpec change `refactor-application-layer-cqrs` was updated to use LiteBus instead of MediatR.
- Next implementations in this change must use `ICommandMediator`/`IQueryMediator` and LiteBus DI, not `IMediator`/`AddMediatR`.
- Updated paths (short):
  - `openspec/changes/refactor-application-layer-cqrs/proposal.md`
  - `openspec/changes/refactor-application-layer-cqrs/tasks.md`
  - `openspec/changes/refactor-application-layer-cqrs/design.md`
  - `openspec/changes/refactor-application-layer-cqrs/specs/application-layer/spec.md`

## CQRS LiteBus progress - AcademicYears (2026-04-22)

- Created and compile-validated handlers/requests:
  - Commands: `CreateAcademicYear`, `UpdateAcademicYear`, `DeleteAcademicYear`, `CopyAcademicYear` (command + handler per use case).
  - Queries: `GetAcademicYearById`, `GetAcademicYears`, `GetActiveAcademicYear` (query + handler per use case).
  - Unit tests: 6 files under `SchoolManagement.Tests/Application/AcademicYears/Handlers/`.
- LiteBus v4 technical baseline confirmed:
  - Dispatch: `ICommandMediator`, `IQueryMediator`.
  - Handlers: `ICommandHandler<TCommand, TResult>`, `IQueryHandler<TQuery, TResult>`.
  - DI: `services.AddLiteBus(liteBus => { liteBus.AddCommandModule(...); liteBus.AddQueryModule(...); })`.
  - Assembly scan: `module.RegisterFromAssembly(typeof(SomeHandler).Assembly)`.
- Handler pattern in project:
  - Uses `IUnitOfWork.AcademicYears` (not direct repository injection).
  - Tenant resolution: `context.TenantId == Guid.Empty ? TenantConstants.DefaultTenantId : context.TenantId`.
  - Standard return contracts: `Result<T>` and `Result`.
- Security validation applied in Create/Update handlers:
  - `Name` max 150, `Slug` max 100, slug regex `[a-z0-9-]`.
  - Specific `catch (ArgumentException)` to avoid leaking internal details.
- Integration status:
  - DI registration added in `SchoolManagement/Configuration/UseCaseAndValidationRegistration.cs`.
  - Controller migrated: `SchoolManagement/AcademicYearsController.cs` now uses `ICommandMediator`/`IQueryMediator`.
  - Legacy Use Cases preserved for coexistence.

## References (short)

- MediatR GitHub: https://github.com/jbogard/MediatR
- MediatR NuGet: https://www.nuget.org/packages/MediatR
- Cortex.Mediator NuGet: https://www.nuget.org/packages/Cortex.Mediator
- Wolverine GitHub: https://github.com/JasperFx/wolverine
- Wolverine NuGet: https://www.nuget.org/packages/WolverineFx
- LiteBus NuGet: https://www.nuget.org/packages/LiteBus
- DispatchR.Mediator NuGet: https://www.nuget.org/packages/DispatchR.Mediator
- ModernMediator NuGet: https://www.nuget.org/packages/ModernMediator
- Concordia (Python/DeepMind): https://github.com/google-deepmind/concordia
- Synaptrix NuGet: https://www.nuget.org/packages/Synaptrix
