# report-builder Specification

## Purpose
TBD - created by archiving change add-custom-report-builder. Update Purpose after archive.
## Requirements
### Requirement: Report template management

The system SHALL allow school administrators to create, read, update, delete, duplicate, and activate/deactivate report templates within their tenant, with full multi-tenant isolation.

#### Scenario: Create a new template

- **GIVEN** a user with `MANAGE_REPORT_TEMPLATES` permission
- **WHEN** they provide a template name, description, page size, and orientation
- **THEN** the system creates a template with a default empty layout and returns a 201 Created with the template ID

#### Scenario: Duplicate an existing template

- **GIVEN** a user with `MANAGE_REPORT_TEMPLATES` permission and an existing template
- **WHEN** they request to duplicate the template
- **THEN** the system creates a copy with "(Cópia)" suffix, includes all blocks and configurations, and returns 201 Created

#### Scenario: Tenant isolation

- **GIVEN** two tenants (Escola A and Escola B) each with their own report templates
- **WHEN** an administrator from Escola A lists templates
- **THEN** only Escola A's templates are returned

#### Scenario: Activate/deactivate template

- **GIVEN** an existing template
- **WHEN** an administrator toggles its active status
- **THEN** the system updates IsActive and only active templates appear in the generation interface

#### Scenario: Unauthorized access

- **GIVEN** a user without `MANAGE_REPORT_TEMPLATES` permission
- **WHEN** they attempt to create, update, or delete a template
- **THEN** the system returns 403 Forbidden

### Requirement: WYSIWYG editor with draggable data blocks

The system SHALL provide a visual drag-and-drop editor where administrators compose report layouts by arranging predefined data blocks (header, student info, grades, attendance, skills, comments, footer) in vertical order, with per-block configuration.

#### Scenario: Add block from palette

- **GIVEN** a user editing a template in the WYSIWYG editor
- **WHEN** they drag a "Grades" block from the palette to the canvas
- **THEN** the block appears in the canvas with a preview thumbnail and default configuration

#### Scenario: Reorder blocks

- **GIVEN** a template with multiple blocks (Header, Grades, Footer)
- **WHEN** the user drags "Grades" above "Header"
- **THEN** the canvas reorders blocks accordingly and the layout order is persisted

#### Scenario: Configure block settings

- **GIVEN** a "Grades" block on the canvas
- **WHEN** the user opens its configuration panel and sets `showWeightedAverage` to false
- **THEN** the block configuration is updated and the preview reflects the change

#### Scenario: Remove block

- **GIVEN** a non-required block on the canvas
- **WHEN** the user clicks remove
- **THEN** the block is removed from the canvas and the layout is updated

#### Scenario: Required block cannot be removed

- **GIVEN** a required block (e.g., Student Info) on the canvas
- **WHEN** the user attempts to remove it
- **THEN** the remove action is disabled with a tooltip explaining the block is required

### Requirement: Preview with real student data

The system SHALL allow previewing a report template populated with a selected student's real data before generating the final PDF.

#### Scenario: Preview with student data

- **GIVEN** a template with Grades and Attendance blocks
- **WHEN** the administrator selects a student from the preview dropdown
- **THEN** the system renders a full HTML preview of the template populated with that student's actual grades and attendance data

#### Scenario: Preview with no student selected

- **GIVEN** a template being edited
- **WHEN** no student is selected for preview
- **THEN** the canvas shows placeholder blocks with generic labels ("Nome do Aluno", "Nota: --")

### Requirement: Template-to-class-group assignment

The system SHALL allow associating report templates with one or more class groups and designating a default template per class group.

#### Scenario: Assign template to class groups

- **GIVEN** a template and three class groups
- **WHEN** the administrator assigns the template to Class Groups A and B
- **THEN** the system persists the association and returns the updated list of class groups

#### Scenario: List templates by class group

- **GIVEN** a template assigned to Class Group A
- **WHEN** a user filters templates by Class Group A
- **THEN** the system returns only templates assigned to that class group

#### Scenario: Set default template for class group

- **GIVEN** two templates assigned to a class group
- **WHEN** the administrator marks one as default
- **THEN** that template becomes the default for that class group's report card generation

### Requirement: PDF generation (individual and batch)

The system SHALL generate PDF documents from a template for one or more students, supporting both individual download and batch ZIP download.

#### Scenario: Generate PDF for single student

- **GIVEN** an active template and a student enrolled in an associated class group
- **WHEN** the administrator generates a report for that student
- **THEN** the system produces a PDF file with the student's data rendered in the template layout and returns a download link

#### Scenario: Batch generate PDFs for a class

