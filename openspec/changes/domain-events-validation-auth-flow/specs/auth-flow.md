# Spec: Auth0 SSO + MFA para Self-Service Portal

**Status**: active  
**Version**: 1.0

---

## Overview

Implementar fluxo de autenticação (Auth0 SSO) e autorização (MFA opcional) para permitir que responsáveis e alunos acessem dados sensíveis no Self-Service Portal.

---

## Requisitos Funcionais

### RF1: Login via Auth0

**Given** um usuário navega para `portal.app/portal`  
**When** clica em "Login com Auth0"  
**THEN** redireciona para Auth0 login page  
**AND** após login bem-sucedido, redireciona para `/portal/callback`  
**AND** Angular captura JWT (`id_token`, `access_token`)  
**AND** redireciona para `/portal/dashboard`

### RF2: Extrair e validar claims do JWT

**Given** um JWT é obtido após login  
**WHEN** Angular decodifica o token  
**THEN** extrai: `sub` (user id), `email`, `https://tenant.io/tenant_id`, `https://tenant.io/user_metadata` (role, mfaRequired, totp_secret)

### RF3: MFA via TOTP (opcional)

**Given** um usuário com `mfaRequired = true`  
**WHEN** redireciona para `/portal/dashboard`  
**THEN** MfaComponent intercepta e mostra tela de TOTP  
**AND** usuário entra código TOTP (time-based OTP)  
**AND** valida localmente com base em `totp_secret` armazenado em Auth0 metadata  
**AND** se válido, continua para dashboard; se inválido, mostra erro

### RF4: Rotas protegidas por guard

**Given** uma rota `/portal/*` está protegida por `portalGuard`  
**WHEN** usuário não autenticado tenta acessar  
**THEN** redireciona para `/auth/login`  
**WHEN** usuário autenticado acessa  
**THEN** permite navegação

### RF5: Logout com revogação de token

**Given** um usuário autenticado clica em "Logout"  
**WHEN** `auth.logout()` é chamado  
**THEN** limpa JWT local (localStorage/sessionStorage)  
**AND** revoga refresh_token em Auth0 (fetch `POST /oauth/revoke`)  
**AND** redireciona para `/auth/login`

### RF6: Backend valida autorização

**Given** uma requisição para `GET /api/portal/responsible/{tenantId}`  
**WHEN** o endpoint valida `Authorization: Bearer {access_token}`  
**THEN** extrai `tenantId` do JWT payload (`user['https://tenant.io/tenant_id']`)  
**AND** compara com rota `tenantId`  
**AND** se não match, retorna 403 Forbidden  
**AND** se match, retorna dados do responsável

### RF7: Portal carrega dados do responsável

**Given** um responsável autenticado acessa `/portal/dashboard`  
**WHEN** PortalComponent `ngOnInit` dispara `PortalService.GetResponsibleData(tenantId)`  
**THEN** backend retorna: nome responsável, list de filhos, boletos vencidos, notas recentes  
**AND** UI renderiza com as informações

---

## Requisitos Não-Funcionais

### RNF1: Segurança

- Tokens JWT são validados via `jwks_uri` do Auth0
- Refresh token é armazenado apenas em memória (não localStorage para XSS mitigation)
- CORS configurado apenas para domínios autorizados

### RNF2: Performance

- Login completo (redirect → Auth0 → callback) < 3 segundos
- Dashboard carrega dados em < 2 segundos

### RNF3: Resiliência

- Se Auth0 está down, mostrar erro descritivo (não falha silenciosa)
- Refresh token automático via `getAccessTokenSilently()`

---

## Test Scenarios

| Scenario        | Input                              | Expected                             | Validation                               |
| --------------- | ---------------------------------- | ------------------------------------ | ---------------------------------------- |
| Login Flow      | Usuário clica "Login"              | Redireciona Auth0, retorna com token | JWT decodificado contém claims esperados |
| MFA Check       | User com `mfaRequired=true`        | MfaComponent intercepta              | Mostra input TOTP, valida código         |
| MFA Skip        | User com `mfaRequired=false`       | Vai direto pro dashboard             | Sem tela TOTP                            |
| Guard Rejection | Anônimo tenta `/portal/dashboard`  | Redireciona `/auth/login`            | `isAuthenticated$` retorna false         |
| Logout          | Usuário autenticado clica "Logout" | Limpa token, revoga refresh          | Redireciona `/auth/login`                |
| Backend Auth    | Request com token inválido         | 401 Unauthorized                     | Bearer token ausente ou expirado         |
| Backend Authz   | User A tenta acessar dados User B  | 403 Forbidden                        | `tenantId` do JWT ≠ rota `tenantId`      |
| Data Load       | Dashboard autenticado              | Carrega dados                        | Mostra responsável, filhos, boletos      |

---

## Auth0 Configuration

### Application Settings

```
Application Type: Single Page Application (SPA)
Allowed Callback URLs: http://localhost:4200/auth/callback,
                       https://portal.app/auth/callback
Allowed Logout URLs: http://localhost:4200,
                     https://portal.app
Allowed Web Origins: http://localhost:4200,
                     https://portal.app
```

### Auth Rules (Custom Logic)

