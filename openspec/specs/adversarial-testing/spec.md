# adversarial-testing Specification

## Purpose
Garantia contínua de robustez da API contra entradas hostis e uso indevido: matriz de status HTTP (401/403/404 com anti-5xx) em todas as rotas protegidas, isolamento cross-tenant (IDOR) nas superfícies de leitura/escrita, validação de entrada com recusas estruturadas, valores de fronteira e idempotência de re-runs. Inclui a invariante de classificação de autorização (toda action de controller tem `[Authorize]` ou `[AllowAnonymous]`) e o gate de model cache do EF para que os query filters de tenant nunca fiquem silenciosamente inativos.

## Requirements

### Requirement: HTTP status-code matrix for protected routes

The automated test suite SHALL assert, over a representative sample of protected API routes, that unauthenticated requests receive 401, authenticated requests with insufficient permissions receive 403, and non-existent or cross-tenant resource IDs receive 404.

#### Scenario: Unauthenticated access denied

- **GIVEN** a protected endpoint (e.g. `GET /api/students`) without an authorization token
- **WHEN** the request is sent
- **THEN** the response status is 401

#### Scenario: Wrong-role access denied

- **GIVEN** an authenticated user whose role lacks the required permission (e.g. a guardian calling `POST /api/students`)
- **WHEN** the request is sent
- **THEN** the response status is 403 and no data is mutated

#### Scenario: Not-found and cross-tenant IDs denied

- **WHEN** an authenticated caller requests a resource by a non-existent ID, or by an ID belonging to another tenant
- **THEN** the response status is 404 (or 403 where the route convention requires it) and no resource data is leaked

### Requirement: Input validation surfaced as HTTP 400

The automated test suite SHALL prove that endpoints with request validators reject malformed input over HTTP with 400 and problem-details, covering missing required fields, wrong types, invalid enums/GUIDs, and invalid CPF/e-mail formats.

#### Scenario: Invalid DTO rejected by validator

- **GIVEN** an endpoint with a registered request validator (e.g. guardian, classroom, assignment, submission, lesson-plan)
- **WHEN** a request with missing or invalid required fields is sent
- **THEN** the response is 400 with problem-details identifying the offending fields

#### Scenario: Malformed payload rejected

- **WHEN** a request body contains syntactically invalid JSON, wrong value types, invalid enum members, or a non-GUID identifier
- **THEN** the response is 4xx (never 500) with a clear error message

### Requirement: Boundary-value and concurrency coverage

The automated test suite SHALL cover boundary values of paging parameters, business numeric boundaries (assessment weight sums, currency rounding, date ranges) and concurrent/repeated operations, asserting deterministic behavior.

#### Scenario: Paging boundaries handled

- **WHEN** list endpoints are called with `page=0`, `pageSize=0`, negative or very large `pageSize`, or a page beyond the end
- **THEN** the response is well-formed (200 with a valid page, or 400) and never a 500

#### Scenario: Business boundary values enforced

- **WHEN** assessment weights sum to a value other than 100%, or billing amounts hit rounding boundaries, or a date range is inverted
- **THEN** the operation is rejected with a clear 400 or corrected deterministically, per the documented business rule

#### Scenario: Repeated and concurrent operations are safe

- **WHEN** the same operation (e.g. subscription cancel, installment pay) is executed twice or in parallel against the same entity
- **THEN** the state remains consistent and the second call returns a deterministic outcome (success idempotently or a conflict 409), never a corrupt state

### Requirement: Live E2E coverage of UI write paths and denial behavior

Live Cypress specs (real API) SHALL cover CRUD write paths for core entities and the negative UI behavior: form validation errors surfaced to the user, API failures degrading gracefully, and guards expelling users without the required permission.

#### Scenario: CRUD write path with validation errors

- **WHEN** a user creates/updates a core entity (student, grade, installment) with invalid field values through the UI
- **THEN** the form shows the validation error, no partial data is persisted, and the corrected submission succeeds

#### Scenario: User without permission is denied in the UI

- **GIVEN** a logged-in user whose role lacks permission for an admin route (e.g. guardian accessing admin screens)
- **WHEN** they navigate to that route
- **THEN** the guard blocks access (redirect or 403 feedback) and no protected data is rendered

#### Scenario: API failure degrades gracefully in the UI

- **WHEN** a write request fails with 4xx/5xx during a UI flow
- **THEN** the user sees a clear error message and the interface remains usable (no blank screen or infinite spinner)

### Requirement: Shared live-spec test helpers

Live Cypress specs SHALL share login and idempotent database-seed helpers through an explicitly imported support module, instead of duplicating setup code per spec.

#### Scenario: Spec reuses shared helpers

- **WHEN** a new live spec is written
- **THEN** it imports `liveLogin`/seed helpers from the shared module and contains no copy-pasted login or psql setup block

### Requirement: Bugs found by the battery are fixed with regression tests

Every defect discovered by the adversarial battery SHALL be triaged, fixed, and covered by a regression test in the same change before it is marked complete.

#### Scenario: Discovered bug is reproduced then fixed

- **WHEN** a battery test reveals a defect
- **THEN** a failing test reproduces it, the fix makes it pass, and the regression test remains in the suite

#### Scenario: Suites stay green

- **WHEN** the battery is complete
- **THEN** `dotnet test`, the Angular unit suite, and the live Cypress battery all pass with zero failures
