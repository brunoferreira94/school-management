<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Academic year management

The system SHALL provide CRUD operations for academic years scoped by tenant, including fields for name, slug, start/end dates, status (Draft/Active/Archived), and SHALL prevent overlapping active years per tenant.

#### Scenario: Prevent overlapping active years

- **GIVEN** a tenant has an active academic year covering 2025-01-01 to 2025-12-31
- **WHEN** an administrator attempts to activate a new academic year whose date range overlaps
- **THEN** the system rejects the activation and returns a validation error explaining the overlap

### Requirement: Year linkage for scoped entities

The system SHALL require entities that operate within a school year (courses, classgroups, lesson plans, timetables, assessments, plans, events) to store a non-null `academicYearId` foreign key and SHALL enforce tenant-aligned referential integrity.

#### Scenario: Create course with academic year

- **GIVEN** an administrator provides course details and selects the 2026 academic year
- **WHEN** they submit the create course request
- **THEN** the system persists the course with the provided `academicYearId` and rejects the request if the year does not belong to the tenant

### Requirement: API and UI context selection

The system SHALL expose APIs and UI components that allow selecting the current academic year, propagate the selection via headers or session context, and default list/query endpoints to the active year unless overridden.

#### Scenario: Filter classgroups by selected year

- **GIVEN** a user selects academic year 2026 in the UI context switcher
- **WHEN** they open the classgroup list page
- **THEN** the frontend requests classgroups filtered by `academicYearId=2026` and the API returns only classgroups for that year

### Requirement: Data migration support

The system SHALL provide operational tooling (scripts or jobs) that assign existing records to academic years, including generating a "Historical" year per tenant and producing reports of records requiring manual reclassification.

#### Scenario: Migration report generated

- **GIVEN** the migration tool runs for a tenant with legacy courses lacking `academicYearId`
- **WHEN** it finishes processing
- **THEN** it assigns the courses to the default historical year and outputs a report of any records that need manual year selection
