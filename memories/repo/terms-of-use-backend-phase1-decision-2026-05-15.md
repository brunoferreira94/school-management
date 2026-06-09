# Decisão Fase 1: Backend de Termos de Uso

## Decision

Implementar backend de aceite de termos de uso com consulta de status e confirmação explícita de aceite por usuário autenticado, garantindo idempotência e rastreabilidade por tenant.

## Context

- Necessidade de controlar aceite da versão atual dos Termos de Uso por usuário.
- Necessidade de endpoint de leitura para orientar o frontend sobre exibição de modal/tela de aceite.
- Necessidade de endpoint de escrita seguro para registrar aceite sem duplicidade.

## Solution

### Endpoints

- GET /api/privacy/terms-of-use/status
- POST /api/privacy/terms-of-use/accept

### Persistência

- Tabela/entidade: TermsOfUseAcceptances
- Regra de unicidade: (Tenant + Subject) único
- Objetivo: impedir múltiplos registros para o mesmo usuário no mesmo tenant e manter operação de aceite idempotente no nível de domínio/dados.

### Versionamento dos termos

- Fonte da versão atual: configuração Legal:TermsOfUseVersion
- Fallback removido: a configuração passou a ser obrigatória
- Valor definido em appsettings.json, appsettings.Development.json e appsettings.Testing.json: 2026.1

## Consequences

- Frontend consegue decidir com precisão se deve exigir novo aceite.
- Backend mantém um único estado de aceite por usuário/tenant, reduzindo risco de inconsistência.
- Evolução de versão de termos fica centralizada em configuração, sem necessidade de alteração de código para cada troca de versão.

## Validation

- Suite de integração: PrivacyIntegrationTests
- Cobertura expandida para 7/7 testes, incluindo status pendente, aceite, idempotência e reaceite por mudança de versão
- Resultado: 7/7 testes passando

## Fase Atual (2026-05-15)

### Task 2.5 concluída: trilha de auditoria de aceite

- Implementada entidade `TermsOfUseAcceptanceAudit` para rastreabilidade de eventos de aceite.
- Gravação de auditoria adicionada em dois fluxos:
  - aceite inicial
  - reaceite por mudança de versão dos termos
- Suite `PrivacyIntegrationTests` expandida com novos cenários de auditoria.
- Resultado final da suite: **11/11 testes passando**.
- Status consolidado: **tasks backend 2.1 a 2.5 concluídas**.

### Enforcement de aceite (fail-closed)

- Implementado `TermsOfUseEnforcementMiddleware` em modo fail-closed.
- Requisições de usuários autenticados sem aceite vigente retornam HTTP 428 (Precondition Required).

### Allowlist de rotas (exceções de enforcement)

- `/api/auth`
- `/api/privacy/terms-of-use`
- `/api/privacy/cookie-consent`

### Testes

- Suite de integração: `PrivacyIntegrationTests` ampliada para cobrir enforcement e allowlist.
- Resultado atualizado: 11/11 testes passando.

### Migration (delta mínimo)

- Migration `AddTermsOfUseAcceptance` gerada e sanitizada para manter delta mínimo.
- Alterações persistidas somente para:
  - criação da tabela `TermsOfUseAcceptances`
  - criação de índice único para idempotência por tenant/usuário
- Sem alterações colaterais em outros objetos.

### Observação de tooling

- Registrado aviso de versão divergente entre `dotnet-ef` tools e runtime durante o fluxo de migration.
- Não bloqueante para execução neste estágio, mas recomendado alinhar versões para reduzir ruído e risco em próximas migrations.

## Fase Frontend (2026-05-15)

### Tasks 3.1 a 3.4 concluídas

- 3.1: implementado modal de aceite obrigatório no app root, com ação explícita do usuário.
- 3.2: adicionados links de Termo de Uso e Política de Privacidade nas páginas de login e cadastro do portal.
- 3.3: adicionados links legais no rodapé global em áreas pública e autenticada.
- 3.4: implementado reaceite obrigatório quando o backend sinaliza status pendente por nova versão.

### Serviço frontend

- Criado `TermsOfUseService` para centralizar consulta de status, fluxo de aceite e gatilho de reaceite.
- Integração do serviço com o app root para enforcement consistente em primeiro acesso e em mudança de versão.

### Validação frontend

- Suíte frontend executada com sucesso: **293/293 testes passando**.
- Cobertura inclui fluxo de modal de aceite, reaceite por status backend e presença de links legais em login/cadastro/rodapé.

## Fechamento Iteração Frontend da change `add-terms-of-use-acceptance` (2026-05-15)

### Hardening aplicado

- `TermsOfUseService` ajustado para usar URL absoluta baseada em `environment.apiBaseUrl`, evitando dependência implícita de base URL relativa.
- `AppComponent` com comportamento fail-closed quando ocorre erro no endpoint de status em contexto autenticado/rota de portal protegida.
- Modal de termos com mensagem explícita de erro em cenário de falha de leitura de status.
- Links legais reforçados com `rel="noopener noreferrer"`.

### Ajustes de testes

- `AppComponent` spec ampliado para cobrir:
  - fail-open em rota pública;
  - fail-closed em contexto autenticado.
- Matchers ajustados para `jasmine.stringContaining` nos pontos relevantes para eliminar warnings de tipagem.

### Resultado de execução real

- Suíte `school-management-ui`: **295/295 SUCCESS**.

### Referências oficiais utilizadas

- Angular Interceptors: https://angular.dev/guide/http/interceptors
- Angular HttpContext API: https://angular.dev/api/common/http/HttpContext
- Angular Route Guards: https://angular.dev/guide/routing/route-guards
- Angular Testing Guide: https://angular.dev/guide/testing
- MDN `rel=noopener`: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/rel/noopener
- MDN `rel=noreferrer`: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/rel/noreferrer

## References (Microsoft)

- ASP.NET Core Authorization (Authorize): [Authorization in ASP.NET Core](https://learn.microsoft.com/aspnet/core/security/authorization/simple)
- ASP.NET Core Claims-based Authorization: [Claims-based authorization in ASP.NET Core](https://learn.microsoft.com/aspnet/core/security/authorization/claims)
- API design (inclui práticas para idempotência HTTP): [Best practices for RESTful web API design](https://learn.microsoft.com/azure/architecture/best-practices/api-design)
- EF Core modeling: [Entity Framework Core modeling](https://learn.microsoft.com/ef/core/modeling/)
- EF Core migrations: [Migrations Overview - EF Core](https://learn.microsoft.com/ef/core/managing-schemas/migrations/)

## Status

IMPLEMENTED
