## MODIFIED Requirements

### Requirement: Subscription lifecycle per tenant

- **FROM**: A tenant gets an `Active` subscription only after the checkout completes; before
  that `GET /api/subscriptions/tenant` returns 404 for newer tenants.
- **TO**: Every created tenant SHALL receive a `Free` subscription with `Status = Trial` and
  `TrialEndsAtUtc` = now + 14 days immediately at provisioning time. `GET /api/subscriptions/tenant` SHALL
  return that trial subscription for tenants with no paid subscription yet.

#### Scenario: Newly created tenant has a Free trial subscription

- **GIVEN** a tenant was just provisioned (default seed or self-service signup)
- **WHEN** `GET /api/subscriptions/tenant` is called authenticated as that tenant
- **THEN** the response returns a subscription with `Plan = Free` and `Status = Trial`
- **AND** `TrialEndsAtUtc` is set to approximately 14 days in the future
