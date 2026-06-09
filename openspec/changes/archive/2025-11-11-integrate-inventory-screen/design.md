# Design notes — Inventory screen

## UI sketches

- Assets list: toolbar with search and filters. Table with columns `Tag | Name | Category | Location | Status | Actions`.
- Asset form: two-column layout — left: basic fields; right: notes editor and attachments panel.

## Data relationships

- Asset may have many Attachments (1:N) — reuse attachments endpoints used by Documents and other features.

## Integration points

- Reuse `ToastService`, `ConfirmService`, `PaginatorComponent` and `sanitizeHtml`.
- Leverage existing auth guard and permission directive/pipe to show/hide UI elements.

## Implementation hints

- Prefer lazy-loading the assets module.
- Use Reactive Forms; use `uploadAttachmentWithProgress` pattern for attachment uploads.
