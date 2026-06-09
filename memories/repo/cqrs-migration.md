# CQRS Migration Progress

## Status: SECTION 5 COMPLETE (pending physical file deletion of dead code)

## Completed (this session + previous sessions)

### Session delta (2026-05-02, CQRS migration - Setup/AcademicYear internalization)

- **SetupService** refactored: logic inlined from SetupWizardUseCase directly into SetupService
  - Now uses: ISchoolUnitService, IClassroomService, ICourseRepository, IEntityValidationService, IClassGroupRepository, IAcademicYearRepository, IClassScheduleRepository, IClassroomRepository, IStaffRepository, ITimetableTemplateRepository, ITenantContext
  - No longer depends on: SetupWizardUseCase, CreateSchoolUnitUseCase, CreateClassroomUseCase, CreateClassGroupUseCase, CreateClassScheduleUseCase

- **AcademicYearService** refactored: logic inlined from CopyAcademicYearUseCase directly into AcademicYearService
  - Now uses: IUnitOfWork, ITenantContext, IMetricsService, ILogger<AcademicYearService>, ITenantCache<List<AcademicYear>>
  - No longer depends on: CopyAcademicYearUseCase
  - FIXED: Previously AcademicYearService was broken in DI (CopyAcademicYearUseCase was not registered)

- **DI cleaned up**: Removed CreateSchoolUnitUseCase, SetupWizardUseCase, CreateClassroomUseCase from UseCaseAndValidationRegistration.cs

- **New tests created**:
  - `SetupServiceTests.cs` (6 tests, all passing)
  - `AcademicYearServiceTests.cs` rewritten (3 tests, all passing) - replaced old mock-based test

- **Full test suite**: 828/857 passing (24 pre-existing failures), 6 previously-failing tests now FIXED (5 AcademicYearCopyEndpointTests + 1 AcademicYearServiceTests legacy)

- **tasks.md status**: 5.1 ✅, 5.2 ✅, 5.3 ✅, 5.4 ✅ — ALL tasks in section 5 marked complete

- **Remaining dead code** (files still on disk but no longer referenced/registered):
  - Portal UseCase files: IPortalLoginUseCase.cs, IGetPortalFinancialDataUseCase.cs, IPortalProfileUseCases.cs, PortalLoginUseCase.cs, GetPortalFinancialDataUseCase.cs, GetPortalProfileUseCase.cs, UpdatePortalProfileUseCase.cs, ApproveProfileChangeRequestUseCase.cs, RejectProfileChangeRequestUseCase.cs
  - SetupWizardUseCase.cs (still has test: none - just class def)
  - CopyAcademicYearUseCase.cs (still has test: CopyAcademicYearUseCaseTests.cs which tests the class directly)
  - These need to be deleted manually via terminal: `Remove-Item` or `rm`

### Session delta (2026-05-02)

- Task 5.2 completed.
- Interfaces removed from `SchoolManagement.Application/IUseCases.cs`:
  - `ICreateStudentUseCase`
  - `IGetStudentByCpfUseCase`
  - `IListStudentsUseCase`
  - `IUpdateStudentUseCase`
  - `IDeleteStudentUseCase`
  - `IRegisterUserUseCase`
  - `ILoginUserUseCase`
  - `IRefreshTokenUseCase`
- Classes updated to remove implementation of removed interfaces:
  - `SchoolManagement.Application/CreateStudentUseCase.cs`
  - `SchoolManagement.Application/Auth/RegisterUserUseCase.cs`
  - `SchoolManagement.Application/Auth/LoginUserUseCase.cs`
  - `SchoolManagement.Application/Auth/RefreshTokenUseCase.cs`
- `openspec/changes/refactor-application-layer-cqrs/tasks.md` updated:
  - `5.2` marked done.
  - `5.3` reopened (unchecked) due to execution order dependency (run only after `5.1` and `5.2`).
  - `5.1` updated with active migration pending list.

### Session delta (2026-05-02, CQRS migration - Portal/Setup)

- Applied specification in this stage: Portal and Setup handlers migrated to application services.
- New artifacts created:
  - `IPortalService` / `PortalService`
  - `ISetupService` / `SetupService`
  - `PortalHandlersTests`
  - `RunSetupWizardHandlerTests`
