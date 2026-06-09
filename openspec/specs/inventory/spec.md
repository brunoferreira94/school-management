# inventory Specification

## Purpose
TBD - created by archiving change integrate-inventory-screen. Update Purpose after archive.
## Requirements
### Requirement: Asset management API

The system SHALL provide CRUD APIs and UI screens to create, list, update, and archive assets with fields for category, acquisition date, cost, depreciation method, status, and assigned location.

#### Scenario: Create and view asset

- **GIVEN** a staff member with `MANAGE_ASSETS` permission submits a new asset form
- **WHEN** the API processes the request
- **THEN** it returns 201 Created with the asset data and the asset appears in the inventory list with correct location and status

### Requirement: Attachment handling

The system SHALL allow uploading, listing, and deleting attachments for each asset, enforcing file type and size limits and storing metadata such as uploader and upload date.

#### Scenario: Upload asset attachment

- **GIVEN** an asset exists
- **WHEN** the user uploads a PDF receipt via the attachments endpoint
- **THEN** the system stores the file, records metadata, and makes the attachment available for download

### Requirement: Audit and history

The system SHALL track asset lifecycle events (status changes, location transfers, disposal) and expose a chronological history log per asset.

#### Scenario: Track location transfer

- **GIVEN** an asset is reassigned from Lab A to Lab B
- **WHEN** the transfer is saved
- **THEN** the history log records the previous and new locations with timestamp and user

### Requirement: Permissions and tenancy

The system SHALL enforce tenant scoping and role-based permissions such that only users with `VIEW_ASSETS` can read asset data and only users with `MANAGE_ASSETS` can modify or delete assets.

#### Scenario: Prevent unauthorized edit

- **GIVEN** a user has `VIEW_ASSETS` but not `MANAGE_ASSETS`
- **WHEN** they attempt to update an asset
- **THEN** the API returns 403 Forbidden and no changes are applied

