## ADDED Requirements

### Requirement: Checkout redirect through the payment gateway

The system SHALL create a payment checkout intent (`POST /api/subscriptions/checkout-intents`)
and redirect the customer to the provider's hosted checkout URL, instead of simulating payment
in-application.

#### Scenario: Authenticated user is redirected to the provider checkout

- **GIVEN** an authenticated user on the checkout page with a valid plan selected
- **WHEN** the user submits the payment form
- **THEN** the system posts a checkout intent to `/api/subscriptions/checkout-intents`
- **AND** the response contains a `checkoutUrl`
- **AND** the user is redirected to that `checkoutUrl`

#### Scenario: Anonymous user is not redirected

- **GIVEN** an anonymous visitor on the checkout page
- **WHEN** the user tries to submit the payment form
- **THEN** the system does not create a checkout intent
- **AND** the user stays on the current page (no subscription is created)

### Requirement: Subscription reflects the real payment status after return

After the customer returns from the provider, the system SHALL consult
`GET /api/subscriptions/tenant` and reflect the real subscription status (`Active` / `Trial`),
driven by the provider's webhook, never by an in-app timer.

#### Scenario: Return after successful payment

- **GIVEN** a checkout intent was created with status `PENDING`
- **WHEN** the customer returns from the provider checkout page
- **THEN** the `GET /api/subscriptions/tenant` endpoint returns the subscription
- **AND** the subscription `Status` is `Active` (set by the gateway webhook)
- **AND** the UI navigates to the checkout success page

### Requirement: Local development runs without real gateway credentials

In Development/E2E the gateway SHALL degrade to the mock payment service so the checkout
flow can be exercised end-to-end without Asaas or Stripe keys.

#### Scenario: Missing credentials degrade to mock

- **GIVEN** `Asaas:ApiKey` and `Stripe:SecretKey` are empty
- **WHEN** a checkout intent is created for a Boleto/PIX payment
- **THEN** the `MockPaymentCheckoutService` returns a `checkoutUrl` with provider `MockPayment`
- **AND** the local return route simulates a `COMPLETED` payment

## MODIFIED Requirements

### Requirement: Pricing page CTAs lead to real checkout

- **FROM**: CTAs navigated to `/checkout/:planId` which simulated payment with a timer
- **TO**: CTAs still navigate to `/checkout/:planId`, but the checkout SHALL call
  `POST /api/subscriptions/checkout-intents` and SHALL redirect to the provider's `checkoutUrl`

#### Scenario: Pricing → gateway checkout

- **GIVEN** a visitor on the pricing page
- **WHEN** the visitor clicks a plan CTA
- **THEN** the visitor lands on the checkout page for that plan
- **AND** submitting the form creates a checkout intent and redirects to the provider
