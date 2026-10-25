## ADDED Requirements

### Requirement: Weekly class diary as the single data source

The teacher SHALL record each class (content taught, attendance, notes) exactly once in the weekly diary, and all downstream artifacts (coordination reports, report-card comments) SHALL be generated from that data without re-entry.

#### Scenario: Coordination report from diary data

- **GIVEN** a teacher recorded the week's classes in the diary
- **WHEN** they click "gerar relatório para coordenação"
- **THEN** the weekly report is produced from the diary data alone
- **AND** no field of the report requires data not already present in the diary

### Requirement: AI report-card comment drafts with cited basis

The system SHALL generate an editable draft report-card comment per student that cites the student's real grades and attendance from the diary, in a "review required" state that blocks saving as final without explicit teacher approval, keeping an audit trail of who approved.

#### Scenario: Comment draft blocked without approval

- **GIVEN** a student with recorded grades and absences
- **WHEN** the teacher requests a report-card comment draft
- **THEN** an editable draft is produced citing the student's actual grades and attendance
- **AND** the draft cannot be saved as final until the teacher approves it

### Requirement: Lesson plan drafts with BNCC pre-mapped

The system SHALL suggest lesson plan drafts with BNCC skill codes pre-mapped by subject and grade, always editable, and never auto-published without teacher review.

#### Scenario: BNCC skill suggestion

- **GIVEN** a teacher starts a lesson plan for a 6th-grade math class
- **WHEN** they request a plan draft
- **THEN** the suggestion includes pre-filled BNCC skill codes for the subject and grade
- **AND** the teacher can edit any field before saving
