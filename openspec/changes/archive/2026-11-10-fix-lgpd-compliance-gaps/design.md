# Design — fix-lgpd-compliance-gaps

## Context

A compliance review de 2026-10-29 mapeou a superfície de privacidade da plataforma sob a
régua GDPR e, por decisão de produto, o foco inicial é o mercado brasileiro (LGPD). A base
existente já tem consentimento de cookies com registro servidor-side
(`CookieConsentController`), endpoints de direitos do titular
(`DataSubjectRightsController`) e política de retenção parcial
(`AuditLogCleanupService` + config `Retention`). As lacunas estão na completude da
exclusão/export, no bloqueio dos direitos pelo gate de termos de uso, na fragmentação do
consentimento entre dois `localStorage`, na ausência de testes dos endpoints de
privacidade e no conteúdo do aviso de privacidade.

Restrições: produto B2B (a escola é a controladora dos dados de alunos/responsáveis; a
plataforma opera como operadora), multi-tenant, suíte atual verde (755 testes) e change
ativa `add-terms-of-use-acceptance` mexendo no mesmo middleware de termos.

## Goals / Non-Goals

- Goals:
  - Exclusão e export que respondem a um pedido real de titular da LGPD.
  - Direitos do titular acessíveis mesmo com termos pendentes.
  - Consentimento único, servidor-backed e revogável.
  - Retenção documentada e aplicada em todas as categorias.
  - Aviso de privacidade com conteúdo do art. 9º e runbook de incidente do art. 48.
- Non-Goals:
  - Adequação GDPR/UE (transferência internacional, representante na UE, 72h) — change futura.
  - Redação jurídica final (textos são draft até revisão de advogado).
  - Fluxo de DPA B2B e export no cancelamento (já cobertos por outras changes).

## Decisions

- **Semântica da exclusão: anonimização irreversível, não hard delete.**
  Registros acadêmicos pertencem à escola (obrigação legal — art. 16, I), então a
  exclusão do titular remove/anonimiza identificadores diretos e histórico pessoal,
  preservando o que a lei obriga a manter, com entrada em registro de retenção.
  Alternativa considerada: hard delete de tudo — rejeitada por quebrar obrigações
  legais da instituição e integridade acadêmica.
- **CPF do aluno deixa de ser consultável após exclusão.** Hoje `Student.Cpf` sobrevive
  à anonimização, permitindo reidentificação. Decisão: nullar o CPF (e o
  `account.StudentCpf` correspondente) na exclusão. Alternativa: manter hash do CPF
  para deduplicação — só se um caso de uso concreto exigir, registrado no
  registro de retenção.
- **Export em JSON único, mesmo contrato ampliado.** Nada de novo formato/endpoint;
  adicionar categorias ao payload atual preserva compatibilidade e atende portabilidade
  (art. 18, III). Alternativa considerada: geração assíncrona de zip — fora de escopo
  agora, o volume por titular é pequeno.
- **Isenção de caminhos no middleware de termos.** Adicionar
  `/api/privacy/data-subject` à lista de paths ignorados em
  `TermsOfUseEnforcementMiddleware` (mesmo ponto de extensão já usado por
  `cookie-consent` e `terms-of-use`). Alternativa: exigir aceite prévio — viola o
  direito de acesso (art. 18) e foi justamente o achado P0 da review.
- **Consentimento único com servidor como fonte da verdade.** Unificar
  `cookieConsentDecision` (UI + `CookieConsents`) e `portal_analytics_consent`
  (só `localStorage`): o serviço de analytics passa a ler a decisão do
  `CookieConsentService`, eliminando o estado divergente que hoje nunca é escrito
  por componente algum. Alternativa: manter dois stores e sincronizar — mantém a
  classe de bug que motivou a change.
- **Retenção como config + job existente.** Estender a seção `Retention` e o
  `AuditLogCleanupService` em vez de criar infraestrutura nova; cada categoria ganha
  prazo e método de remoção/anonimização.
- **Logs: hash com salt (HMAC) para IP.** Trocar SHA-256 puro de `ip|userAgent` e o
  IP cru do rate-limit por HMAC com salt configurável; volcamento de headers fica
  atrás de ambiente de teste. Alternativa: descartar IP — perde utilidade de
  segurança (rate limit, detecção de intrusão).

## Risks / Trade-offs

- Nullar o CPF pode quebrar fluxos que resolvem aluno por CPF do usuário logado →
  mapear usos de `account.StudentCpf` antes e cobrir com teste.
- Excluir histórico de busca e anonimizar perfis afeta analytics internos → aceito;
  dados agregados de coorte permanecem.
- Isentar caminhos do gate de termos abre endpoints de privacidade sem aceite →
  exigem autenticação JWT, que já é obrigatória.
- Textos do aviso de privacidade sem revisão jurídica → marcar como draft e bloquear
  uso comercial até revisão.

## Migration Plan

1. Backend: erasure/export + isenção no middleware (com testes de integração novos).
2. Frontend: unificação de consentimento + superfície de revogação.
3. Config/retenção: novos prazos + job.
4. Documentos: aviso de privacidade, tabela de retenção, runbook de incidente.
5. Rollback: mudanças são aditivas; a isenção do middleware e o erasure podem ser
   revertidos por deploy anterior sem perda de dados (a exclusão é, por definição,
   irreversível — executar só após aprovação).

## Open Questions

- Quem responde formalmente pelo titular: escola (controladora) ou plataforma? Afeta
  em quem recai o SLA de 15 dias — confirmar com jurídico antes de publicar o prazo.
- Mantém-se hash do CPF para deduplicação de alunos após exclusão? (ver Decisions)
- O registro de retenção por obrigação legal vira tabela no banco ou documento
  operacional? Preferência: documento versionado em `docs/`, com prazos refletidos na
  config `Retention`.
