# Design: Global Search Implementation

## Architecture Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                        AppComponent                          │
│  - Registers global keyboard listener (Ctrl+K/Cmd+K)        │
│  - Opens GlobalSearchComponent modal on trigger             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     TopbarComponent                          │
│  - Search icon/button to trigger search modal               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  GlobalSearchComponent                       │
│  - Modal overlay with input field                           │
│  - Results list with keyboard navigation                    │
│  - Integrates GlobalSearchService + Router                  │
│  - Renders routes AND quick actions                         │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ GlobalSearch    │ │ PermissionService│ │ Angular Router   │
│ Service         │ │                  │ │                  │
│ - Route index   │ │ - Filter by perms│ │ - Navigate       │
│ - Quick actions │ │                  │ │ - Execute action │
│ - Fuzzy search  │ │                  │ │                  │
│ - Recent items  │ │                  │ │                  │
│ - Analytics     │ │                  │ │                  │
└─────────────────┘ └──────────────────┘ └──────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                               │
│  GET  /api/search/history      - Load user search history   │
│  POST /api/search/history      - Save search event          │
│  POST /api/search/analytics    - Track search metrics       │
└─────────────────────────────────────────────────────────────┘
```

## Component Design

### GlobalSearchComponent

**Responsibility**: Render search UI, handle user interactions, coordinate search and navigation

**Interface**:

```typescript
@Component({
  selector: 'app-global-search',
  standalone: true,
  templateUrl: './global-search.component.html',
  styleUrls: ['./global-search.component.scss']
})
export class GlobalSearchComponent implements OnInit, OnDestroy {
  searchQuery$ = new BehaviorSubject<string>('');
  results$ = new Observable<SearchResult[]>();
  selectedIndex = 0;
  isOpen = false;

  @HostListener('document:keydown', ['$event'])
  handleKeyboard(event: KeyboardEvent): void;

  open(): void;
  close(): void;
  navigate(result: SearchResult): void;
}
```

**Key Behaviors**:

- Opens as fullscreen overlay on mobile, centered dialog on desktop
- Debounces search input (300ms)
- Highlights selected result
- Closes on Esc, blur, or successful navigation
- Shows empty state when no results

### GlobalSearchService

**Responsibility**: Maintain searchable route index, execute search, track history

**Interface**:

```typescript
@Injectable({ providedIn: "root" })
export class GlobalSearchService {
  private routeIndex: SearchableRoute[] = [];
  private quickActions: QuickAction[] = [];

  initialize(routes: Routes): void;
  search(query: string, userPermissions: string[]): Observable<SearchResult[]>;

  // Backend-synced history
  loadSearchHistory(): Observable<SearchHistoryItem[]>;
  recordSearch(
    query: string,
    itemId: string,
    itemType: "route" | "action"
  ): Observable<void>;
  clearHistory(): Observable<void>;

  // Analytics
  trackSearchEvent(
    query: string,
    resultCount: number,
    selectedItem?: string
  ): Observable<void>;

  // Quick actions
  executeAction(action: QuickAction): void;
}
```

**Search Algorithm**:

1. Filter routes by user permissions
2. Apply fuzzy matching (title, keywords, category)
3. Calculate relevance score:
   - Exact title match: 100 points
   - Title contains query: 75 points
   - Keyword match: 50 points
   - Category match: 25 points
   - Recent search: +20 bonus
4. Sort by score (descending)
5. Limit to top 10 results

### Route Index Structure

```typescript
interface SearchableRoute {
  path: string; // '/students'
  title: string; // 'Alunos'
  keywords: string[]; // ['students', 'estudantes', 'cadastro']
  category: string; // 'Acadêmico'
  icon: string; // '👥'
  permissions: string[]; // [PERMISSIONS.STUDENTS_READ]
  order?: number; // Optional display priority
  type: "route"; // Discriminator
}

interface QuickAction {
  id: string; // 'add-student'
  title: string; // 'Adicionar Novo Aluno'
  keywords: string[]; // ['add', 'new', 'create', 'novo']
  category: string; // 'Ações Rápidas'
  icon: string; // '➕'
  permissions: string[]; // [PERMISSIONS.STUDENTS_WRITE]
  action: () => void; // Function to execute
  type: "action"; // Discriminator
}

type SearchableItem = SearchableRoute | QuickAction;

interface SearchResult extends SearchableItem {
  score: number; // Relevance score
  matchedText?: string; // Highlighted match portion
}

interface SearchHistoryItem {
  id: string;
  query: string;
  itemId: string;
  itemType: "route" | "action";
  timestamp: Date;
  userId: string;
  tenantId: string;
}
```

## Data Flow

### Search Flow

```text
User types query
      │
      ▼
