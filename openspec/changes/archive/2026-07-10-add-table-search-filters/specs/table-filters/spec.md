<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Reusable table search and filter state

The system SHALL provide a reusable frontend table filter utility that supports text search, configurable filter fields, debounce of `500ms`, and localStorage persistence per table key.

#### Scenario: Save and restore student table filters

- **GIVEN** an administrator searches for a student by name or CPF
- **WHEN** the search input is idle for `500ms`
- **THEN** the system applies the filter and stores the active filter state in `localStorage`
- **AND** when the administrator returns to the student list, the same filter is restored

#### Scenario: Clear saved table filters

- **GIVEN** a table has active filters saved in `localStorage`
- **WHEN** the administrator clicks the clear filters action
- **THEN** the system clears the active filters, removes the saved state, and displays the full list again

### Requirement: Student table instant search

The system SHALL provide instant search on the student list without requiring a page reload, filtering loaded student records by name, CPF, and other relevant visible fields.

#### Scenario: Search students by name

- **GIVEN** the student list is loaded
- **WHEN** the administrator types part of a student name
- **THEN** the table updates after the debounce delay and shows only matching students

#### Scenario: Search students by CPF

- **GIVEN** the student list is loaded
- **WHEN** the administrator types a CPF value
- **THEN** the table filters students by CPF and keeps the current page context clear

### Requirement: Teacher table instant search

The system SHALL provide instant search on the teacher list without requiring a page reload, filtering loaded teacher records by name, CPF, and other relevant visible fields.

#### Scenario: Search teachers by name

- **GIVEN** the teacher list is loaded
- **WHEN** the administrator types part of a teacher name
- **THEN** the table updates after the debounce delay and shows only matching teachers

#### Scenario: Search teachers by CPF

- **GIVEN** the teacher list is loaded
- **WHEN** the administrator types a CPF value
- **THEN** the table filters teachers by CPF and keeps the current page context clear

### Requirement: Empty state for filtered tables

The system SHALL display an empty state when a table has active filters but no matching records, explaining that no records matched the current filters and offering a way to clear them.

#### Scenario: No matching records

- **GIVEN** a table has active filters
- **WHEN** no loaded records match the filters
- **THEN** the system displays an empty state with a clear filters action
