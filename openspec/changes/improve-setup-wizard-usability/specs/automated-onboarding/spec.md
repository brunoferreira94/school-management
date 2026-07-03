<!-- markdownlint-disable MD041 -->

## MODIFIED Requirements

### Requirement: Bulk import with validation

The system SHALL support CSV imports for students, guardians, staff, class schedules, courses, and class groups during onboarding. The system SHALL validate the payload before persisting, provide a preview of valid records, block invalid batches that would create inconsistent data, and produce a downloadable error report referencing row numbers and validation messages.

#### Scenario: Import courses and class groups successfully

- **GIVEN** an administrator opens the setup wizard import step
- **WHEN** they upload a CSV containing valid course and class group rows
- **THEN** the system displays a preview with record counts and validation status
- **AND** after confirmation the system creates the courses and class groups as part of the onboarding setup

#### Scenario: Import with validation errors

- **GIVEN** the administrator uploads a CSV where one class group has capacity below the allowed range
- **WHEN** the import validation runs
- **THEN** the system blocks the import, highlights the affected row, and generates an error report with the row number and validation message

## ADDED Requirements

### Requirement: Setup wizard CPF/CNPJ inline validation

The system SHALL validate CPF/CNPJ values inline during the school unit data step when a document field is present, and SHALL show a clear message before the administrator can proceed.

#### Scenario: Valid CPF/CNPJ accepted

- **GIVEN** the administrator enters a valid CPF or CNPJ in the school unit document field
- **WHEN** the field loses focus or the step is submitted
- **THEN** the system marks the value as valid and allows the administrator to continue

#### Scenario: Invalid CPF/CNPJ blocked

- **GIVEN** the administrator enters an invalid CPF/CNPJ
- **WHEN** the setup wizard step is submitted
- **THEN** the system prevents navigation to the next step and displays an inline validation message

### Requirement: Setup wizard explanatory tooltips

The system SHALL provide contextual tooltips for setup wizard fields that commonly cause confusion, including school unit document, classroom code, course name, class group name, class group capacity, and batch import controls.

#### Scenario: View tooltip for classroom code

- **GIVEN** the administrator is on the classroom step
- **WHEN** they open the tooltip for classroom code
- **THEN** the system explains examples such as SIGE code, room label, or lab identifier

#### Scenario: View tooltip for class group capacity

- **GIVEN** the administrator is editing a class group
- **WHEN** they open the capacity tooltip
- **THEN** the system explains the accepted capacity range and why it matters for scheduling

### Requirement: Class group capacity bounds

The system SHALL validate class group capacity during setup wizard entry and import, accepting values from 10 to 40 students and rejecting values outside that range with a clear message.

#### Scenario: Valid capacity accepted

- **GIVEN** the administrator enters class group capacity `30`
- **WHEN** the class group form is validated
- **THEN** the system accepts the value and allows submission

#### Scenario: Capacity below minimum rejected

- **GIVEN** the administrator enters class group capacity `5`
- **WHEN** the class group form is validated
- **THEN** the system rejects the value and explains that capacity must be at least 10 students

### Requirement: Downloadable setup import template

The system SHALL provide a downloadable CSV template for setup wizard batch import, including the required columns, example values, and formatting notes for courses and class groups.

#### Scenario: Download import template

- **GIVEN** the administrator opens the setup wizard import step
- **WHEN** they select the template download action
- **THEN** the system downloads a CSV file with the expected columns and sample rows