GlobalSearchComponent.searchQuery$ emits
      │
      ▼
Debounce 300ms
      │
      ▼
GlobalSearchService.search(query, permissions)
      │
      ├──> Filter by permissions
      ├──> Apply fuzzy matching
      ├──> Score results
      └──> Sort & limit
      │
      ▼
SearchResult[] emitted
      │
      ▼
GlobalSearchComponent renders results
```

### Navigation Flow

```text
User selects result (Enter/Click)
      │
      ▼
GlobalSearchComponent.navigate(result)
      │
      ├──> GlobalSearchService.recordSearch(query, route)
      │         └──> Save to localStorage
      │
      ├──> Router.navigate([result.path])
      │
      └──> GlobalSearchComponent.close()
```

## Route Index Population

The route index will be built at application startup by processing `app.routes.ts`:

```typescript
// In GlobalSearchService.initialize()
const searchableRoutes: SearchableRoute[] = [
  {
    path: "/students",
    title: "Alunos",
    keywords: ["students", "estudantes", "cadastro", "matrícula"],
    category: "Principal",
    icon: "👥",
    permissions: [PERMISSIONS.STUDENTS_READ],
  },
  {
    path: "/calendar",
    title: "Calendário",
    keywords: ["calendar", "eventos", "events", "agenda"],
    category: "Principal",
    icon: "📅",
    permissions: [PERMISSIONS.CLASSES_READ],
  },
  {
    path: "/finance",
    title: "Financeiro",
    keywords: ["finance", "pagamentos", "mensalidades", "cobrança"],
    category: "Principal",
    icon: "💰",
    permissions: [PERMISSIONS.FINANCE_MANAGE],
  },
  // ... more routes
];
```

**Maintenance Strategy**:

- Index defined as static configuration (not auto-generated from routes)
- Reason: Need to add metadata (keywords, icons, categories) that don't exist in route definitions
- Co-located with route definitions for easy updates
- Could be extracted to separate JSON file for i18n support

## Keyboard Interactions

| Key            | Action                      |
| -------------- | --------------------------- |
| Ctrl+K / Cmd+K | Open search modal           |
| Esc            | Close search modal          |
| ↓ / Tab        | Move to next result         |
| ↑ / Shift+Tab  | Move to previous result     |
| Enter          | Navigate to selected result |
| Click outside  | Close modal                 |

## Responsive Design

### Desktop (>768px)

- Centered modal (600px width, 400px max height)
- Full keyboard navigation support
- Hover states on results

### Mobile (<768px)

- Full-screen overlay
- Touch-optimized result items (larger tap targets)
- Virtual keyboard-aware positioning
- Swipe down to close (optional enhancement)

## Performance Considerations

### Search Performance

- Pre-built index (no runtime parsing)
- Debounced input (300ms)
- Limit results to top 10
- Simple string matching (no complex regex)

**Estimated Performance**:

- Index size: ~50 routes × 200 bytes = ~10KB
- Search time: <5ms for 50 routes
- No backend calls needed

### Bundle Size Impact

- GlobalSearchComponent: ~3KB
- GlobalSearchService: ~2KB
- Optional fuzzy search lib (fuse.js): ~5KB (gzipped)
- **Total**: ~10KB additional bundle size

### Optimization Strategies

1. Lazy load search component (only when first opened)
2. Use native string methods instead of heavy fuzzy lib
3. Virtual scrolling for results (if list grows beyond 10)

## Testing Strategy

### Unit Tests

- **GlobalSearchService**:
  - Route filtering by permissions
  - Search scoring algorithm
  - Recent searches management
- **GlobalSearchComponent**:
  - Keyboard event handling
  - Result selection logic
  - Modal open/close behavior

### Integration Tests

- Search → navigate flow
- Permission-based result filtering
- Keyboard shortcuts (Ctrl+K)

### E2E Tests

- User searches for "alunos" → navigates to /students
- User searches with no permissions → sees appropriate message
- User uses keyboard to navigate results

## Security Considerations

1. **Permission Enforcement**:

   - Filter results by user's actual permissions
   - Re-filter on permission changes
   - Never expose routes user shouldn't access

2. **Input Sanitization**:

   - Search query used only for string matching (no eval/execution)
   - No XSS risk from user input

3. **Data Privacy**:
   - Recent searches stored locally only
   - No PII in search index

## Accessibility (a11y)

- ARIA labels for search input and results
- Screen reader announcements for result count
- Keyboard-only navigation fully supported
- Focus trap within modal
- High contrast theme support
- Respects prefers-reduced-motion

**WCAG Compliance**: Targets WCAG 2.1 Level AA

## Backend API Design

### Endpoints

#### GET /api/search/history

Load user's search history for cross-device sync.

**Response**:

```json
{
  "items": [
    {
      "id": "uuid",
      "query": "alunos",
      "itemId": "/students",
      "itemType": "route",
      "timestamp": "2025-11-20T10:30:00Z"
    }
  ]
}
```

#### POST /api/search/history

Record a search event (when user navigates to a result).

**Request**:

```json
{
  "query": "financeiro",
  "itemId": "/finance",
  "itemType": "route"
}
```

#### POST /api/search/analytics

Track search metrics for UX insights.

**Request**:

```json
{
  "query": "alunos",
  "resultCount": 5,
  "selectedItem": "/students",
  "timestamp": "2025-11-20T10:30:00Z"
}
```

**Analytics Tracked**:

- Most searched queries
- Search queries with no results (to improve index)
- Most selected routes/actions
- Average time to selection
- Abandonment rate (searches without selection)

### Database Schema

```sql
-- Search history per user
CREATE TABLE SearchHistory (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    UserId UNIQUEIDENTIFIER NOT NULL,
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Query NVARCHAR(200) NOT NULL,
    ItemId NVARCHAR(500) NOT NULL,
    ItemType NVARCHAR(50) NOT NULL, -- 'route' or 'action'
    Timestamp DATETIME2 NOT NULL,
    INDEX IX_SearchHistory_UserId_Timestamp (UserId, Timestamp DESC)
);

