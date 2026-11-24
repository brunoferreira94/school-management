## ADDED Requirements

### Requirement: Checkout intent links the payment to the tenant subscription

`POST /api/subscriptions/checkout-intents` SHALL require an authenticated tenant and SHALL persist
the generated provider reference as the tenant subscription's external identifier **before** calling
the payment gateway, so the provider webhook can always find the local subscription.

#### Scenario: Authenticated intent persists the reference before the gateway call

- **GIVEN** an authenticated tenant with an `Active` or `Trial` subscription
- **WHEN** the user submits the checkout form
- **THEN** the system persists the generated reference (e.g. `premium-monthly-20261124131130`) as
  `externalSubscriptionId` on that subscription
- **AND** `GET /api/subscriptions/tenant` returns that `externalSubscriptionId` before any payment
  is confirmed
- **AND** the reference is also sent to the payment provider as `externalReference`
  (Asaas) / `client_reference_id` (Stripe)

#### Scenario: Tenant without an active subscription gets a trial before linking

- **GIVEN** an authenticated tenant whose only subscription is `Cancelled`
- **WHEN** the user submits the checkout form
- **THEN** the system provisions an idempotent `Trial` subscription on the Free plan
- **AND** persists the generated reference on that new subscription
- **AND** the plan is NOT upgraded before the payment is confirmed

#### Scenario: Anonymous checkout intent is rejected

- **GIVEN** a request to `POST /api/subscriptions/checkout-intents` without a tenant identity
- **WHEN** the request is handled
- **THEN** the system responds `401 Unauthorized` (or `403 Forbidden` when lacking the
  `subscriptions.write` permission)
- **AND** no checkout intent, subscription, or client-supplied reference is created

### Requirement: Confirmed payment activates the purchased plan

When the provider webhook reports a payment whose status maps to `Active`, the system SHALL apply
the purchased subscription plan and billing cycle derived from the linked reference's plan slug and
cycle; when the reference cannot be resolved into a known plan, the system SHALL keep the current
plan and still apply the status without failing the webhook.

#### Scenario: Confirmed webhook activates the purchased plan

- **GIVEN** a trial subscription on the Free plan linked to reference `premium-monthly-<timestamp>`
- **WHEN** the Asaas webhook reports the payment status `CONFIRMED` (or `RECEIVED`)
- **THEN** the subscription `Status` is `Active`
- **AND** `SubscriptionPlanId` points to the Premium plan
- **AND** `BillingCycle` is `Monthly`
- **AND** `GET /api/subscriptions/tenant` reflects plan `Premium` with status `Active`

#### Scenario: Unparseable reference keeps the current plan

- **GIVEN** a subscription linked to a reference with no recognizable plan slug (e.g. legacy or
  manual value)
- **WHEN** the webhook confirms the payment
- **THEN** the subscription `Status` is `Active`
- **AND** the current `SubscriptionPlanId` and `BillingCycle` are preserved
- **AND** the webhook response remains `processed: true`

#### Scenario: Pending payment does not grant the plan

- **GIVEN** a subscription linked to reference `premium-monthly-<timestamp>`
- **WHEN** the webhook reports the payment status `PENDING`
- **THEN** the subscription `Status` is `Trial`
- **AND** `SubscriptionPlanId` and `BillingCycle` are unchanged

#### Scenario: Repeated event stays idempotent

- **GIVEN** an event id already recorded on the subscription
- **WHEN** the same webhook event is delivered again
- **THEN** the system responds `processed: true` with "Evento já processado anteriormente"
- **AND** the plan and status are not modified again
