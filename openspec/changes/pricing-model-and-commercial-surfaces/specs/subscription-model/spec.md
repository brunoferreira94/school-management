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

### Requirement: Post-trial state is defined and safe

When a trial ends without conversion, the system SHALL resolve the tenant to a documented state
(Free plan, read-only or expired) and SHALL NOT leave the subscription in an undefined condition
that blocks the tenant silently. Enabling `Entitlement:Enforce` SHALL be gated on this rule.

#### Scenario: Trial expiry resolves to the documented state

- **GIVEN** a tenant whose `Trial` subscription ended more than 14 days ago without payment
- **WHEN** entitlement is evaluated
- **THEN** the tenant is in the documented post-trial state
- **AND** the state is the same one exercised by the `Entitlement:Enforce` rollout tests