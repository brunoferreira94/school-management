## ADDED Requirements

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
