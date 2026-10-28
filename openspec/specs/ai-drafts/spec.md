# ai-drafts Specification

## Purpose
TBD - created by archiving change implement-2026-differentiators. Update Purpose after archive.

## Requirements

### Requirement: AI drafts require explicit human approval

The system SHALL generate AI-assisted drafts (guardian outreach, report-card comments, weekly director summary) that are never sent or saved as final without an explicit human review step, keeping an audit trail of who edited and approved each draft.

#### Scenario: Outreach draft for at-risk guardian

- **GIVEN** a guardian is flagged by retention risk or billing overdue
- **WHEN** the director requests a message suggestion
- **THEN** an editable draft is produced with its data basis cited, in a "review required" state that blocks direct sending

#### Scenario: Weekly director summary anchored to data

- **GIVEN** the last 7 days of school activity (invoices, grades, attendance, notices)
- **WHEN** the director opens the "tela de hoje" panel
- **THEN** a draft weekly summary with data references is available and its generation state is recorded with the snapshot source

#### Scenario: No external data leaves without consent scope

- **GIVEN** the school has not enabled external AI processing consent
- **WHEN** a draft is requested
- **THEN** the system uses only data permitted by the school's data processing settings