```javascript
// Rule: Add custom claims to token
function addCustomClaims(user, context, callback) {
  var namespace = "https://tenant.io/";

  context.idToken[namespace + "tenant_id"] = user.user_metadata?.tenant_id;
  context.idToken[namespace + "user_metadata"] = user.user_metadata;

  callback(null, user, context);
}
```

### User Metadata Structure

```json
{
  "tenant_id": "uuid-of-tenant",
  "role": "responsible|student|admin",
  "mfaRequired": true,
  "totp_secret": "JBSWY3DPEHPK3PXP"
}
```

---

## Implementation

### Angular: AuthService

```typescript
import { Injectable } from "@angular/core";
import { Auth0Client } from "@auth0/auth0-spa-js";
import { BehaviorSubject, Observable } from "rxjs";

@Injectable({ providedIn: "root" })
export class AuthService {
  private auth0Client?: Auth0Client;
  private isAuthenticated$ = new BehaviorSubject(false);
  private user$ = new BehaviorSubject<any>(null);

  constructor() {
    this.initializeAuth0();
  }

  private async initializeAuth0() {
    this.auth0Client = new Auth0Client({
      domain: "your-tenant.auth0.com",
      clientId: "your-client-id",
      authorizationParams: {
        redirect_uri: window.location.origin + "/auth/callback",
        scope: "openid profile email https://tenant.io/user_metadata",
      },
    });

    const isAuth = await this.auth0Client.isAuthenticated();
    this.isAuthenticated$.next(isAuth);

    if (isAuth) {
      const user = await this.auth0Client.getUser();
      this.user$.next(user);
    }
  }

  async login() {
    await this.auth0Client?.loginWithRedirect();
  }

  async logout() {
    await this.auth0Client?.logout({
      logoutParams: { returnTo: window.location.origin },
    });
  }

  async getAccessToken(): Promise<string> {
    return this.auth0Client?.getTokenSilently() ?? "";
  }

  get isAuthenticated(): Observable<boolean> {
    return this.isAuthenticated$.asObservable();
  }

  get user(): Observable<any> {
    return this.user$.asObservable();
  }
}
```

### Angular: PortalGuard

```typescript
import { Injectable } from "@angular/core";
import { CanActivate, Router } from "@angular/router";
import { AuthService } from "./auth.service";
import { firstValueFrom } from "rxjs";

@Injectable({ providedIn: "root" })
export class PortalGuard implements CanActivate {
  constructor(
    private auth: AuthService,
    private router: Router,
  ) {}

  async canActivate(): Promise<boolean> {
    const isAuth = await firstValueFrom(this.auth.isAuthenticated);
    if (!isAuth) {
      this.router.navigate(["/auth/login"]);
      return false;
    }
    return true;
  }
}
```

### Angular: PortalComponent

```typescript
@Component({
  selector: "app-portal",
  template: `
    <div *ngIf="user$ | async as user">
      <h1>Minha Área — {{ user.name }}</h1>

      <div *ngIf="mfaRequired$ | async">
        <app-mfa></app-mfa>
      </div>

      <div *ngIf="!(mfaRequired$ | async) && (data$ | async) as data">
        <h2>Filhos</h2>
        <div *ngFor="let child of data.children">{{ child.name }}</div>

        <h2>Boletos Vencidos</h2>
        <div *ngFor="let bill of data.overdueBills">
          {{ bill.description }}: R$ {{ bill.amount }}
        </div>
      </div>
    </div>
  `,
})
export class PortalComponent implements OnInit {
  user$ = this.auth.user;
  mfaRequired$ = this.user$.pipe(
    map((u) => u?.["https://tenant.io/user_metadata"]?.mfaRequired ?? false),
  );
  data$: Observable<any>;

  constructor(
    private auth: AuthService,
    private portalService: PortalService,
  ) {}

  ngOnInit() {
    this.data$ = this.user$.pipe(
      switchMap((u) => {
        const tenantId = u?.["https://tenant.io/tenant_id"];
        return this.portalService.getResponsibleData(tenantId);
      }),
    );
  }
}
```

### ASP.NET Core: PortalController

```csharp
[ApiController]
[Route("api/portal")]
[Authorize]
public class PortalController : ControllerBase
{
    private readonly IPortalService _portalService;

    [HttpGet("responsible/{tenantId}")]
    public async Task<IActionResult> GetResponsibleData(Guid tenantId)
    {
        var userTenantId = User.FindFirst("https://tenant.io/tenant_id")?.Value;
        if (!Guid.TryParse(userTenantId, out var userTenant) || userTenant != tenantId)
            return Forbid();

        var data = await _portalService.GetResponsibleDataAsync(tenantId);
        return Ok(data);
    }
}
```

---

## Exit Criteria

- ✅ Login Auth0 completo em < 3 segundos
- ✅ MFA funciona para usuários com `mfaRequired=true`
- ✅ Guard bloqueia anônimos, permite autenticados
- ✅ Backend retorna 403 para cross-tenant access
- ✅ Portal carrega dados em < 2 segundos
- ✅ Logout revoga refresh token
- ✅ E2E test (login → dashboard → logout) passa
