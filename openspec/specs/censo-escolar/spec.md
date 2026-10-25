# censo-escolar Specification

## Purpose
TBD - created by archiving change add-censo-escolar-export. Update Purpose after archive.

## Requirements

### Requirement: One-click Censo Escolar export

The system SHALL export school data in the official INEP Censo Escolar import layout for a chosen academic year in one click, after validating that all mandatory census fields are complete.

#### Scenario: Export blocked until census fields are complete

- **GIVEN** some students are missing mandatory census fields
- **WHEN** the secretary clicks "Exportar para o Censo"
- **THEN** the export is blocked and the system lists each incomplete record with a link to edit it

#### Scenario: Complete data exports the official layout

- **GIVEN** all census fields are complete for the academic year
- **WHEN** the secretary exports
- **THEN** the system generates the file in the official Censo Escolar import layout

### Requirement: Census readiness checklist

The system SHALL show a readiness panel with the percentage of students, staff, and class groups with complete census data, updated as records are edited.

#### Scenario: Readiness reflects edits immediately

- **GIVEN** the readiness panel shows 80% students complete
- **WHEN** the secretary fills the missing fields of a listed student
- **THEN** the percentage updates without a full page reload
