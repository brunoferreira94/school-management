## ADDED Requirements

### Requirement: AI narrative block with cited basis

The report builder SHALL support an `ai-narrative` block that generates an executive summary in natural language from the report's own data blocks, always citing the numbers that produced it, in a "review required" state that blocks export until a human approves.

#### Scenario: Narrative cites report data

- **GIVEN** a monthly executive report with data blocks for enrollment, delinquency, and attendance
- **WHEN** the AI narrative block is generated
- **THEN** the narrative references only the numbers present in the report's data blocks

#### Scenario: Export blocked until narrative is approved

- **GIVEN** a report whose AI narrative block is in "review required" state
- **WHEN** a user attempts to export the PDF
- **THEN** the export is blocked until the narrative is explicitly approved, and the approval is recorded in the audit trail
