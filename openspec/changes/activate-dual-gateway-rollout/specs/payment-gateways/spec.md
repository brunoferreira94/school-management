<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Provider-aware checkout surface

The UI subscription page SHALL consume the `provider` returned by the checkout intent endpoint and route the user to the provider-specific payment flow (Asaas invoice URL for PIX/boleto/carnê; Stripe hosted checkout redirect for card/USD), without assuming a single provider.

#### Scenario: Guardian chooses PIX

- **GIVEN** a guardian selects the Premium plan and billing type PIX during checkout
- **WHEN** the backend returns an Asaas checkout intent with `provider: "Asaas"` and an `invoiceUrl`
- **THEN** the UI opens the Asaas invoice in the same context and does not treat the payment as completed

#### Scenario: Guardian chooses international card

- **GIVEN** a guardian selects payment by international card
- **WHEN** the backend returns a Stripe checkout intent with `provider: "Stripe"` and a hosted session URL
- **THEN** the UI redirects to the Stripe hosted checkout and returns to the configured success/cancel URLs

### Requirement: Non-production environment disclosure

The system SHALL visibly disclose sandbox/staging mode on payment-covered surfaces when running in a non-production environment, so test charges are never mistaken for real revenue.

#### Scenario: Staging checkout banner

- **GIVEN** the application runs with a non-production environment
- **WHEN** the guardian reaches any checkout or payment surface
- **THEN** a banner identifies the environment as sandbox/staging with the active gateway in test mode
