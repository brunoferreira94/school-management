# Proposta: corrigir lacunas de conformidade LGPD

Autor: _a definir_
Data: 2026-10-29
Status: draft

## Por que

A compliance review de 2026-10-29 (foco inicial: mercado brasileiro, LGPD — Lei 13.709/2018) encontrou lacunas P0/P1 na base já existente de privacidade: a exclusão de dados do titular não remove identificadores diretos (o CPF permanece), os endpoints de direitos do titular não têm cobertura de teste e são bloqueados pelo gate de aceite de termos (428), o export é incompleto para efeito de portabilidade, o consentimento está fragmentado em dois stores locais e a política de retenção não cobre consentimentos e aceites. Sem corrigir isso, a plataforma não consegue responder a um pedido real de titular nem demonstrar conformidade em auditoria B2B.

## O que muda

- **Erasure completo** em `DELETE /api/privacy/data-subject/me`: remove/anonimiza todo identificador direto (CPF, nome, contato, endereço, e-mail, telefone) em account, student, guardian e staff, apaga histórico pessoal (busca, solicitações pendentes, refresh tokens) e preserva apenas dados com base legal registrada em um registro de retenção.
- **Export completo** em `GET /api/privacy/data-subject/me/export`: inclui perfis, preferências/opt-out de notificações, histórico de consentimento de cookies, aceites de termos, histórico de busca e entradas de auditoria que referenciam o titular, em JSON (portabilidade — art. 18, III).
- **Exercício de direitos isento do gate de termos**: `/api/privacy/data-subject/*` passa a ser ignorado pelo `TermsOfUseEnforcementMiddleware` (hoje responde 428 para quem tem termos pendentes).
- **Consentimento unificado e revogável**: decisão única por titular, gravada no servidor, compartilhada pelo banner de cookies e pelo gating de analytics; revogação disponível em superfície de preferências.
- **Política de retenção aplicada**: tabela de prazos cobre também consentimentos, aceites de termos, histórico de busca e dados de conta inativa, com job diário de limpeza.
- **Aviso de privacidade com conteúdo mínimo do art. 9º** da LGPD (controlador, encarregado, finalidades × bases legais, prazos, compartilhamento, direitos e como exercê-los) na UI e em `docs/privacy-policy.md`.
- **Runbook de incidente (art. 48)**: fluxo de notificação à ANPD e aos titulares em até 48h do conhecimento, com papéis e evidências.
- **Minimização de dados em logs**: IP/user-agent em logs de rate limit e acesso armazenados apenas como hash com salt ou truncamento; depuração de headers restrita a ambiente de teste.

## Escopo

- Backend (controllers de privacidade, middleware de termos, job de retenção, config `Retention`).
- Frontend (banner/preferências de consentimento, gating de analytics, página de privacidade).
- Documentos legais e operacionais (`docs/privacy-policy.md`, novo runbook de incidente, tabela de retenção).
- Testes de integração dos endpoints de privacidade (hoje inexistentes).

## Fora de escopo

- Adequação GDPR/UE (transferência internacional, representante na UE, notificação em 72h) — change futura quando houver titulares na UE.
- Redação jurídica final pelos advogados do cliente (os textos são draft até revisão jurídica).
- Alteração do fluxo comercial de DPA B2B (`finalize-public-launch-readiness`).

## Impacto

- Specs afetadas: `data-compliance` (nova capability), `security` (novo requisito de minimização em logs).
- Código afetado: `DataSubjectRightsController.cs`, `TermsOfUseEnforcementMiddleware.cs`, `AuditLoggingMiddleware.cs`, `RateLimitObservability.cs`, `AuditLogCleanupService`/config `Retention`, `cookie-consent.service.ts` + banner, `portal-analytics.service.ts`, `privacidade.component.*`, `docs/privacy-policy.md`.
- Dependências: change ativa `add-terms-of-use-acceptance` (mesmo middleware de termos) — coordenar a isenção de caminhos.

## Critérios de aceite

- Requisitos novos testáveis em `data-compliance` e `security`, com cenários por requisito.
- Tarefas verificáveis cobrindo backend, frontend, documentação e QA.
- Change valida em modo estrito: `openspec validate fix-lgpd-compliance-gaps --strict`.
