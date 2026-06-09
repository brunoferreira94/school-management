# Admin Page Standardization

Concise Angular 19 + Tailwind 4 guidance for CRUD-style admin pages such as finance, attendance, assignments, enrollments, reports, notices, and timetabling.

## 1. Standardize layout with shared wrappers
- Use one page shell component for title, subtitle, actions, and content.
- Use one filter/toolbar wrapper and one card/section wrapper.
- Prefer `gap-*` spacing rules over ad-hoc margins.
- Keep a small spacing scale and reuse it everywhere.

## 2. Normalize native form controls
- Apply one shared visual pattern to inputs, selects, textareas, and buttons.
- Keep height, padding, border radius, and typography identical.
- Always include hover, focus, invalid, and disabled states.
- Use labels and helper/error text consistently.

## 3. Make filter/action rows responsive
- Stack controls on small screens and move to wrapped rows on larger screens.
- Separate filters from actions, with one primary action only.
- Keep action order predictable across all pages.
- Use consistent widths for common field types.

## 4. Keep templates thin and reusable
- Prefer standalone Angular components for field rows, toolbars, and action groups.
- Use reactive forms for complex forms and signals for local UI state.
- Use modern template syntax like `@if` and `@for`.
- Avoid repeating utility-class bundles inside each feature page.

## Relevant concepts
- Shared page shell
- Toolbar/filter bar pattern
- Field wrapper pattern
- Design tokens or semantic utility classes
- Mobile-first responsive layout
- Accessible focus and validation states
