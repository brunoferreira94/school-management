# UI Animation Refactor Design

## Context

The UI currently has 30+ instances of `transition: all` which violates the animation craft standards. This is a cross-cutting change affecting multiple components in the report-builder feature and shared UI components.

## Goals / Non-Goals

- **Goals**: Performance improvements, accessibility compliance, consistent motion
- **Non-Goals**: Redesigning visual aesthetics, changing component behavior

## Decisions

### Decision: Replace `transition: all` with explicit properties
- **Rationale**: `transition: all` can trigger animations on unintended properties (box-shadow, color changes) causing jank and unpredictable behavior
- **Pattern**: Use specific properties — typically `background`, `transform`, `opacity`, `border-color`, `box-shadow`

### Decision: Add hover/pointer media query gating
- **Rationale**: Touch devices fire `:hover` on tap, causing incorrect animations
- **Pattern**: `@media (hover: hover) and (pointer: fine) { .element:hover { transform: scale(1.03); } }`

### Decision: Reduce hover scale to 1.03
- **Rationale**: 1.05 scale feels exaggerated; 1.02-1.03 is subtle but perceptible feedback

### Decision: Remove duplicate keyframes
- **Rationale**: slideDown, slideUp, scaleIn, shimmer are already defined in styles.scss; components redefine them unnecessarily

## Risks / Trade-offs

- **Risk**: Missing a `transition: all` instance → jank on focus/hover
- **Mitigation**: Systematic search across all component SCSS files

- **Risk**: Hover gating may affect some intentional focus styles
- **Mitigation**: Keep `:focus-visible` styles outside the media query for keyboard accessibility

## Migration Plan

1. Update each file systematically using search/replace for `transition: all`
2. Verify in browser that hover states still work on mouse devices
3. Verify on touch device or using devtools touch simulation