-- Analytics aggregation
CREATE TABLE SearchAnalytics (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    TenantId UNIQUEIDENTIFIER NOT NULL,
    Query NVARCHAR(200) NOT NULL,
    ResultCount INT NOT NULL,
    SelectedItem NVARCHAR(500),
    Timestamp DATETIME2 NOT NULL,
    UserId UNIQUEIDENTIFIER NOT NULL,
    INDEX IX_SearchAnalytics_TenantId_Timestamp (TenantId, Timestamp DESC)
);
```

## Quick Actions Design

### Quick Action Examples

```typescript
const quickActions: QuickAction[] = [
  {
    id: "add-student",
    title: "Adicionar Novo Aluno",
    keywords: ["add", "new", "create", "novo", "criar", "aluno", "student"],
    category: "Ações Rápidas",
    icon: "➕",
    permissions: [PERMISSIONS.STUDENTS_WRITE],
    action: () =>
      router.navigate(["/students"], { queryParams: { action: "add" } }),
    type: "action",
  },
  {
    id: "generate-report",
    title: "Gerar Relatório de Frequência",
    keywords: ["report", "relatório", "attendance", "frequência", "gerar"],
    category: "Ações Rápidas",
    icon: "📊",
    permissions: [PERMISSIONS.REPORTS_READ],
    action: () => openReportDialog("attendance"),
    type: "action",
  },
  {
    id: "send-announcement",
    title: "Enviar Comunicado",
    keywords: ["send", "enviar", "announcement", "comunicado", "notice"],
    category: "Ações Rápidas",
    icon: "📢",
    permissions: [PERMISSIONS.ANNOUNCEMENTS_WRITE],
    action: () => openAnnouncementDialog(),
    type: "action",
  },
];
```

### Action Execution Flow

```text
User selects quick action
      │
      ▼
GlobalSearchComponent.executeAction(action)
      │
      ├──> Close search modal
      ├──> Call action.action() function
      │         └──> Navigate to route with params
      │         └──> Open dialog/modal
      │         └──> Trigger service method
      │
      └──> Record in analytics
```

## Future Enhancements (Post-MVP)

1. **Content Search**: Search within entities (students, notices, etc.) via backend API
2. ~~**Quick Actions**: Execute commands directly ("Add new student", "Generate report")~~ **INCLUDED IN MVP**
3. ~~**Search History Sync**: Store history in backend per user~~ **INCLUDED IN MVP**
4. **Contextual Search**: Filter by current context/route
5. ~~**Search Analytics**: Track popular searches to improve UX~~ **INCLUDED IN MVP**
6. **i18n Support**: Multi-language search keywords (deferred)
7. **Smart Suggestions**: Machine learning-based recommendations

## Implementation Timeline

- **Phase 1 (Core Search + Backend)**: 4-6 days
  - Service + Component + Basic UI + Backend API
- **Phase 2 (Quick Actions + Analytics)**: 3-4 days
  - Quick action framework + Analytics tracking
- **Phase 3 (Polish)**: 2-3 days
  - Keyboard shortcuts + Styling + Performance optimization
- **Testing & Refinement**: 2-3 days

**Total Estimate**: 11-16 days of development work (increased from 6-10 due to backend integration and quick actions)
