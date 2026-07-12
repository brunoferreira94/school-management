# listings Specification

## Purpose
TBD - created by archiving change add-skeleton-loading. Update Purpose after archive.
## Requirements
### Requirement: Skeleton loading for list pages

The system SHALL provide a reusable skeleton loading component that preserves the visual structure of table-based list pages while data is being fetched.

#### Scenario: Students list is loading

- **WHEN** the user opens the students list page
- **AND** the student data request is still in progress
- **THEN** the page shows skeleton rows that match the student table columns
- **AND** the user sees a stable layout instead of an empty table

#### Scenario: Teachers list is loading

- **WHEN** the user opens the teachers list page
- **AND** the teacher data request is still in progress
- **THEN** the page shows skeleton rows that match the teacher table columns
- **AND** the user sees a stable layout instead of an empty table

### Requirement: Reusable skeleton loading component

The system SHALL expose a standalone skeleton loading component that can be reused by other list pages.

#### Scenario: Component renders rows and columns

- **WHEN** the component is used with row and column inputs
- **THEN** it renders a table placeholder with the requested number of rows and columns
- **AND** it animates the placeholder to communicate loading state

