# product-differentiation Specification

## Purpose
AI-Era Differentiation for School Management using Revenue-Centric Design (RCD) principles.

## Requirements

### Requirement: Switching cost via micro-loops

The system SHALL create engaging daily workflows that make leaving costly by guiding directors through micro-loops (grade entry, report card review, announcements, payments) with persistent state.

#### Scenario: Director completes micro-loop sequence

- **GIVEN** a director uses the system daily
- **WHEN** they complete a micro-loop
- **THEN** the system tracks completion in SetupProgress and suggests the next relevant action

### Requirement: Daily attention via single-focus screen

The system SHALL provide a "tela de hoje" (today screen) with exactly one primary action (most urgent issue) to capture daily attention without overwhelming the user.

#### Scenario: Director sees today's primary action

- **GIVEN** there are unpaid invoices
- **WHEN** the director opens the home dashboard
- **THEN** the system shows inadimplência as the primary action with "ver detalhes" button

### Requirement: Brand confidence via design language

The system SHALL use proprietary design tokens (ESCOLA+ color #4f46e5, 12px radius, confirm pulse) to create visual confidence and differentiation from generic SaaS.

#### Scenario: Action button shows brand pulse

- **GIVEN** the director clicks "convidar professor"
- **WHEN** the invite is successful
- **THEN** the button pulses with the ESCOLA+ brand color confirmation

### Requirement: Human touch in errors

The system SHALL replace technical error messages with warm, conversational language that suggests recovery actions ("A gente erramos aqui", "Tentar de novo").

#### Scenario: API error shows gentle message

- **GIVEN** an API call fails with status 500
- **WHEN** the error card renders
- **THEN** the system displays "A gente erramos aqui" with a retry button