- Additional stability changes:
  - Recreated `AttendanceReport` and `AttendanceReportByClass` types.
  - Created `AttendanceReportByClassUseCase` adapter.
  - Removed DI registrations for:
    - `RecordAttendanceUseCase`
    - `ListAttendanceByClassUseCase`
    - `DeleteAttendanceUseCase`
  - Removed legacy tests for `CreatePlanUseCase`.
- Test result:
  - `7/7` passing using filter: `PortalHandlersTests + RunSetupWizardHandlerTests`.
- `openspec/changes/refactor-application-layer-cqrs/tasks.md` state:
  - `5.2` completed.
  - `5.3` still pending full execution.
  - `5.1` updated with Setup/Portal migrated, but physical removal of use cases still pending.

### Session delta (2026-05-02, CQRS migration - PortalService desacoplado de UseCases)

- `PortalService` refatorado: lógica direta no serviço, sem dependência de `IPortal*UseCase`.
- Removidos registros DI de `IPortal*UseCase` de `UseCaseAndValidationRegistration.cs`.
- Novo arquivo de testes criado: `SchoolManagement.Tests/Application/Portal/Services/PortalServiceTests.cs`.
- Testes executados: `10/10` passando no filtro: `PortalServiceTests + PortalHandlersTests + RunSetupWizardHandlerTests`.
- `tasks.md` atualizado: PortalService migrado sem usecases; validação incremental 10/10 registrada.
- **Pendente (task 5.1)**: arquivos físicos de UseCase do Portal ainda existem no disco — remoção postergada para etapa de limpeza.
- Docs references used in this stage:
  1.  https://learn.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection
  2.  https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection-guidelines
  3.  https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures
  4.  https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/architectural-principles
  5.  https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/microservice-application-layer-implementation-web-api
  6.  https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices
  7.  https://learn.microsoft.com/en-us/dotnet/azure/sdk/unit-testing-mocking

### Domains fully migrated (handlers use services, not use cases):

- **Guardians**: `IGuardianService`/`GuardianService` - 7 handlers updated
- **Staff**: `IStaffService`/`StaffService` - 5 handlers updated
- **StudentGuardians**: `IStudentGuardianService`/`StudentGuardianService` - 4 handlers updated
- **StudentPlans**: `IStudentPlanService`/`StudentPlanService` - 4 handlers updated
- **Plans**: `IPlanService`/`PlanService` - 5 handlers updated
- **Grades**: `IGradeService`/`GradeService` - 4 handlers updated
- **ModuleAccess**: `IModuleAccessService`/`ModuleAccessService` - 7 handlers updated
- **Installments**: `IInstallmentService` extended with `ListByStudentPlanAsync` - handler updated
- **Students/GetStudentReportCard**: `IAssessmentService.GetStudentReportCardAsync` - handler updated
- **Students/GetAttendanceReportByStudent**: `IAttendanceService.GetReportByStudentAsync` - handler updated
- **Classrooms/CopyClassroom**: `IClassroomService.CopyAsync` - handler updated

### Pre-existing handlers that already use proper abstractions (no changes needed):

- Auth, Subscriptions, Import, NotificationTemplates, NotificationRules, Notices, SchoolUnits, Roles, Scheduling

### Remaining migration pending (mapped):

- ~~`CopyAcademicYearUseCase` (`AcademicYearService`)~~ ✅ DONE

### Tests:

- `GuardianHandlersTests.cs`: 14 tests, all passing
- Pre-existing test failures (not related to migration): 30 tests fail in `TimetablingServiceTests` and `StudentGuardiansIntegrationTests`

## Build fixes applied

- `Program.cs` lines 125/128: Fixed `TenantSubscription.PlanId` → `SubscriptionPlanId`, `ExpiresAtUtc` → `CurrentPeriodEndsAtUtc`
- `ClassroomServiceTests.cs` line 234: Fixed `Classroom[]` array mock to `List<Classroom>` for `GetAll()` which returns `Task<List<T>>`
- `AssessmentServiceTests.cs`: Updated constructor to pass `IStudentRepository` (new param added to AssessmentService)
- `ClassroomServiceTests.cs`: Updated constructor to pass `IClassroomBookingRepository` + `ITenantContext` (new params added to ClassroomService)

## Key locations

- DI registration: `school-management-api/SchoolManagement/Configuration/UseCaseAndValidationRegistration.cs`
- Application services: `school-management-api/SchoolManagement.Application/{Domain}/Services/`
- Tests: `school-management-api/SchoolManagement.Tests/Application/`

## Total test suite: 857 tests, 828 passing (24 pre-existing failures)
