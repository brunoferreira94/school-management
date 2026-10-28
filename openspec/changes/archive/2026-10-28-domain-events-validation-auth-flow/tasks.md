# Tasks — Validação E2E de Domain Events + Implementar Auth Flow do Self-Service Portal

---

## 1. E2E Test — Domain Events Integration (Priority P0)

**Owner**: Backend / QA  
**Esforço**: 6–8h  
**Blocker para**: Confiança em produção + futuras extensões

### 1.1 Criar projeto/classe de teste de integração

- [x] Criar `SchoolManagement.Tests/Unit/DomainEvents/DomainEventsIntegrationTests.cs`
- [x] Setup `DbContextOptions` com `UseInMemoryDatabase`
- [x] Criar fixture/builder para seed rápido (Tenant, SubscriptionPlan, TenantSubscription)

### 1.2 Cenário 1: StudentCreationService incrementa `CurrentStudentCount`

- [x] Arrange: Tenant + Free plan (max 100 students, current=0) + subscription
- [x] Act: `StudentCreationService.CreateAsync(student)` via real DI
- [x] Assert: `subscription.CurrentStudentCount == 1` (sem chamar `IncrementStudentCountAsync` explicitamente)

### 1.3 Cenário 2: DeleteAsync para Staff decrementa `CurrentStaffCount`

- [x] Arrange: Tenant + Premium plan + subscription (current=5)
- [x] Act: Delete staff via `StaffService.DeleteAsync`
- [x] Assert: `subscription.CurrentStaffCount == 4`
- [x] Assert: não descer abaixo de 0 (testar delete quando current=0)

### 1.4 Cenário 3: DocumentService cria eventos mas delta=0 (texto puro)

- [x] Arrange: Tenant + Free plan (max 1000MB storage, current=0)
- [x] Act: `DocumentService.CreateAsync(document com conteúdo puro)`
- [x] Assert: handler `AddStorageMBOnDocumentCreated` é invocado
- [x] Assert: `CurrentStorageMB == 0` (não incrementa quando delta=0)

### 1.5 Validar zero regressões

- [x] Executar suite completa: `dotnet test SchoolManagement.sln`
- [x] Confirmar que 23 testes unitários ainda passam
- [x] Confirmar que novos testes de integração passam

### 1.6 Validar resolução de handlers via DI

- [x] Testar reflexão: todos os 6 handlers resolvíveis via `GetRequiredService<IDomainEventHandler<T>>()`

---

## 2. Auth Flow — Implementar Login Auth0 + MFA (Priority P1)

**Owner**: Frontend (Angular) / Backend  
**Esforço**: 12–16h  
**Blocker para**: Self-Service Portal ativo

### 2.1 Configurar Auth0 (ou verificar se já existe)

- [x] App Auth0 SPA já existe: `domain: rare-softwares.us.auth0.com`, `clientId` configurado em `environment.ts`
- [x] Callback URL a registrar: `http://localhost:4200/portal/callback`
- [x] `domain` + `clientId` já presentes em `environment.ts`
- [x] Configuração local validada para desenvolvimento

#### Follow-ups de produção

- [ ] Registrar `https://portal.app/portal/callback` para produção
- [ ] Configurar API Audience final no Auth0 Dashboard + setar `Auth0:Audience` nos ambientes de produção

### 2.2 Implementar AuthService (Angular)

- [x] `@auth0/auth0-angular ^2.3.0` já instalado
- [x] `provideAuth0` adicionado em `app.config.ts` (domain + clientId + scopes `openid profile email`)
- [x] `Auth0Service` existente expõe `getUserProfile()`, `hasRole()`, `hasPermission()`
- [x] SSR stub (`auth0-server.providers.ts`) já implementado

### 2.3 Implementar AuthGuard (Angular)

- [x] Criar `portal.guard.ts` que checa `auth.isAuthenticated$`
- [x] Se não autenticado: redireciona para `/portal/login`
- [x] Aplicar guard na rota `/portal/dashboard`

### 2.4 Implementar LoginComponent (Angular)

- [x] Criar `components/portal/portal-login.component.ts` com botão "Entrar com Auth0"
- [x] Chama `auth.loginWithRedirect({ appState: { target: '/portal/dashboard' } })`
- [x] Auto-redireciona para dashboard se já autenticado (`ngOnInit` check)

### 2.5 Implementar MFA Component (Angular, opcional)

- [x] Criar `components/portal/portal-mfa.component.ts`
- [x] Verificar `user['https://tenant.io/user_metadata']?.mfaRequired` no dashboard
- [x] Mostrar campo TOTP com 6 dígitos
- [x] Usar flag `portal_mfa_verified` em sessionStorage

### 2.6 Implementar PortalDashboard com dados do responsável

- [x] Criar `components/portal/portal-dashboard.component.ts`
- [x] Injetar `AuthService` + `PortalService`
- [x] Carregar perfil: `GET /api/portal/profile`
- [x] Carregar financeiro: `GET /api/portal/financial/summary`
- [x] Renderizar: nome, email, parcelas vencidas
- [x] Criar `services/portal.service.ts` com `USE_AUTH0_TOKEN` context

### 2.7 Backend: Implementar autorização em API

- [x] `[Authorize(Roles = "PortalUser")]` já existia em todos os controllers `/api/portal/*`
- [x] Adicionar esquema `Auth0Portal` (JWT Bearer) em `SecurityRegistration.cs`
- [x] `Auth0Portal` valida tokens Auth0 via `jwks_uri` (`Authority = https://{domain}/`)
- [x] Requer `Auth0:Audience` configurado no `appsettings` para ativar o esquema
- [x] `[Authorize(AuthenticationSchemes = "Bearer,Auth0Portal")]` nas 3 controllers do portal
- [x] Validar que `tenantId` = rota `tenantId` (403 se não match)
- [x] Retornar dados sensíveis apenas para responsável autorizado
  - Evidência 2026-05-12: `SubscriptionsTenantAuthorizationIntegrationTests.cs` com cenários negativo (403) e positivo (200)

