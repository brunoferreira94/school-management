# global-search Specification

## Purpose
TBD - created by archiving change add-global-search. Update Purpose after archive.
## Requirements
### Requirement: Quick feature discovery

The system SHALL provide a global search bar accessible from any screen that indexes all application routes with metadata (title, keywords, category, icon) and allows fuzzy text matching to help users discover and navigate to features without browsing menus.

#### Scenario: Search for feature by partial name

- **GIVEN** a user with access to the Students feature
- **WHEN** they open the search bar (via Ctrl+K or clicking the search icon) and type "alun"
- **THEN** the system displays "Alunos" route as the top result, categorized under "Principal", with a score-based ranking reflecting title match quality

#### Scenario: Search with typo

- **GIVEN** a user searching for the Finance feature
- **WHEN** they type "financero" (typo in "financeiro")
- **THEN** the system applies fuzzy matching and still shows "Financeiro" in the results with an appropriate relevance score

### Requirement: Permission-aware results

The system SHALL filter search results based on the authenticated user's permissions, ensuring only accessible routes are displayed and SHALL update the result set when user permissions change during the session.

#### Scenario: Search without finance permission

- **GIVEN** a user without FINANCE_MANAGE permission
- **WHEN** they search for "financeiro" or "payments"
- **THEN** the system returns no results (or a message indicating restricted access) and does not expose the /finance route

#### Scenario: Grant permission during session

- **GIVEN** a user actively using the search feature
- **WHEN** their permissions are updated to include a new feature (e.g., STUDENTS_WRITE)
- **THEN** subsequent searches reflect the new permission and previously hidden routes now appear in results

### Requirement: Keyboard-first interaction

The system SHALL support full keyboard navigation with a global shortcut (Ctrl+K or Cmd+K on macOS) to open the search modal, arrow keys to navigate results, Enter to select, and Esc to close, allowing power users to navigate without touching the mouse.

#### Scenario: Open search with keyboard shortcut

- **GIVEN** a user on any screen of the application
- **WHEN** they press Ctrl+K (or Cmd+K on macOS)
- **THEN** the search modal opens immediately with focus on the input field, and the current content is blurred

#### Scenario: Navigate with arrow keys

- **GIVEN** the search modal is open with 5 results displayed
- **WHEN** the user presses the Down arrow key 3 times
- **THEN** the 3rd result is highlighted, and pressing Enter navigates to that route and closes the modal

#### Scenario: Close with Escape

- **GIVEN** the search modal is open
- **WHEN** the user presses Esc
- **THEN** the modal closes, focus returns to the previous element, and the search query is cleared

### Requirement: Recent search tracking

The system SHALL maintain a history of recent searches in browser localStorage, displaying recently accessed routes with a visual indicator and boosting their relevance score by 20 points, and SHALL provide a way to clear this history.

#### Scenario: Access recent route faster

- **GIVEN** a user previously searched for "Alunos" and navigated there
- **WHEN** they open the search again and type "alu"
- **THEN** "Alunos" appears at the top (or near top) due to the recent search bonus, above other similarly scored matches

#### Scenario: Clear history

- **GIVEN** a user with a populated recent search history
- **WHEN** they trigger the "clear history" action (via UI control or service method)
- **THEN** recent searches are removed from localStorage, and future searches no longer receive the recency boost

