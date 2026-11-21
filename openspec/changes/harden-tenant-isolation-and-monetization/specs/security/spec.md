## ADDED Requirements

### Requirement: Query filter global de tenant nas entidades acadêmicas

O sistema SHALL aplicar um filtro global de tenant (`HasQueryFilter`) às entidades `ClassGroup`,
`StudentClass`, `Classroom` e `ClassSchedule` gerenciadas pelo `AcademicContext`, de modo que
nenhuma consulta retorne registros de outro tenant, independentemente de filtros manuais no
repositório. O filtro de `ClassGroup` SHALL ser por `TenantId` (não por `SchoolUnitId != null`).

#### Scenario: Consulta de turmas não retorna turma de outro tenant

- **WHEN** uma consulta do `AcademicContext` busca `ClassGroup` no tenant A
- **THEN** a resposta não contém nenhuma turma do tenant B
- **AND** o isolamento decorre do query filter, não de um `.Where` no repositório

#### Scenario: Matrícula aluno-turma respeita tenant

- **WHEN** uma consulta busca `StudentClass` para o tenant A
- **THEN** apenas vínculos cujo `TenantId` é o tenant A são retornados

### Requirement: Isolamento fail-closed sem tenant padrão em rotas autenticadas

O sistema SHALL rejeitar (400/401) requisições autenticadas a rotas `/api` quando o tenant não
puder ser resolvido, em vez de assumir `TenantConstants.DefaultTenantId`. O uso de `DefaultTenantId`
SHALL ser restrito a seed, migration e design-time, nunca ao processamento de requisições.

#### Scenario: Requisição sem tenant é rejeitada

- **WHEN** uma requisição autenticada a `/api/**` não resolve tenant (sem claim, sem header válido)
- **THEN** a API responde 400/401 com erro explícito
- **AND** nenhum dado do tenant padrão é lido ou escrito

#### Scenario: Seed usa tenant padrão

- **WHEN** o processo de seed/migration precisa de um tenant alvo
- **THEN** `DefaultTenantId` pode ser usado
- **AND** esse caminho não é alcançável por requisição HTTP