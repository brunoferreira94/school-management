<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: One-click data export at cancellation

The system SHALL offer a complete data export (students, classes, records, invoices, documents) in open formats (CSV/JSON) during the self-service cancellation flow, available before final deactivation, without requiring support contact.

#### Scenario: Export offered in cancel flow

- **GIVEN** the school admin reached the confirmation panel of the cancellation flow
- **WHEN** the panel is displayed
- **THEN** an export action generates the full data package (CSV/JSON) with progress and integrity confirmation before the account is deactivated

#### Scenario: Export after grace period is still possible

- **GIVEN** the subscription was cancelled and the account is in the grace/deactivation window
- **WHEN** the admin requests the export again
- **THEN** the export succeeds while the grace window is open, and the system records the export event
