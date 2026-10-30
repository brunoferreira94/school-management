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

- POST /api/portal/register — dados de responsáveis/alunos (validação: captcha)
- POST /api/portal/login — e-mail/CPF + senha (refresh token, IP pseudonimizado)
- GET /api/portal/profile — dados do responsável e vínculos
- GET /api/students*, /api/staff*, /api/guardians*, /api/teachers* — dados acadêmicos (acesso por permissão)
- POST /api/onboarding/register-school — dados do diretor controlador institucional
- POST /api/portal/profile/change-request — solicitações de retificação (auditáveis)

### Observações de conformidade (art. 30 — registro de atividades)

- Endpoints mutáveis são auditados pelo **AuditLoggingMiddleware** (RequestId, user,
  method, path, status, duração, tenant — headers de teste só em ambiente de teste);
- O tráfego em produção usa **HTTPS** (enforced fora de Testing);
- **IP de acesso e de rate-limit** são hash com salt via HMAC (`Privacy:IpHashSalt`) —
  nenhum IP cru é persistido nem logado;
- Dados de contas removidas são **anonimizados irreversivelmente** (pseudônimo da PK
  CPF em todas as tabelas dependentes dentro da mesma transação — migration
  `MakeStudentCpfFksDeferrable` + `DataSubjectErasureService` + job de retenção ativo);
- **Job diário de retenção** remove/anonimiza categorias vencidas (log de auditoria
  90d, consentimentos/aceites 5a, histórico de busca 30d, contas inativas 365d);
