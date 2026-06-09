# Design: Domain Events E2E Validation + Auth Flow

---

## 1. Domain Events E2E Validation

### Arquitetura de Teste

```
┌─────────────────────────────────────────────────────┐
│  Integration Test (SchoolManagement.Tests)          │
├─────────────────────────────────────────────────────┤
│ Setup:                                              │
│  • InMemoryDatabase (SchoolContext)                 │
│  • DI container real (não Moq)                      │
│  • Seed: Tenant, SubscriptionPlan, Subscription    │
│                                                      │
│ Act:                                                │
│  • service.CreateAsync(student) via DI             │
│  • StudentCreationService injeta:                   │
│    - StudentRepository                              │
│    - IDomainEventDispatcher ← chave!               │
│    - ITenantContext                                │
│                                                      │
│ Assert:                                             │
│  • subscription.CurrentStudentCount == 1            │
│  • Nenhuma chamada explícita a IncrementAsync      │
│                                                      │
│ Teardown:                                           │
│  • DbContext dispose (cleanup automático)          │
└─────────────────────────────────────────────────────┘
```

### Handler Invocation Flow

```
CreateAsync(student)
  ↓
await _repository.Add(student)  ← EF persiste
  ↓
await _domainEventDispatcher.DispatchAsync(StudentCreatedEvent(tenantId))
  ↓
DomainEventDispatcher.DispatchAsync:
  handlers = container.GetServices<IDomainEventHandler<StudentCreatedEvent>>()
  foreach handler: await handler.HandleAsync(event)
    ↓
    IncrementStudentCountOnStudentCreated.HandleAsync:
      await repository.IncrementStudentCountAsync(tenantId)
        ↓
        subscription.CurrentStudentCount++
        await context.SaveChangesAsync()
  ↓
CreateAsync retorna
```

### Test Scenarios

| Scenario        | Input                                     | Expected                          | Validation             |
| --------------- | ----------------------------------------- | --------------------------------- | ---------------------- |
| Create Student  | Tenant (Free plan, max 100, current=0)    | CurrentStudentCount = 1           | Sem race condition     |
| Delete Staff    | Tenant (current=5) → delete staff         | CurrentStaffCount = 4             | Não descer abaixo de 0 |
| Create Document | Tenant (Free plan, max 1000MB, current=0) | CurrentStorageMB = 0 (texto puro) | Guarda contra delta=0  |

---

## 2. Auth Flow (Auth0 + MFA)

### Fluxo de Login

```
Usuário acessa portal.app:4200/portal
  ↓
Portal redireciona para Auth0 login page
  ↓
Usuário entra (email + password)
  ↓
Auth0 retorna:
  - id_token (JWT com claims: sub, email, user_metadata { tenantId, role, mfaRequired })
  - access_token
  - refresh_token
  ↓
PortalComponent checks: user_metadata.mfaRequired ?
  ↓
  SIM: redireciona para /portal/mfa
      Usuário entra TOTP
      PortalComponent valida via Auth0 rules (optional)
  NÃO: redireciona para /portal/dashboard
  ↓
PortalComponent carrega dados:
  GET /api/portal/responsible/{tenantId}
    Authorization: Bearer {access_token}
  ↓
API backend valida token + TenantId do user_metadata
  ↓
Retorna dados do responsável + filhos
```

### DI + Guards (Angular)

```typescript
// auth.service.ts
export class AuthService {
  constructor(private auth: AuthService) {}

  isAuthenticated$: Observable<boolean> = this.auth.isAuthenticated$;
  user$: Observable<User> = this.auth.user$;

  async getAccessToken(): Promise<string> {
    return this.auth.getAccessTokenSilently();
  }
}

// portal.guard.ts
export const portalGuard = (route, state) => {
  const auth = inject(AuthService);
  return auth.isAuthenticated$ ? true : redirect("/auth/login");
};

// portal.component.ts
export class PortalComponent {
  user$ = this.auth.user$;
  mfaRequired$ = this.user$.pipe(
    map((u) => u["https://tenant.io/user_metadata"]?.mfaRequired ?? false),
  );
}
```

### MFA (TOTP)

```
User metadata in Auth0:
{
  "tenantId": "uuid",
  "role": "responsible|student|admin",
  "mfaRequired": true|false,
  "totp_secret": "JBSWY3DPEHPK3PXP"
}

PortalComponent:
if (mfaRequired) {
  show MfaComponent
  user enters TOTP code
  validate locally (or via Auth0 custom API)
  if valid -> proceed
  else -> show error
}
```

### Backend: Access Control

```csharp
// PortalController.cs
[Authorize]
[HttpGet("api/portal/responsible/{tenantId}")]
public async Task<IActionResult> GetResponsibleData(Guid tenantId)
{
    var userTenantId = User.FindFirst("https://tenant.io/tenant_id")?.Value;
    if (userTenantId != tenantId.ToString())
        return Forbid();  // 403 — cross-tenant access blocked

    // Fetch data for tenantId
    var data = await _portalService.GetResponsibleDataAsync(tenantId);
    return Ok(data);
}
```

---

## 3. Experiment: Domain Events Resilience

**Hipótese**: Se todo handler é testado E2E com DbContext real, então:

- Handlers são invocados corretamente
- Contadores permanecem sincronizados
- Infraestrutura é resiliente para futuras extensões (NotificationSentEvent, FeatureAccessedEvent)

**Validação**: 3 cenários de integração (Student/Staff/Document) + 3 verificações por cenário:

1. Contador antes = 0
2. Ação executada (create/delete)
3. Contador depois = esperado (1, -1, etc.)

**Critério**: 3/3 cenários passam, zero regressões.

---

## 4. Integration Points

- **StudentCreationService** + dispatcher ← já implementado, falta E2E test
- **StaffService** + dispatcher ← já implementado, falta E2E test
- **DocumentService** + DeleteAsync ← já implementado, falta E2E test
- **PortalComponent** ← novo, depende de Auth0 config
- **Auth0 IdP** ← externo, precisa setup

---

## 5. Testing Strategy

### Unit Tests (Existentes, sem mudança)

- 23 testes com Moq
- Validam lógica isolada de handlers

### Integration Tests (Novos)

- 3 cenários (Student/Staff/Document)
- DbContext real + DI real
- Validam padrão E2E

### E2E Tests (Futuro, não escopo)

- Login via Auth0 em browser real
- Verificar UI + API junto
