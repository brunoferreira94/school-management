## MODIFIED Requirements

### Requirement: UI motion performance and accessibility

The system SHALL implement high-craft motion following Emil Kowalski's design engineering principles, with explicit property transitions and touch-device compatibility.

#### Scenario: Explicit property transitions

- **WHEN** a UI element has an animated state change
- **THEN** the transition property lists only animatable properties (background, color, transform, opacity, border-color, box-shadow), never `all`

#### Scenario: Touch-device hover compatibility

- **WHEN** a hover state includes transform effects
- **THEN** those effects are gated by `@media (hover: hover) and (pointer: fine)` to prevent unwanted activation on touch devices

#### Scenario: Consistent scale values

- **WHEN** an interactive element scales on hover
- **THEN** it uses `scale(1.03)` (not 1.05) for subtle perceptual feedback