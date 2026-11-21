## MODIFIED Requirements

### Requirement: Trial subscription on tenant provisioning

Every provisioned tenant (default seed and self-service signup) SHALL immediately receive a
`Free` subscription with `Status = Trial` and `TrialEndsAtUtc` = now + 14 days. A tenant with no
paid subscription yet SHALL still get `200` from `GET /api/subscriptions/tenant` with that trial.
Provisioning is idempotent: a tenant that already has an `Active`/`Trial` subscription is not
given another one.

#### Scenario: Newly created tenant has a Free trial subscription

- **GIVEN** a tenant was just provisioned (default seed or self-service signup)
- **WHEN** `GET /api/subscriptions/tenant` is called authenticated as that tenant
- **THEN** the response returns a subscription with `Plan = Free` and `Status = Trial`
- **AND** `TrialEndsAtUtc` is set to approximately 14 days in the future

#### Scenario: Existing subscription is not duplicated

- **GIVEN** a tenant already has an active or trial subscription
- **WHEN** the provisioning path runs again (idempotent retry)
- **THEN** no new subscription is created and the existing one is returned unchanged

## ADDED Requirements

### Requirement: Enforcement de trial expirado (entitlement)

O sistema SHALL aplicar o estado da assinatura ao tenant: um trial expirado (`Status = Trial` e
`TrialEndsAtUtc` no passado) sem assinatura `Active` SHALL bloquear operações de escrita e sinalizar
downgrade nas leituras, até que uma assinatura `Active` seja ativada por webhook do gateway. O
enforcement SHALL ser idempotente e auditável.

#### Scenario: Trial expirado bloqueia escrita

- **GIVEN** um tenant com `Status = Trial` e `TrialEndsAtUtc` no passado, sem assinatura `Active`
- **WHEN** o tenant tenta uma operação de escrita (ex.: lançar nota, cadastrar aluno)
- **THEN** a API responde com bloqueio (código dedicado de assinatura expirada)
- **AND** nenhum dado é persistido

#### Scenario: Trial expirado mantém leitura com aviso

- **GIVEN** o mesmo tenant com trial expirado
- **WHEN** o tenant consulta dados (leitura)
- **THEN** a resposta inclui sinalização de downgrade/assinatura inativa
- **AND** os dados legítimos do tenant permanecem acessíveis

#### Scenario: Assinatura ativa restaura acesso

- **GIVEN** o tenant recebe webhook do gateway confirmando pagamento (`Status = Active`)
- **WHEN** o tenant tenta escrever novamente
- **THEN** o acesso é restabelecido integralmente
- **AND** o enforcement idempotente não duplica bloqueios nem auditoria