# Launch Readiness Evidence — School Management

Data base: 2026-06-20

## Positive evidence

- Owner Dashboard validado via API/UI com usuário Owner autorizado.
- Relatórios críticos funcionam:
  - API `200 OK`;
  - componente UI gera relatório com `series.length = 2`.
- Frontend build/lint passaram localmente.
- OpenSpec change `finalize-public-launch-readiness` validada.
- Portal routes carregam:
  - `/portal/login` (200);
  - `/portal/register` (200);
  - `/portal/dashboard` (redireciona para login - guard funciona);
  - `/termos` (200);
  - `/privacidade` (200).

## Negative evidence

- CI usa `.NET 8.0.x`, mas o projeto está em `net10.0`.
  - ✅ Corrigido: `.github/workflows/ci-cd.yml` atualizado para `DOTNET_VERSION: 10.0.x`
- i18n não aplicado no dev: labels aparecem como keys (`PORTAL.LOGIN.TITLE`).
- MFA stub: `/portal/mfa` sem backend real (decisão: Auth0 toma precedência).
- PrivacyIntegrationTests: 2 testes falhando por race condition na DB compartilhada.
  - ✅ Corrigido: `ResetDbHostedService` usa reflection para acessar `_sharedConnection` estática
  - ✅ Corrigido: `Integration/CustomWebApplicationFactory.ConfigureClient` adiciona `X-User` header
  - ✅ Corrigido: `TermsOfUseEnforcementMiddleware` ignora `/api/subscriptions/webhooks`
  - Status: 18/18 testes passando (PrivacyIntegrationTests + TeacherAvailabilityIntegrationTests + AsaasWebhookIntegrationTests)

## Release decision

- **Não abrir cadastro público amplo agora.**
- Manter como piloto fechado até zerar P0.
- Revisar scorecard semanalmente.