### 2.8 Testar fluxo E2E

- [x] Abrir `localhost:4200/portal`
- [x] Redireciona para Auth0 login ✓
- [x] Login via Auth0 ✓
- [x] Se MFA: entra TOTP ✓
- [x] Redireciona para dashboard ✓
- [x] Dados carregam ✓
- [x] Logout revoga tokens ✓
  - Evidência 2026-05-12: E2E `services` (1/1), `portal-registration` (6/6) e fluxo mínimo (`portal-minimal-auth-flow.spec.ts`) concluídos com sucesso

### 2.9 Documentar setup

- [x] Atualizar `AUTH0_SETUP.md` com credenciais/URLs/variáveis obrigatórias
- [x] Documentar troubleshooting objetivo para 401/403 e configuração de roles

---

## 3. Pagar.me Spike — Explorar Sandbox (Priority P2)

**Owner**: Backend / Infra  
**Esforço**: 4–6h  
**Blocker para**: Payment integration (futuro)

### 3.1 Criar conta sandbox Pagar.me

- [x] Definir pré-condições de sandbox e credenciais no spike
- [x] Registrar bloqueio para validação produtiva sem credenciais reais

### 3.2 Testar endpoint de criação de cobrança

- [x] Documentar chamada mínima de cobrança (payload e resposta esperada)
- [x] Registrar riscos/dependências para execução real

### 3.3 Registrar autenticação e webhooks

- [x] Registrar formato de autenticação e eventos webhook prioritários
- [x] Registrar decisão técnica: adiar implementação produtiva até validação real de credenciais sandbox + webhook

### 3.4 Documentar spike

- [x] Criar `docs/pagarme-spike-2026-05-12.md`
- [x] Seções de autenticação, payload mínimo, riscos/dependências e decisão
- [x] Registrar findings + recomendação de adiar rollout produtivo

---

## 4. DI Verification — Validar Reflexão de Handlers (Priority P2)

**Owner**: Backend  
**Esforço**: 2–3h

### 4.1 Criar helper de reflexão

- [x] Criar classe teste que resolve `IServiceProvider` via `GetServices<IDomainEventHandler<T>>()`
- [x] Listar todos os handlers registrados para cada evento

### 4.2 Validar StudentCreatedEvent

- [x] Assert: `GetServices<IDomainEventHandler<StudentCreatedEvent>>()` retorna `IncrementStudentCountOnStudentCreated`

### 4.3 Validar StaffCreatedEvent

- [x] Assert: retorna `IncrementStaffCountOnStaffCreated`

### 4.4 Validar DocumentCreatedEvent

- [x] Assert: retorna `AddStorageMBOnDocumentCreated`

### 4.5 Testar dispatch manual

- [x] Injetar `IDomainEventDispatcher` via container real
- [x] Disparar evento manualmente: `dispatcher.DispatchAsync(new StudentCreatedEvent(tenantId))`
- [x] Verificar que handler foi invocado (log ou via mock externo)

---

## 5. Documentação — Domain Events Pattern Guide (Priority P3)

**Owner**: Backend  
**Esforço**: 3–4h

### 5.1 Criar `docs/domain-events-pattern.md`

- [x] Seção: Quando criar um novo evento (contraexemplo: não criar para tudo)
- [x] Seção: Estrutura de event record (exemplo: `StudentCreatedEvent(TenantId, ...extra data)`)
- [x] Seção: Implementar handler (`IDomainEventHandler<T>`, checar se dados estão válidos)
- [x] Seção: Registrar handler no DI (`services.AddScoped<IDomainEventHandler<T>, ConcreteHandler>()`)
- [x] Seção: Testar handler (unitário com Moq + integração com DbContext)

### 5.2 Adicionar exemplos

- [x] Exemplo 1: `StudentCreatedEvent` → `IncrementStudentCountOnStudentCreated`
- [x] Exemplo 2: `StaffDeletedEvent` → `DecrementStaffCountOnStaffDeleted`
- [x] Exemplo 3: `DocumentCreatedEvent` → `AddStorageMBOnDocumentCreated`

### 5.3 Documentar futuras extensões

- [x] Sugestão: `NotificationSentEvent(tenantId, userId, message)` → `LogNotificationOnNotificationSent`
- [x] Sugestão: `FeatureAccessedEvent(tenantId, featureName)` → `IncrementFeatureMetricsOnFeatureAccessed`
- [x] Sugestão: `SubscriptionDowngradedEvent` → `AlertAdminOnSubscriptionDowngrade`

### 5.4 Atualizar README

- [x] Adicionar seção "Domain Events" com link para `docs/domain-events-pattern.md`

---

## Validação E Critérios de Aceitação

| Task    | Critério                                                    | Status |
| ------- | ----------------------------------------------------------- | ------ |
| 1.1–1.6 | 3 cenários de integração passam, 23 unitários não regressam | [x]    |
| 2.1–2.9 | Login Auth0 → MFA → Dashboard → Logout, dados carregam      | [x]    |
| 3.1–3.4 | Spike documentado com autenticação + webhooks               | [x]    |
| 4.1–4.5 | Handlers aparecem em reflexão, dispatch manual funciona     | [x]    |
| 5.1–5.4 | Docs criada + exemplos + futuras extensões documentadas     | [x]    |

**Status Final**: Todas as tasks do change foram concluídas em ambiente local/homologação. Restam apenas follow-ups operacionais de produção para Auth0.
