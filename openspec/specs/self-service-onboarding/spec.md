# self-service-onboarding Specification

## Purpose

Cadastro self-service da escola: uma escola nova entra pelo funil público (landing → pricing → cadastro) e sai com tenant provisionado de ponta a ponta — conta de diretor, unidade, ano letivo padrão e assinatura Free/trial ativa — sem intervenção manual. O cadastro é atômico (nada parcial fica para trás), deduplica por e-mail/CPF, respeita o aceite de termos e integra o checkout de planos pós-login.

## Requirements

### Requirement: Public school registration form

The system SHALL expose a public, unauthenticated registration form at `/cadastro` so a
visitor can create a school account without contacting support.

#### Scenario: Visitor creates a school account

- **GIVEN** an anonymous visitor on `/cadastro`
- **WHEN** the visitor fills school name, principal name, CPF, e-mail, password and accepts
  the terms
- **THEN** the system creates a tenant, a school unit, the principal user and a Free trial
  subscription in a single transaction
- **AND** the response redirects the visitor to the login page with a "conta criada" indicator

#### Scenario: CPF or e-mail already registered

- **GIVEN** a visitor submits a CPF or e-mail already in use
- **WHEN** the registration is processed
- **THEN** the system returns 409
- **AND** the error message does not reveal which of the two identifiers is duplicated

### Requirement: New tenants start on the Free trial

Every tenant created through self-service SHALL receive an active `Free` plan subscription with
`Status = Trial` and a configurable trial duration (default 14 days).

#### Scenario: New school starts on a Free trial

- **GIVEN** a school account was just created
- **WHEN** the principal logs in
- **THEN** `GET /api/subscriptions/tenant` returns status `Trial` and plan `Free`
- **AND** the dashboard shows the upgrade options and the trial expiration

### Requirement: Anonymous visitor can start a school account

The system SHALL allow an unauthenticated visitor to start a school account from the public pricing page (name, school, e-mail, CPF/CNPJ and password) and receive a pending account that can be completed without contacting support, with the self-service flow never sending the visitor to a third-party hosted login.

#### Scenario: Visitor creates a school account from pricing

- **GIVEN** an unauthenticated visitor on the public pricing page
- **WHEN** the visitor submits the school registration form with valid school data
- **THEN** a pending school account is created for the tenant and the visitor is routed to the in-app onboarding, without leaving the product domain

#### Scenario: Visitor without an account cannot complete a purchase

- **GIVEN** an unauthenticated visitor reaches the checkout page
- **WHEN** the visitor tries to confirm the plan
- **THEN** the system asks for the account creation (or login) inside the product instead of failing silently or redirecting to an external identity provider

### Requirement: Trial plan without payment

The system SHALL grant the new tenant a trial/Free plan automatically at account creation, so the school can use the system before any payment, and SHALL show the upgrade path (and its consequences) in-product.

#### Scenario: New school starts on the Free plan

- **GIVEN** a school account was just created
- **WHEN** the tenant signs in for the first time
- **THEN** the tenant has an active Free subscription and the dashboard shows the upgrade options and the limits of the current plan

### Requirement: Onboarding checklist persisted server-side

The system SHALL persist the onboarding checklist progress (welcome seen, standard template applied, first class group, teachers invited, first report card) per tenant on the server, so the checklist survives reloads, devices and browsers.

#### Scenario: Progress persists across devices

- **GIVEN** a school completed the welcome step on one browser
- **WHEN** the same account opens the app on another browser
- **THEN** the checklist reflects the completed steps and the welcome modal is not shown again

### Requirement: Acquisition surfaces are self-consistent

The public acquisition surfaces (landing, pricing, checkout) SHALL present the same plan catalogue, prices and billing options as the API exposes, and every price shown SHALL correspond to an actual purchasable plan.

#### Scenario: Price displayed matches the plan catalogue

- **GIVEN** the pricing page renders the plans
- **WHEN** a plan is displayed with a price
- **THEN** the same plan id, price and billing options are the ones accepted by the purchase endpoint
