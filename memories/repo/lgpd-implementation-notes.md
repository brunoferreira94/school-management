# LGPD Compliance Implementation Notes

- **Key Files:**
  - Backend: school-management-api/src/Domain/Lgpd/, school-management-api/src/Application/Lgpd/, school-management-api/src/Infrastructure/Lgpd/, school-management-api/openapi.json, school-management-api/all_migrations_initialcreate.sql
  - Frontend: school-management-ui/src/app/lgpd/, consent banner, storage/history gating logic
- **Security:**
  - All LGPD endpoints require [Authorize] (no X-User header except in Testing)
- **Consent State:**
  - If consent is unset, optional data storage/history is disabled by default (frontend enforces gating)
- **Frontend:**
  - Gating for optional features (storage/history) based on consent state
- **Testing:**
  - All new/updated endpoints and gating logic covered by tests; all tests passing
- **Pending:**
  - EF migration command must be run to apply DB changes
