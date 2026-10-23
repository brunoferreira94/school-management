## ADDED Requirements

### Requirement: Search results with contextual actions

For entity results (student, invoice, class group), the global search SHALL return contextual actions executable directly from the search result (e.g. generate a second copy of an invoice, open the student's financial page, send a class announcement), filtered by the searching user's permissions.

#### Scenario: Second copy generated from search

- **GIVEN** a staff user with billing permissions
- **WHEN** they search a student by name
- **THEN** the result offers a "2ª via" action that generates the invoice copy without navigating away

#### Scenario: Actions respect permissions

- **GIVEN** a teacher without billing permissions
- **WHEN** they search the same student
- **THEN** no billing action is offered in the result
