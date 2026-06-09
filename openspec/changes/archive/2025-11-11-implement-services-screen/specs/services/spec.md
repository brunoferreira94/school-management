## ADDED Requirements

### Requirement: Services management API

The system SHALL provide an HTTP JSON API to manage Services (CRUD) including endpoints to list services with pagination, create, update, retrieve and delete a service. The API SHALL expose price history for a given service.

#### Scenario: Create and read service

- **GIVEN** an authenticated user with the `MANAGE_SERVICES` permission
- **WHEN** the client POSTs a valid service payload to `POST /api/services`
- **THEN** the API responds with 201 Created and the created resource including its `id`
- **AND** a subsequent `GET /api/services/{id}` returns the created resource with correct fields and an empty price history by default

### Requirement: Price history

The system SHALL maintain a price history for each Service. Each price record SHALL include price, startDate and endDate and SHALL be returned by `GET /api/services/{id}/prices`.

#### Scenario: Price history returned

- **GIVEN** a service with previous price changes
- **WHEN** the client requests `GET /api/services/{id}/prices`
- **THEN** the API returns a 200 response with an ordered list of price records including `price`, `startDate` and `endDate`

### Requirement: Recurrence and billing rules

The system SHALL allow configuration of recurrence rules for billable services (one-time, monthly, yearly) and SHALL expose these rules via the service API. Billing rules SHALL be machine-readable and exportable.

#### Scenario: Recurrence rule persisted

- **GIVEN** a service with recurrence set to `monthly` and a billing rule defined
- **WHEN** the client retrieves the service via `GET /api/services/{id}`
- **THEN** the returned resource contains a `recurrence` field with value `monthly` and a `billingRules` object describing the recurrence

### Requirement: Permissions

The system SHALL protect service management endpoints: LIST/GET endpoints require `VIEW_SERVICES` and create/update/delete require `MANAGE_SERVICES`.

#### Scenario: Permission enforcement

- **GIVEN** an authenticated user without `MANAGE_SERVICES`
- **WHEN** the user attempts to POST `/api/services`
- **THEN** the API returns 403 Forbidden

### Requirement: Exporting rules

The system SHALL provide an export endpoint `GET /api/services/{id}/export` that returns billing rules and pricing information in JSON or CSV when requested.

#### Scenario: Export rules CSV

- **GIVEN** a service with defined billing rules and prices
- **WHEN** the client requests `GET /api/services/{id}/export?format=csv`
- **THEN** the API responds with 200 OK and a CSV body containing billing rules and effective prices
