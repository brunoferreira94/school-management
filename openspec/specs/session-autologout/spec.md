# session-autologout Specification

## Purpose
TBD - created by archiving change add-inactivity-session-confirm. Update Purpose after archive.
## Requirements
### Requirement: supported timeout values

The system SHALL support inactivity timeout values of `15`, `30`, and `60` minutes.

#### Scenario: default timeout is used when no value is saved

- **GIVEN** no inactivity timeout is stored in `localStorage`
- **WHEN** the inactivity service starts
- **THEN** the effective timeout is `30` minutes

### Requirement: persisted timeout

The system SHALL persist the selected timeout in `localStorage`.

#### Scenario: saved timeout is restored

- **GIVEN** `localStorage` contains `30`
- **WHEN** the inactivity service starts
- **THEN** the effective timeout is `30` minutes

### Requirement: invalid timeout normalization

The system SHALL normalize invalid stored values to the default timeout.

#### Scenario: invalid saved timeout falls back to default

- **GIVEN** `localStorage` contains an invalid value
- **WHEN** the inactivity service starts
- **THEN** the effective timeout is `30` minutes

### Requirement: activity resets timer

The system SHALL treat mouse movement, keyboard input, click/tap, scroll, and document visibility returning to active as activity.

#### Scenario: activity resets timer

- **GIVEN** the user is authenticated
- **AND** the inactivity timeout is `15` minutes
- **WHEN** the user performs activity before the timeout expires
- **THEN** the logout timer is reset

### Requirement: inactivity warning

The system SHALL show a session confirmation warning when the inactivity timer expires.

#### Scenario: inactivity warning is shown

- **GIVEN** the user is authenticated
- **AND** the inactivity timeout is `15` minutes
- **WHEN** no activity occurs for `15` minutes
- **THEN** the user sees a confirmation warning

### Requirement: continue session

The system SHALL renew the session when the user confirms that they are still present.

#### Scenario: user continues the session

- **GIVEN** the inactivity warning is visible
- **WHEN** the user confirms they are still present
- **THEN** the token is refreshed
- **AND** the inactivity timer is reset

### Requirement: forced logout after grace period

The system SHALL log the user out and navigate to `/login` when the user ignores the warning until the grace period expires.

#### Scenario: user ignores the warning

- **GIVEN** the inactivity warning is visible
- **AND** the grace period is `5` minutes
- **WHEN** no activity occurs for `5` minutes
- **THEN** the user is logged out
- **AND** the user is redirected to `/login`

