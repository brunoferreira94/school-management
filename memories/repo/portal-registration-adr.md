# ADR: Portal Registration Form with ExternalIdentity Integration

## Decision

Implementar formulário standalone Angular 20+ com signal-based forms para registro de responsáveis no portal, integrado com sistema ExternalIdentity agnóstico (Opção B).

## Context

- User migrou de Guardian.Auth0Sub para ExternalIdentity provider-agnostic model
- Portal precisa de fluxo de autoregistro antes do email verification
- Auth0 provisioning feito no backend (PortalService.RegisterAsync)
- Security requirement: fail-closed resolution, sem fallback de email se auth0Sub existe

## Solution

### Frontend (Angular 20+)

- Standalone component: PortalRegisterComponent
- Signal-based reactive forms (FormBuilder + reactive validators)
- Async email validator com debounce 500ms
- Custom validators: passwordComplexity(), passwordMatchValidator()
- States: loading, error, success (redirect com 1s delay)
- UX: password strength meter, toggle visibility, autofocus on errors

### Backend Integration

- POST /api/portal/auth/register { email, password }
- Response: { success, guardianId, auth0Sub, message }
- sessionStorage: auth0Sub + guardianId (temporary, cleared após email verification)
- Redirect: /portal/email-verification?guardianId={id}&sub={sub}

### Security

- Sem armazenamento local de password
- HTTPS obrigatório (via environment)
- JWT via Auth0 SDK
- Rate limiting backend recomendado (5/min/IP)

## Implications

- Formulário disponível em /portal/register (sem guard - público)
- Email async check pode impactar UX se backend lento
- sessionStorage cleared após email verification (segurança)
- Firebase/Auth0 timeout > 30s pode retornar erro genérico

## Testing

- 16 testes unitários (validação, submissão, erros, loading states)
- E2E recomendado (Cypress) para fluxo completo até verification

## Alternatives Rejected

- Template-driven forms: signal-based mais moderno
- localStorage: exposição de auth0Sub
- Imediato redirect sem delay: feedback visual melhor com 1s

## Files Created

- src/app/components/portal/portal-register.component.ts
- src/app/components/portal/portal-register.component.spec.ts
- PortalService: register(), validateEmail() methods added

## Status

✅ IMPLEMENTED - Frontend completo, validação de testes
🔄 PENDING - E2E testing, backend rate limiting

## Verified Notes (2026-05-12)

- Em school-management-ui/package.json, o script e2e:ci:portal-registration executa scripts/run-e2e-services.mjs com npm run e2e:portal-registration e é o caminho mais confiável para validação headless no Windows sem problemas de quoting.
- Em school-management-ui/src/app/components/portal/portal-register.component.ts, o botão de submit do registro deve considerar form.pending além de form.invalid e isLoading para não habilitar envio durante validação assíncrona.
- O async validator de e-mail do portal deve validar o valor atual e completar; usar control.valueChanges dentro do próprio AsyncValidatorFn pode deixar o formulário preso em pending.
- Validação verificada: npm run e2e:ci:portal-registration passou com 6/6 testes.

## Verified Notes (2026-05-12 - Login Security)

- Decisão aplicada no frontend: o login tradicional bloqueia envio de credenciais quando apiBaseUrl resolve para HTTP fora de localhost/loopback (fail-closed para transporte inseguro).
- Implementação principal em school-management-ui/src/app/services/auth.service.ts.
- Cobertura de teste em school-management-ui/src/app/services/auth.service.spec.ts validando o bloqueio e ausência de request HTTP no cenário inseguro.
- Configuração de desenvolvimento atualizada para HTTPS em school-management-ui/src/environments/environment.ts com https://localhost:7046/api.
- Validação executada: npm run test -- --watch=false --browsers=ChromeHeadless passou 281/281.
