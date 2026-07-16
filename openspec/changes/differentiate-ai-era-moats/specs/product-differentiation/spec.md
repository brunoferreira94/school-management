## ADDED Requirements

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
