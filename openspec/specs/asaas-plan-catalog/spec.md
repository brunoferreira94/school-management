# asaas-plan-catalog Specification

## Purpose
Contrato comportamental do Asaas **Sandbox** para o catálogo de planos: como os planos comerciais são materializados como assinaturas recorrentes, o que a API rejeita ou aceita em criação/update, o ciclo de vida de cancelamento, idempotência e filtros de consulta — derivado de testes reais executados em 2026-11-23, para distinguir regressão do app de comportamento esperado do provedor.

## Requirements

### Requirement: Plan catalog materialized as Asaas recurring subscriptions

The commercial plan catalog SHALL be represented in the Asaas Sandbox as one recurring
subscription per plan/cycle, carrying the canonical price published in
`docs/plans/pricing-page.md` and `openspec/changes/monetization-strategy/design.md`
(`Premium` R$ 299,90/month and R$ 2.999,00/year; `Enterprise` R$ 999,90/month and
R$ 9.999,00/year), a `PIX` billing type and an `externalReference` matching the plan slug.
The `Free` plan SHALL NOT be materialized, because the API rejects any subscription value
not greater than R$ 0,00.

#### Scenario: Catalog holds exactly the four paid plan subscriptions

- **GIVEN** the catalog customer `cus_000010087639` (`externalReference=plans_catalog`)
- **WHEN** `GET /v3/subscriptions?customer=cus_000010087639` is called
- **THEN** it returns exactly 4 subscriptions, all `ACTIVE`
- **AND** their `externalReference` values are `plan_premium_monthly`, `plan_premium_yearly`, `plan_enterprise_monthly` and `plan_enterprise_yearly`

#### Scenario: Free plan cannot exist as a subscription

- **GIVEN** an attempt to create a subscription with `value` equal to `0` or negative
- **WHEN** `POST /v3/subscriptions` is called
- **THEN** the API responds `invalid_value` and no object is created

#### Scenario: Prices match the documented table

- **GIVEN** each catalog subscription is fetched by id
- **WHEN** the response is compared with the canonical pricing table
- **THEN** values are 299.9, 2999, 999.9 and 9999 with cycles `MONTHLY`, `YEARLY`, `MONTHLY` and `YEARLY` respectively

### Requirement: Subscription creation is validated by the gateway

The gateway SHALL reject subscription creation that omits or invalidates any required field
(`customer`, `billingType`, `value`, `cycle`, `nextDueDate`) with a specific error code,
and SHALL NOT create partial objects.

#### Scenario: Missing or unknown customer is rejected

- **GIVEN** a `POST /v3/subscriptions` payload without `customer` or with an unknown customer id
- **WHEN** the request reaches the API
- **THEN** it fails with HTTP 400 and error code `invalid_customer`

#### Scenario: Malformed due date is rejected

- **GIVEN** a payload with `nextDueDate` that is not a valid date
- **WHEN** the request reaches the API
- **THEN** it fails with HTTP 400 and error code `parse_error`

#### Scenario: Invalid enums are rejected

- **GIVEN** a payload with an unknown `cycle` or `billingType`
- **WHEN** the request reaches the API
- **THEN** it fails with HTTP 400 with codes `invalid_cycle` and `invalid_billingType` respectively

### Requirement: Creating a subscription generates the first pending charge

Creating a subscription SHALL immediately generate its first charge as `PENDING`, due on the
requested date, linked to the subscription id; the subscription's `nextDueDate` in the
response SHALL be normalized by the gateway to the following cycle of the requested date.

#### Scenario: First charge is generated and linked

- **GIVEN** a valid `POST /v3/subscriptions` with `nextDueDate=2026-12-01`
- **WHEN** the subscription is created
- **THEN** a `PENDING` charge exists with `dueDate=2026-12-01`, the subscription's value and `subscription` pointing to the new id
- **AND** the subscription response reports `nextDueDate` one cycle later (2027-01-01 for `MONTHLY`, 2027-12-01 for `YEARLY`)

### Requirement: Subscription updates do not mutate already-generated charges

