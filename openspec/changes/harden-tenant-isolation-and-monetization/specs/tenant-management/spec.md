## ADDED Requirements

### Requirement: Fail-closed na resolução de tenant do SaaS

A resolução de tenant para requisições autenticadas SHALL ser fail-closed: quando `Tenant:FailClosed`
está habilitado (staging/produção) e o tenant não é resolvível, a requisição SHALL ser rejeitada
com erro explícito, sem fallback para um tenant padrão. O valor `DefaultTenantId` SHALL existir
apenas para seed/migration/design-time.

#### Scenario: Tenant não resolvido em produção

- **WHEN** uma requisição autenticada não resolve tenant em produção
- **THEN** a API responde erro explícito
- **AND** nenhuma operação ocorre no tenant padrão

#### Scenario: Portal multi-escola continua resolvendo por header

- **WHEN** uma conta de portal sem `tenant_id` no JWT envia `X-Tenant-Id` válido
- **THEN** o tenant é resolvido pelo header
- **AND** a requisição não é rejeitada por ausência de contexto