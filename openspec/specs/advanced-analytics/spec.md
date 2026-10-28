# advanced-analytics Specification

## Purpose
Esta capacidade entrega dashboards analíticos para gestão da operação da escola, com métricas de retenção, inadimplência, ocupação de turmas, desempenho de alunos e churn de responsáveis. Inclui drill-down por campus, curso e período, pipeline ETL para popular um warehouse analítico, atualização diária das métricas e visibilidade do status da última carga.

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

### Requirement: Explainable churn and delinquency risk scores

The analytics module SHALL compute daily churn and delinquency risk scores per student/family from consolidated data (attendance, grades, payment delays, portal usage), and each score SHALL be explainable with its contributing factors in plain language.

#### Scenario: Score factors are explained

- **GIVEN** a student with a high churn risk score
- **WHEN** the coordinator opens the student's risk detail
- **THEN** the contributing factors are listed in plain language (e.g. "12 faltas no mês; 2 notas abaixo da média")

### Requirement: High-risk scores feed the action queue

Students/families above the configured risk threshold SHALL automatically appear in the director's today-screen queue with an editable outreach draft attached, closing the loop from prediction to action.

#### Scenario: Risk feeds today screen

- **GIVEN** a family whose delinquency score crosses the threshold
- **WHEN** the daily scoring job runs
- **THEN** an action is queued on the today screen with an outreach draft citing the family's real payment data