`PUT /v3/subscriptions/{id}` SHALL update the subscription fields (including `value`,
`description`, `billingType` and `cycle`) but SHALL NOT rewrite charges that were already
generated, which keep the value and billing type they were created with. Invalid update
values (such as `value` equal to `0` or an unknown `billingType`) SHALL be silently
ignored — the gateway responds without an error and the state stays unchanged — unlike
creation, which rejects the same values with HTTP 400.

#### Scenario: Value change does not propagate to the pending charge

- **GIVEN** an active subscription with a `PENDING` charge of value 10
- **WHEN** `PUT` changes the subscription `value` to 12.34
- **THEN** the subscription reports 12.34
- **AND** the existing pending charge still reports 10

#### Scenario: Cycle is mutable

- **GIVEN** an active `MONTHLY` subscription
- **WHEN** `PUT` sends `cycle=YEARLY`
- **THEN** the subscription reports `YEARLY`

#### Scenario: No-op update preserves state

- **GIVEN** a catalog subscription
- **WHEN** `PUT` is called with a payload identical to the current state
- **THEN** value, cycle, billing type and description remain unchanged

#### Scenario: Invalid update values are silently ignored

- **GIVEN** an active catalog subscription with `value` 299.9 and `billingType` `PIX`
- **WHEN** `PUT` sends `value=0` and, separately, an unknown `billingType`
- **THEN** both requests succeed without error codes
- **AND** the subscription still reports `value` 299.9 and `billingType` `PIX`

### Requirement: Cancelling a subscription deactivates it and removes its pending charges

`DELETE /v3/subscriptions/{id}` SHALL move the subscription to status `INACTIVE` (not
`CANCELED`) and SHALL remove the pending charges generated by it from listing results,
leaving no residue in the account.

#### Scenario: Delete results in INACTIVE

- **WHEN** `DELETE /v3/subscriptions/{id}` is called on an active subscription
- **THEN** a subsequent `GET` reports status `INACTIVE`

#### Scenario: No residue after cancellation

- **GIVEN** a disposable subscription with generated pending charges
- **WHEN** the subscription is deleted
- **THEN** listing payments returns no charges with that subscription's description
- **AND** the account charge count returns to the pre-test value

#### Scenario: Cancel is idempotent

- **WHEN** `DELETE /v3/subscriptions/{id}` is called on an already `INACTIVE` subscription
- **THEN** the request succeeds with HTTP 200 and the status remains `INACTIVE`

### Requirement: externalReference is not idempotent

The gateway SHALL NOT enforce uniqueness on `externalReference`: posting a subscription with
a reference that already exists creates a duplicate. Callers SHALL enforce catalog
uniqueness themselves.

#### Scenario: Duplicate reference creates a second subscription

- **GIVEN** a subscription exists with `externalReference=fixture_teste_spec`
- **WHEN** `POST /v3/subscriptions` repeats the same `externalReference`
- **THEN** a second subscription with a different id is created

### Requirement: Query capabilities differ between subscriptions and payments

`GET /v3/subscriptions` SHALL honor the `customer`, `description`, `externalReference`,
`status`, `limit` and `offset` filters; `GET /v3/payments` SHALL be treated as if it ignores
`description` and `dateCreated` filters, so callers SHALL filter payment results client-side.

#### Scenario: Subscription filters work

- **WHEN** `GET /v3/subscriptions?externalReference=plan_premium_monthly` or `?status=ACTIVE` is called
- **THEN** only matching subscriptions are returned

#### Scenario: Payment filters are ignored

- **WHEN** `GET /v3/payments?description=Fixture&dateCreated=2026-11-23` is called
- **THEN** the response contains unrelated rows and the caller must filter locally

### Requirement: Catalog tests run only against the Sandbox environment

All catalog contract tests SHALL target `https://api-sandbox.asaas.com/v3` using the
sandbox key, SHALL keep credentials out of code, logs and conversation, and SHALL restore
the sandbox to the clean four-subscription state when finished.

#### Scenario: Clean final state

- **GIVEN** the test battery has finished
- **WHEN** the customer and payment listings are read again
- **THEN** exactly 4 active catalog subscriptions exist and today's charges are only the 4 plan charges (299.9, 999.9, 2999, 9999, all `PENDING`)
