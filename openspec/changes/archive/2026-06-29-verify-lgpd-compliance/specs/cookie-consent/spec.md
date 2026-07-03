# Cookie Consent Specification

## ADDED Requirements

### Requirement: Implement Cookie Consent Banner
O sistema SHALL exibir um banner de consentimento de cookies para os usuários, permitindo que eles escolham aceitar ou rejeitar cookies antes de qualquer ativação.

#### Scenario: Display Banner on First Visit
- **Given** a user visits the application for the first time,
- **When** the page loads,
- **Then** a cookie consent banner should be displayed at the bottom of the screen.

#### Scenario: Store User Consent
- **Given** a user interacts with the cookie consent banner,
- **When** the user accepts or rejects cookies,
- **Then** the choice should be stored in the backend.

#### Scenario: Enforce Consent Before Activation
- **Given** a user has not accepted cookies,
- **When** the user navigates the application,
- **Then** no cookies should be activated until consent is given.