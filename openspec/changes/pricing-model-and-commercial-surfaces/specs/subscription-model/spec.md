# Spec Delta — Capability `subscription-model`

## ADDED Requirements

### Requirement: Plan catalog is the single source of truth for prices and limits

The system SHALL expose plan prices, billing cycles and limits (students, staff, school units,
storage) exclusively from the subscription plan catalog served by the API. No client surface
(public pricing page, internal plans screen, checkout, docs) SHALL hardcode prices or limits.

#### Scenario: Public pricing page renders catalog limits

- **GIVEN** the plan catalog defines `Free` with 50 students and `Premium` with 500
- **WHEN** an anonymous visitor opens `/pricing`
- **THEN** the comparison table shows 50 and 500 (not hardcoded values)
- **AND** the Free plan shows `R$ 0` instead of "sob consulta"/"price on request"

#### Scenario: Internal plans screen reuses the same catalog

- **GIVEN** a tenant opens the internal "Planos Disponíveis" screen
- **WHEN** the plans are listed
- **THEN** names, prices and limits come from the API catalog
- **AND** no second hardcoded price table exists in the UI

#### Scenario: No placeholder strings in production

- **GIVEN** the production bundle of the public pricing page
- **WHEN** its i18n resources are inspected
- **THEN** every `PRICING.*` key resolves to Brazilian Portuguese text
- **AND** no key resolves to an English placeholder such as `Hero Title` or `Cta Start`

### Requirement: School unit creation enforces the plan limit

Creating a school unit SHALL check the tenant's plan limit through
`SubscriptionLimitService.EnsureSchoolUnitLimitAsync` and SHALL fail with a domain limit error
when the limit is reached. Limits equal to `-1` mean unlimited.

#### Scenario: Unit beyond the plan limit is rejected

- **GIVEN** a tenant on the `Free` plan (max 1 school unit) with one unit already created
- **WHEN** a second school unit is created
- **THEN** the request fails with a limit error naming the plan and the limit
- **AND** no unit is persisted

#### Scenario: Unlimited plans are not blocked

- **GIVEN** a tenant on a plan with `MaxSchoolUnits = -1`
- **WHEN** several school units are created
- **THEN** all requests succeed

### Requirement: Feature access is gated by plan

Feature flags declared by the plan (`HasApiAccess`, `HasAdvancedAnalytics`, `HasPrioritySupport`,
`HasCustomBranding`, `HasAdvancedNotifications`, `HasFinancialModule`) SHALL be enforced by the
API and reflected in the UI with an upgrade prompt, instead of being available to every tenant.

#### Scenario: Free tenant is blocked from a paid feature

- **GIVEN** a tenant on the `Free` plan (`HasAdvancedAnalytics = false`)
- **WHEN** the tenant requests an advanced analytics endpoint
- **THEN** the API responds with a plan-limit/entitlement error
- **AND** the UI offers an upgrade path instead of a generic failure

#### Scenario: Paid plan keeps the feature

- **GIVEN** a tenant on `Premium` (`HasAdvancedAnalytics = true`)
- **WHEN** the same endpoint is called
- **THEN** the request succeeds

### Requirement: Expired trial is read-only and offers an upgrade

When a trial ends without conversion, the tenant SHALL keep **read** access to all of its data and
SHALL have every **write** action blocked with `402 Payment Required` and the error code
`subscription_expired`. The UI SHALL respond to that error by opening an upgrade offer (modal)
with the available plans and a checkout CTA, instead of showing a generic failure. Enabling
`Entitlement:Enforce` SHALL be gated on that UI offer being in place.

#### Scenario: Expired trial keeps reading available

- **GIVEN** a tenant whose `Trial` subscription ended more than 14 days ago without payment
- **WHEN** the tenant lists students, grades or reports
- **THEN** every read succeeds and all data remains accessible

#### Scenario: Write is blocked with an upgrade signal

- **GIVEN** an expired-trial tenant and `Entitlement:Enforce = true`
- **WHEN** the tenant attempts to create or update a record
- **THEN** the API responds `402` with `error = subscription_expired` and a `reason`
- **AND** no write is persisted

#### Scenario: UI opens the upgrade offer instead of a generic error

- **GIVEN** the UI receives `402 subscription_expired` from any write request
- **WHEN** the response is handled by the HTTP client
- **THEN** an upgrade modal is shown with the catalog plans and a CTA to `/checkout/:plan`
- **AND** the user stays on the same screen with data preserved