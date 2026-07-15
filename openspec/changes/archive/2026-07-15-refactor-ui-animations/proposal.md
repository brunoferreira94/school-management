## Why

The current UI uses `transition: all` extensively (~30+ occurrences across component styles), which animates unintended properties and can trigger layout/paint operations under load. Hover animations lack pointer/hover gating, causing incorrect behavior on touch devices where `:hover` fires on tap. Some components redefine keyframes already defined in styles.scss.

## What Changes

Replace all `transition: all` with explicit property lists, add `@media (hover: hover) and (pointer: fine)` guards for hover transforms, remove redundant keyframe definitions, and standardize scale values.

## Effort

Small (~30 minutes for search/replace across 5 component files)

## Implementation Notes

See `tasks.md` for the complete checklist. Key changes:
- `transition: all var(--transition-fast)` → explicit properties
- `transform: scale(1.05)` → `scale(1.03)` for subtlety
- Wrap hover transforms in media query for touch compatibility