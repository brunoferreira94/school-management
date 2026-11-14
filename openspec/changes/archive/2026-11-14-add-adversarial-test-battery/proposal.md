## Why

The current test suite is overwhelmingly happy-path: only ~36 negative `it()` titles exist across 50 Cypress specs, only 6 xUnit files assert 4xx status codes, and ~19 of 85 API controllers are exercised over HTTP at all. Validation errors, permission denials, not-found IDs, boundary values and concurrency conflicts are largely untested on both front and back — exactly the classes of bugs that reach production (e.g. the `varchar(20)` narrative-status bug found by the live E2E battery, still live in prod).

## What Changes

- Add an adversarial test battery (front + back) that simulates **every kind of action a user could take**, not only the happy path: unauthenticated access, wrong-role access, cross-tenant access, malformed/missing input, boundary values, not-found IDs, idempotency/re-run, and concurrency conflicts.
- **Back**: HTTP-level status-code matrix (401/403/404/400/409) via `TestWebApplicationFactory` for the highest-risk controllers; validator→400 problem-details wiring proof; boundary-value and concurrency tests.
- **Front**: live Cypress specs (real API, `cy.request`) for CRUD write paths and negative UI behavior (guards expelling wrong-role users, form validation errors surfaced, API failures degrading gracefully).
- Extract a shared Cypress helper (login + idempotent psql seed) so live specs stop duplicating setup (currently copy-pasted in 6 specs).
- **Fix bugs found in the same change**: each failure is reproduced → fixed → covered by a regression test → task marked done.
- Keep both suites green: `dotnet test` (API), `ng build` + Karma (UI), and the new Cypress battery against local API `:5067`.

## Impact

- Affected specs: new capability `adversarial-testing` (deltas in `specs/adversarial-testing/spec.md`).
- Affected code:
  - `school-management-api/tests/SchoolManagement.Tests/` — new test files (HTTP matrix, validators, boundaries, concurrency).
  - `school-management-ui/cypress/support/` (new shared helpers) + `cypress/e2e/` — new live specs; existing 6 live specs migrate to the helper opportunistically.
  - Bug fixes discovered by the battery touch arbitrary API/UI files (each fix ships with its regression test).
- Risks: new `supportFile` in Cypress could affect existing specs (mitigated: helpers imported explicitly per-spec, `supportFile: false` stays); xUnit v3 parallelism requires unique data per test instance (existing pitfall).
