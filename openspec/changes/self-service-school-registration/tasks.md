# Tasks — Cadastro self-service de escola

## 1. API — endpoint
- [ ] 1.1 Criar `POST /api/onboarding/register-school` (`[AllowAnonymous]`, rate-limited "PortalRegister")
- [ ] 1.2 DTO: `RegisterSchoolRequest { schoolName, principalName, principalCpf, principalEmail, password }`
- [ ] 1.3 `TenantProvisioningService.RegisterSchoolAsync()` em uma transação:
      - cria `Tenant` (slug suave de schoolName) + `SchoolUnit` default
      - cria `Staff` (principal) com hash de senha e role `Admin`
      - cria `TenantSubscription` no plano Free com `Status = Trial`, `TrialEndsAtUtc = +14 dias`
- [ ] 1.4 Idempotência por CPF: CPF já cadastrado → conflito 409 com mensagem (não vaza dados)

## 2. Seed de plano Free
- [ ] 2.1 Garantir que `SubscriptionPlanSeeder.SeedAsync()` cria um plano `Free` (slug `free`, price 0)

## 3. UI — cadastro
- [ ] 3.1 Feature `onboarding/` com `RegisterSchoolFormComponent` (standalone)
- [ ] 3.2 Rota pública `/cadastro` (sem guarda)
- [ ] 3.3 Form: schoolName, principalName, cpf, email, senha + repetir senha + aceitar termos
- [ ] 3.4 POST `/api/onboarding/register-school`; em 200/201 navega para `/login?registered=1`;
      em 409 mostra erro de e-mail/cpf já usado
- [ ] 3.5 Pricing "Iniciar" / CTA da landing → `/cadastro`

## 4. Testes
- [ ] 4.1 API: `POST /register-school` cria tenant + staff + assinatura trial; idempotente por CPF
- [ ] 4.2 E2E `school-self-service-signup.cy.ts`: signup → tenant trial ativo → login → dashboard

## Ordem de implementação
Seed Free → endpoint API → UI cadastro → CTAs apontando para /cadastro → E2E
