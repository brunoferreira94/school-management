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

### Requirement: Switching cost via internalized UX

The system SHALL build switching cost by internalizing repeated micro-loops (grade→report→announcement→payment) into the user's workflow, such that migrating to a cheaper clone incurs a measurable productivity loss. The backend `SetupProgress` SHALL track loop completion timestamps to quantify the embedded state.

#### Scenario: Embedded state quantified

- **GIVEN** a school has completed 4 grade entries, 3 report views, 2 announcements, 1 payment over 30 days
- **WHEN** the system computes switching cost
- **THEN** the `SetupProgress` loop timestamps show 10 embedded actions
- **AND** the clone would require re-performing all 10 to match value

### Requirement: Expansion architecture (internal network effects)

The system SHALL grow usage through invite-to-collaborate loops where each activated teacher pulls additional data (attendance, grades) into the tenant, increasing LTV. The invitation SHALL use a passwordless magic-link to minimize friction.

#### Scenario: Activated teacher pulls data

- **GIVEN** a teacher accepts a magic-link invite and becomes active
- **WHEN** they record attendance for their class
- **THEN** the tenant's data volume increases
- **AND** the LTV proxy (`TeachersActivated` × data points) rises

### Requirement: Brand power as trust proxy

The system SHALL use a consistent proprietary visual identity across RCD surfaces to signal authority and lower CAC, resisting the "generic V0/Tailwind template" perception that dominates AI-generated SaaS.

#### Scenario: Consistent identity across surfaces

- **GIVEN** a prospect evaluates the product across welcome modal, checklist, and dashboard
- **WHEN** they compare visual treatment
- **THEN** all RCD surfaces share the ESCOLA+ token (color, radius, shadow)
- **AND** the identity is distinct from default Material