- **GIVEN** an active template and a class group with 30 students
- **WHEN** the administrator selects all students and confirms batch generation
- **THEN** the system generates 30 PDF files and offers them as a single ZIP download

#### Scenario: Batch generation progress feedback

- **GIVEN** a batch generation in progress for 30 students
- **WHEN** the system is generating reports
- **THEN** the UI shows a progress bar with status per student (Pending/Completed/Failed)

#### Scenario: Generated report history

- **GIVEN** a previously generated report
- **WHEN** the administrator opens "Generated Reports"
- **THEN** they can see a paginated list with student name, class group, template, generation date, status, and download action

#### Scenario: PDF respects page configuration

- **GIVEN** a template configured as A4 Landscape
- **WHEN** a PDF is generated
- **THEN** the output PDF uses A4 Landscape page dimensions with proper margins

### Requirement: Predefined data blocks (v1)

The system SHALL provide at least eleven predefined block types that can be used in report templates: Header, Student Info, Grades Table, Attendance Summary, Skills/Competencies Grid, **Academic History (multi-year transcript)**, Comments, Footer, **Balance Summary**, **Installment History**, and **Payment Timeline**.

#### Scenario: Header block shows school identity

- **GIVEN** a Header block in a template
- **WHEN** a report is generated
- **THEN** the block displays the school logo, school name, and address (if configured)

#### Scenario: Grades block shows per-subject table

- **GIVEN** a Grades block with `showWeightedAverage` enabled
- **WHEN** a report is generated
- **THEN** the block renders a table with subjects, scores, weighted average percentage, and pass/fail status for each subject

#### Scenario: Skills block shows competency grid

- **GIVEN** a Skills block with `showScore` enabled
- **WHEN** a report is generated for a student with skills evaluations
- **THEN** the block renders a grid of competencies with score badges (🟢 ≥70, 🟡 40-69, 🔴 <40) per subject

#### Scenario: Attendance block shows summary

- **GIVEN** an Attendance block with `showPercentage` enabled
- **WHEN** a report is generated
- **THEN** the block renders total absences, justified vs unjustified counts, and attendance percentage

#### Scenario: Academic history block shows multi-year transcript

- **GIVEN** an Academic History block in a template and a student enrolled across multiple academic years (e.g., 2024, 2025, 2026)
- **WHEN** a report is generated
- **THEN** the block renders a table grouped by academic year, showing for each year: list of subjects/disciplines taken, final grade/average per subject, total workload/hours (if available), and final status (approved/failed)

#### Scenario: Academic history block respects year range filter

- **GIVEN** an Academic History block configured with `yearsRange: "2025-2026"`
- **WHEN** a report is generated for a student with records from 2024, 2025, and 2026
- **THEN** only the 2025 and 2026 records are displayed

#### Scenario: Balance summary block shows financial overview

- **GIVEN** a Balance Summary block in a template
- **WHEN** a report is generated for a student with installments
- **THEN** the block displays: total amount pending (unpaid), total amount paid, number of overdue installments, and overall balance

#### Scenario: Installment history block shows detailed payment table

- **GIVEN** an Installment History block in a template
- **WHEN** a report is generated for a student with multiple installments
- **THEN** the block renders a table with columns: installment number, due date, amount, payment date, status (paid/pending/overdue), and billing type (PIX/Boleto)

#### Scenario: Payment timeline block shows chronological events

- **GIVEN** a Payment Timeline block in a template
- **WHEN** a report is generated for a student with payment history
- **THEN** the block renders a chronological list of payment events, each showing: date of payment, amount paid, payment method, and gateway reconciliation status

#### Scenario: Comments block is editable text field

- **GIVEN** a Comments block in a template
- **WHEN** the report is being generated
- **THEN** the system allows the teacher to input free-text observations for each student

### Requirement: Permission model

The system SHALL enforce role-based access control with two dedicated permissions: `MANAGE_REPORT_TEMPLATES` for template CRUD and `VIEW_REPORTS` for viewing and generating reports.

#### Scenario: Manage-only users cannot generate reports

- **GIVEN** a user with `MANAGE_REPORT_TEMPLATES` but not `VIEW_REPORTS`
- **WHEN** they attempt to access the generation interface
- **THEN** the system returns 403 Forbidden

#### Scenario: View-only users cannot edit templates

- **GIVEN** a user with `VIEW_REPORTS` but not `MANAGE_REPORT_TEMPLATES`
- **WHEN** they attempt to access the editor
- **THEN** the system returns 403 Forbidden

#### Scenario: Full access for admins

- **GIVEN** a user with both `MANAGE_REPORT_TEMPLATES` and `VIEW_REPORTS`
- **WHEN** they access any report builder feature
- **THEN** the system allows full CRUD and generation access

