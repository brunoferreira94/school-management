## ADDED Requirements

### Requirement: Anonymous visitors see a public landing page at the root

The system SHALL render a public landing/marketing page at `/` for unauthenticated visitors,
without redirecting them to the login page.

#### Scenario: Anonymous visitor lands on the marketing page

- **GIVEN** an anonymous visitor opens `/`
- **WHEN** the visitor is not authenticated
- **THEN** the landing page is rendered with the headline, the 2026 differentiators and CTAs
- **AND** the visitor is NOT redirected to `/login`

#### Scenario: CTA starts self-service registration

- **GIVEN** the landing page is shown
- **WHEN** the visitor clicks the primary CTA ("Iniciar")
- **THEN** the visitor is taken to `/cadastro` (school registration)

### Requirement: Pricing CTA is conditional on session

- **GIVEN** a visitor on `/pricing`
- **WHEN** the visitor is anonymous
- **THEN** the primary CTA SHALL navigate to `/cadastro`
- **WHEN** the visitor is authenticated
- **THEN** the primary CTA SHALL navigate to `/checkout/:plan`

#### Scenario: Anonymous pricing CTA starts registration

- **GIVEN** an anonymous visitor on `/pricing`
- **WHEN** the visitor clicks the primary CTA
- **THEN** the visitor is taken to `/cadastro`
