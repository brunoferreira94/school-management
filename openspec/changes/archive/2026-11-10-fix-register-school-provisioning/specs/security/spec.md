## ADDED Requirements

### Requirement: Vínculo de tenant no JWT e resolução à prova de spoofing

O sistema SHALL emitir o claim `tenant_id` no JWT de acesso quando a conta possuir vínculo
com um tenant (`UserAccount.TenantId`), e a resolução do tenant da request SHALL antepor
o claim do token autenticado ao header `X-Tenant-Id`. Contas sem vínculo (portal/multi-escola
por design) preserves a ordem de resolução atual (header → claim → default).

#### Scenario: Diretor registrado autentica com claims bound

- **WHEN** um principal provisionado pelo register-school faz login
- **THEN** o JWT contém `tenant_id` do tenant criado e `school_unit_id` da primeira unidade
  ativa desse tenant
- **AND** as requests dele resolvem o tenant pelo claim, mesmo com header `X-Tenant-Id`
  falsificado de outro tenant

#### Scenario: Conta sem binding mantém ordem atual

- **WHEN** uma conta de portal (`StudentCpf`) autentica
- **THEN** o JWT não contém `tenant_id`
- **AND** a resolução de tenant segue header → claim → default (comportamento atual)
