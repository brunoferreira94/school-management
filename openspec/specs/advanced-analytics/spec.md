# advanced-analytics Specification

## Purpose
TBD - created by archiving change implement-advanced-analytics. Update Purpose after archive.
## Requirements
### Requirement: Operational analytics dashboards

The system SHALL provide interactive dashboards for retention, delinquency, class occupancy, student performance, and guardian churn, each with drill-down filters by campus, course, and timeframe.

#### Scenario: Apply dashboard filters

- **GIVEN** a user with `VIEW_ANALYTICS` permission viewing the retention dashboard
- **WHEN** they filter by a specific campus and academic year
- **THEN** the dashboard refreshes to show metrics scoped to the selected campus and year within three seconds

### Requirement: Scheduled data aggregation

The system SHALL run ETL pipelines that populate an analytics warehouse with normalized fact tables and SHALL refresh analytics metrics at least once per day, providing status visibility for the latest successful run.

#### Scenario: ETL status visible

- **GIVEN** the daily aggregation completed successfully at 02:00
- **WHEN** an administrator opens the analytics settings
- **THEN** the UI presents the timestamp of the latest successful refresh and indicates any pending or failed jobs

### Requirement: Metric export

The system SHALL allow exporting dashboard data to CSV and PDF, respecting applied filters, and SHALL include generated-at metadata in the exported files.

#### Scenario: Export filtered metrics

- **GIVEN** a user filters the delinquency dashboard by "overdue > 30 days"
- **WHEN** they export to CSV
- **THEN** the downloaded file contains only records matching the filter and includes a header with the export timestamp and filter summary

### Requirement: Data governance and definitions

The system SHALL expose metric definitions (data dictionary) within the analytics module so that users can inspect how each KPI is calculated, including field sources and aggregation windows.

#### Scenario: View metric definition

- **GIVEN** a user reviews the occupancy dashboard
- **WHEN** they open the definition panel for "Class Occupancy"
- **THEN** the panel displays the formula, included data sources, and the refresh cadence for that metric

