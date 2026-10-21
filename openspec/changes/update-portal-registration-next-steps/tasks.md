# Tasks — update-portal-registration-next-steps

## Planejamento e alinhamento

- [x] Inventariar dependências de spec: self-service-portal, notifications, communications, automated-onboarding, academic-year. (owner: product)
- [x] Estruturar pacote OpenSpec completo para o roadmap de registro. (owner: product)
- [x] Validar o change via openspec validate --strict. (owner: product) ✅ 2026-10-21 — `npx @fission-ai/openspec validate update-portal-registration-next-steps --strict` → "Change is valid" (corrigidos 2 cenários omitidos no delta MODIFIED de self-service-portal; `validate_openspec.sh` local também corrigido — bug de contagem do `grep -c`)

## Backend

- [x] Implementar rate limiting de 5 tentativas/min por IP no endpoint de registro. (owner: backend) ✅ já em produção — policy `PortalRegister` (5/min/IP) em Program.cs:69-79 aplicada no POST /register [EnableRateLimiting]
- [x] Registrar eventos de 429 e tentativas excedidas em trilha de auditoria. (owner: backend) ✅ commit 57d7fb1 — `RateLimitObservability.OnRejected` loga RequestId/Method/Path/StatusCode/RemoteIp (429 short-circuits antes do AuditLoggingMiddleware)
- [x] Expor métricas de tentativas e bloqueios para observabilidade. (owner: backend) ✅ contador `school_ratelimit_rejections_total{path}` (57d7fb1) — soma com HTTP global do /metrics existente
- [x] Implementar endpoint de reenvio de e-mail de verificação com idempotência básica. (owner: backend) ✅ POST /api/portal/auth/resend-verification (PortalAuthController.cs:112) → ResendPortalVerificationHandler/PortalService.cs:265 via Auth0; reenvio repetido é seguro + rate limit PortalLogin 10/min

## Frontend

- [x] Implementar rota e tela de verificação de e-mail com feedback de sucesso/erro. (owner: frontend) ✅ portal-email-verification.component (.ts/.html/.spec) + rota em portal.routes.ts
- [x] Limpar dados sensíveis de sessionStorage ao concluir o fluxo de verificação. (owner: frontend) ✅ portal-email-verification.component.ts:179-180 remove `checkout_draft` e `checkout_intent`
- [x] Adicionar link de navegação login -> registro com requisitos de acessibilidade. (owner: frontend) ✅ portal-login.component.html:80 — routerLink + [attr.aria-label] + data-cy (fe57ace)
- [x] Adicionar telemetria de eventos de navegação e submissão no fluxo de registro. (owner: frontend) ✅ PortalAnalyticsService injetado; eventos `registration_page_view/submit/success/error` (portal-register.component.ts:447-604)

## Qualidade

- [ ] Criar suíte E2E Cypress cobrindo fluxo positivo e fluxos negativos. (owner: qa)
- [ ] Adicionar testes unitários para link no login e tela de email-verification. (owner: qa)
- [ ] Adicionar testes automatizados de rate limiting no backend. (owner: qa)
- [ ] Validar não regressão de permissões/escopo de responsável no login do portal. (owner: qa)

## Segurança e operação

- [ ] Revisar política de mensagens transacionais vs quiet hours/opt-out. (owner: security)
- [ ] Garantir retenção mínima e mascaramento de dados sensíveis nos logs. (owner: security)
- [ ] Definir alertas de abuso (pico de 429 por IP/tenant). (owner: sre)

## Encerramento

- [ ] Atualizar documentação funcional/técnica do portal com o fluxo final. (owner: docs)
- [ ] Marcar tarefas concluídas após implementação e validação em produção. (owner: product)
