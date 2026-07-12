# Proposal: Global Search Bar

## Why

Users currently need to navigate through the sidebar menu to access different features in the system. This creates friction when trying to quickly access specific functionalities, especially for users who are not yet familiar with the menu structure or when the desired feature is buried several levels deep. A global search bar will significantly reduce navigation time and improve the overall user experience by allowing direct access to any feature through keyboard shortcuts and fuzzy search, similar to modern development tools and operating systems.

## Problem Statement

Users currently need to navigate through the sidebar menu to access different features in the system. This creates friction when trying to quickly access specific functionalities, especially for users who are not yet familiar with the menu structure or when the desired feature is buried several levels deep.

## What Changes

A global command palette-style search bar was implemented in the topbar, allowing users to:

1. **Search for features/routes** by name or keywords (similar to VS Code Command Palette or Windows Search)
2. **Navigate instantly** to any accessible screen/route
3. **Access via keyboard shortcut** (Ctrl+K or Cmd+K)
4. **Respect permissions** - only show routes/features the user has access to

### Key Features

- **Fuzzy search**: Match partial words, handle typos gracefully
- **Keyboard navigation**: Arrow keys to move, Enter to select, Esc to close
- **Recent searches**: Show recently accessed features first
- **Categorization**: Group results by section (Acadêmico, Financeiro, etc.)
- **Visual feedback**: Highlight matching text in results
- **Responsive**: Works on desktop and mobile (with appropriate adaptations)

## User Impact

- **Reduced navigation time**: Direct access to any feature in 2-3 keystrokes
- **Improved discoverability**: Users can find features they didn't know existed
- **Better UX for power users**: Keyboard shortcuts for efficiency
- **Accessibility**: Alternative navigation method for users with different needs

## Technical Approach

### Frontend Implementation

1. **New Service**: `GlobalSearchService`

   - Maintains index of all routes with metadata (name, keywords, category, icon, permission)
   - Implements fuzzy search algorithm (using lightweight lib like fuse.js or custom implementation)
   - Tracks recent searches (localStorage)

2. **New Component**: `GlobalSearchComponent`

   - Modal/overlay with input field and results list
   - Keyboard event handling (shortcuts, navigation)
   - Integrates with Angular Router for navigation
   - Uses PermissionService to filter results

3. **Integration Points**:
   - Add search button/icon to `TopbarComponent`
   - Register global keyboard shortcut in `AppComponent`
   - Style consistent with existing Angular Material theme

### Route Metadata Structure

```typescript
interface SearchableRoute {
  path: string;
  title: string;
  keywords: string[];
  category: string;
  icon: string;
  permissions: string[];
  order?: number;
}
```

### Search Algorithm

- Weighted matching: title > keywords > category
- Score-based ranking
- Recent items boost
- Permission filtering applied post-search

## Implementation Phases

### Phase 1: Core Search (MVP)

- Basic search service with route index
- Search modal component with keyboard navigation
- Integration in topbar
- Fuzzy matching implementation

### Phase 2: Enhancements

- Keyboard shortcut (Ctrl+K)
- Recent searches
- Result categorization
- Visual improvements (icons, highlights)

### Phase 3: Advanced Features (Future)

- Search in content (students, notices, etc.)
- Contextual actions (e.g., "Add new student")
- Search history persistence
- Analytics tracking

## Risks and Mitigations

| Risk                               | Mitigation                                         |
| ---------------------------------- | -------------------------------------------------- |
| Performance with large route lists | Pre-index routes at startup, lazy load search lib  |
| Mobile UX challenges               | Simplified mobile version, touch-optimized         |
| Permission sync issues             | Subscribe to permission changes, re-filter results |
| Browser compatibility              | Use standard APIs, test in major browsers          |

## Success Metrics

- Adoption rate: % of users who use search feature
- Navigation efficiency: Time to reach target feature reduced by X%
- User satisfaction: Positive feedback in usability tests
- Reduced support tickets about "where to find X feature"

## Dependencies

- No backend changes required
- Frontend dependencies:
  - Lightweight fuzzy search library (optional, ~5KB)
  - Angular Material Dialog/Overlay (already available)

## Open Questions

All questions have been resolved:

1. ~~Should we include quick actions (like "Add new student") in search results, or only navigation routes?~~

   - **RESOLVED**: Yes, include quick actions alongside navigation routes

2. ~~Should recent searches be stored per-user in the backend or just locally?~~

   - **RESOLVED**: Persist in backend for cross-device sync and better user experience

3. ~~Do we need to support searching in multiple languages (i18n)?~~

   - **RESOLVED**: No, not in initial implementation (Portuguese only)

4. ~~Should we track search analytics (what users search for most)?~~
   - **RESOLVED**: Yes, track search analytics to improve UX and identify popular features

## Alternatives Considered

1. **Enhanced sidebar with nested search**: More complex, doesn't solve keyboard access
2. **Breadcrumb-based navigation**: Doesn't help with discovery
3. **Mega menu**: Overwhelming, not keyboard-friendly

## Related Work

- VS Code Command Palette: Excellent UX reference
- Windows Search/macOS Spotlight: System-level search patterns
- Linear/Notion quick switcher: Modern web app examples

## Approval Checklist

- [x] UX review: Search interaction patterns
- [x] Accessibility review: Keyboard navigation, screen reader support
- [x] Security review: Permission filtering logic
- [x] Performance review: Search algorithm efficiency

**Status**: ✅ **APPROVED** (2025-11-20)
