# Tasks: fix-lgpd-compliance-gaps

## 1. Backend — direitos do titular

- [ ] 1.1 Ampliar `DELETE /api/privacy/data-subject/me` para remover/anonimizar todos os
      identificadores diretos (CPF do aluno incluso), apagar histórico de busca,
      solicitações pendentes de perfil e refresh tokens (owner: backend).
- [ ] 1.2 Estender `GET /api/privacy/data-subject/me/export` com preferências/opt-out de
      notificações, histórico de consentimentos, aceites de termos, histórico de busca e
      entradas de auditoria do titular (owner: backend).
- [ ] 1.3 Isentar `/api/privacy/data-subject` no `TermsOfUseEnforcementMiddleware` e
      atualizar `docs/middleware/terms-of-use-exceptions.md` (owner: backend).
- [ ] 1.4 Mapear usos de `account.StudentCpf`/`Student.Cpf` antes de passar a nulá-los
      na exclusão (owner: backend).

## 2. Backend — consentimento e retenção

- [ ] 2.1 Manter consentimento como fonte única no servidor e expor decisão no status
      já existente (sem endpoint novo) (owner: backend).
- [ ] 2.2 Estender a seção `Retention` de configuração com: consentimentos, aceites de
      termos, histórico de busca e dados de conta inativa (owner: backend).
- [ ] 2.3 Estender o job diário de limpeza para aplicar os novos prazos, com log do
      resultado (owner: backend).
- [ ] 2.4 Registrar recebimento e resolução de solicitações de titular na trilha de
      auditoria (owner: backend).

## 3. Frontend — consentimento e privacidade

- [ ] 3.1 Unificar consentimento: `PortalAnalyticsService` passa a ler a decisão do
      `CookieConsentService` e removê-lo `portal_analytics_consent` divergente
      (owner: frontend).
- [ ] 3.2 Garantir que aceitar/rejeitar no banner habilita/bloqueia o disparo de
      analytics a partir da mesma decisão (owner: frontend).
- [ ] 3.3 Superfície de revogação de consentimento nas preferências (reabrir banner /
      preferências) com efeito imediato (owner: frontend).
- [ ] 3.4 Atualizar `privacidade.component.*` com as seções do art. 9º: finalidades ×
      bases legais, prazos de retenção, compartilhamento, direitos e como exercê-los
      (owner: frontend/jurídico).

## 4. Segurança e logs

- [ ] 4.1 IP do rate limit e de logs de acesso passam a hash com salt (HMAC) ou
      truncamento (owner: backend).
- [ ] 4.2 Restringir volcamento de headers do `AuditLoggingMiddleware` (`/api/assets`,
      `X-Test-*`) a ambiente de teste (owner: backend).
- [ ] 4.3 Trocar SHA-256 puro de `ip|userAgent` em consentimento e termos por
      hash com salt (owner: backend).

## 5. Documentos legais e operacionais

- [ ] 5.1 Reescrever `docs/privacy-policy.md` com o conteúdo mínimo do art. 9º da LGPD
      (draft até revisão jurídica) (owner: jurídico/documentação).
- [ ] 5.2 Atualizar `docs/lgpd-data-endpoints.md` com o mapeamento completo de
      endpoints com dados pessoais (art. 30) (owner: backend/documentação).
- [ ] 5.3 Criar runbook de incidente de segurança de dados (art. 48) em `docs/` com
      papéis, evidências e checklist de notificação ANPD/titulares ≤48h
      (owner: operações/jurídico).
- [ ] 5.4 Documentar a tabela de retenção completa (novas categorias) na política de
      retenção existente (owner: documentação).

## 6. QA

- [ ] 6.1 Criar `PrivacyIntegrationTests` cobrindo export, correção, exclusão e
      status/aceite de consentimento (owner: qa).
- [ ] 6.2 Teste de exclusão: identificadores diretos removidos, histórico de busca
      apagado, retenção legal registrada (owner: qa).
- [ ] 6.3 Teste de isenção do gate: 428 não ocorre em `/api/privacy/data-subject/*`
      com termos pendentes (owner: qa).
- [ ] 6.4 Teste de consentimento unificado no frontend (Karma) e E2E do banner →
      gating de analytics (owner: qa).
- [ ] 6.5 Suíte completa verde (`dotnet test` + `ng build`) sem regressões
      (owner: qa).

## 7. Validação

- [x] 7.1 `openspec validate fix-lgpd-compliance-gaps --strict` passa.
- [ ] 7.2 Proposta revisada e aprovada pelo dono do produto antes da implementação.
