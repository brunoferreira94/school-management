## ADDED Requirements

### Requirement: Provisioned director role

O registro de escola SHALL provisionar o principal com a role global "Director" (via
`StaffRole`) vinculando a conta ao tenant criado, de forma que o primeiro login já
carregue as permissões da role e o diretor consiga operar a escola imediatamente.

#### Scenario: Registro cria diretor operacional

- **WHEN** o formulário público de registro de escola é concluído
- **THEN** a conta do principal recebe o vínculo `StaffRole` ↔ role "Director"
- **AND** `UserAccount.TenantId` fica definido com o tenant criado
- **AND** o primeiro login dessa conta retorna `roles` contendo "Director"
  e `permissions` não vazias

#### Scenario: Registro idempotente quanto a role

- **WHEN** o mesmo principal é provisionado apenas uma vez por registro
- **THEN** re-edição/re-run do fluxo não duplica vínculos (`StaffRole` único por
  Staff↔Role)
