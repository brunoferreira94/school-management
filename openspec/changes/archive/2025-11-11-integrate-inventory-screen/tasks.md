## Tasks for integrate-inventory-screen

- [x] Backend: add Asset entity, migrations and controller endpoints under `/api/assets` (CRUD + attachments). (owner: backend)

  - Files: `SchoolManagement.Domain/Asset.cs`, `SchoolManagement.Domain/IAssetRepository.cs`, `SchoolManagement.Infrastructure/AssetRepository.cs`, `SchoolManagement.Infrastructure/SchoolContext.cs`, `SchoolManagement.Application/Assets/*`, `SchoolManagement/AssetsController.cs`, `SchoolManagement/Program.cs`

- [x] Backend: add permissions `MANAGE_ASSETS` (implemented as `assets.write`), `VIEW_ASSETS` (implemented as `assets.read`) and secure endpoints. (owner: backend)

  - Notes: permission entries were added to the demo seeder and authorization attributes were applied on `AssetsController` actions.
  - Verification steps:
    - Inspect `SchoolManagement.Infrastructure/Seeding/FrontendDemoDataSeeder.cs` for permission definitions (`assets.read`, `assets.write`).
    - Confirm `SchoolManagement/AssetsController.cs` has `[Authorize(Policy = "Permission:assets.read")]` and `[Authorize(Policy = "Permission:assets.write")]` on the appropriate actions.
    - Add a small integration test in `SchoolManagement.Tests` asserting that requests without the appropriate permission claim return 403.

- [x] Frontend: create `AssetService` in `src/app/services/asset.service.ts` mirroring `DocumentService` patterns. (owner: frontend)
- [x] Frontend: implement `assets.component` (list, filters, pagination). (owner: frontend)
- [x] Frontend: implement `asset-form.component` (create/edit, editor with sanitization, attachments panel). (owner: frontend)
- [x] Frontend: add routes and navigation entry. (owner: frontend)
- [x] Tests: unit tests for service and components (frontend). (owner: frontend)
- [x] Tests: component tests for attachments/progress and keyboard accessibility. (owner: frontend)

- [x] Tests: integration/e2e test scenario for asset create -> upload attachment -> view. (owner: qa)

  - Status: E2E test created at `SchoolManagement.Tests/Integration/AssetsE2ETests.cs` and configured to run using the TestWebApplicationFactory (SQLite in-memory). Integration tests were executed successfully in this environment.

- [x] Deployment: DB migration & release notes (owner: infra/backend)
  - Suggested commands to generate migration locally:

```powershell
dotnet ef migrations add AddAssetsTable --project SchoolManagement.Infrastructure --startup-project SchoolManagement
dotnet ef database update --project SchoolManagement.Infrastructure --startup-project SchoolManagement
```

    - Notes: include generated migration SQL in release notes and verify tenant-scoped query filters are applied in the migration.
    - Migration generated and applied in this session:
      - `SchoolManagement.Infrastructure/SchoolManagement.Infrastructure/Migrations/20251019144733_AddAssetsTable.cs`
      - There is also a migration at `SchoolManagement.Infrastructure/Migrations/20251018_AddAssetsTable.cs` (alternate folder). Please review and keep the correct one according to your project layout.
    - SQL scripts saved under `release_notes/migrations/`:
      - `release_notes/migrations/AddAssetsTable.sql` (extracted CREATE TABLE block)
      - `release_notes/migrations/AddAssetsTable-full.sql` (full generated migration script)

Deployment status: migration files and SQL scripts are present in `release_notes/migrations/`. The migration was applied against the configured database during this session (local run). Please validate in staging/prod following DB migration policies.

Summary of actions completed in this change:

- Backend implementation added for Assets (entity, repository, use-cases, controller).
- EF Core migration created: `20251019144733_AddAssetsTable` and applied locally.
- SQL scripts produced and saved under `release_notes/migrations/`.
- Integration E2E test created and executed successfully using in-memory SQLite.
