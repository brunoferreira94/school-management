# Mapeamento LGPD de Endpoints com Dados Pessoais

Este documento mapeia endpoints que coletam, processam ou expõem dados pessoais e os mecanismos de conformidade implementados.

## Endpoints de Consentimento

- POST /api/privacy/cookie-consent/accept
- POST /api/privacy/cookie-consent/reject
- GET /api/privacy/cookie-consent/status

Finalidade: registro e consulta de consentimento para cookies opcionais.

## Endpoints de Direitos do Titular

- GET /api/privacy/data-subject/me/export
- PUT /api/privacy/data-subject/me/correction
- DELETE /api/privacy/data-subject/me

Finalidade: acesso, correção e exclusão/anomização de dados do titular.

## Endpoints Operacionais com Dados Pessoais (exemplos principais)

- /api/students
- /api/staff
- /api/teachers
- /api/guardians
- /api/portal/profile

Observações:
- Endpoints mutáveis são auditados pelo middleware AuditLoggingMiddleware.
- O tráfego em produção usa HTTPS (enforced outside Testing).
- Dados de contas removidas são anonimizados para reduzir retenção indevida.
