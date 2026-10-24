## ADDED Requirements

### Requirement: Trial subscription on tenant provisioning

Every provisioned tenant (default seed and self-service signup) SHALL immediately receive a
`Free` subscription with `Status = Trial` and `TrialEndsAtUtc` = now + 14 days. A tenant with no
paid subscription yet SHALL still get `200` from `GET /api/subscriptions/tenant` with that trial.
Provisioning is idempotent: a tenant that already has an `Active`/`Trial` subscription is not
given another one.

#### Scenario: Newly created tenant has a Free trial subscription

- **GIVEN** a tenant was just provisioned (default seed or self-service signup)
- **WHEN** `GET /api/subscriptions/tenant` is called authenticated as that tenant
- **THEN** the response returns a subscription with `Plan = Free` and `Status = Trial`
- **AND** `TrialEndsAtUtc` is set to approximately 14 days in the future

#### Scenario: Existing subscription is not duplicated

- **GIVEN** a tenant already has an active or trial subscription
- **WHEN** the provisioning path runs again (idempotent retry)
- **THEN** no new subscription is created and the existing one is returned unchanged
