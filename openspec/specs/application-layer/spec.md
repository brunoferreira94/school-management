# application-layer Specification

## Purpose
TBD - created by archiving change refactor-application-layer-cqrs. Update Purpose after archive.
## Requirements
### Requirement: CQRS Dispatch via LiteBus

A camada Application SHALL despachar todas as operações de leitura e escrita através de `ICommandMediator` e `IQueryMediator` do LiteBus, eliminando a injeção direta de UseCases concretos em controllers.

#### Scenario: Command despachado com sucesso

- **WHEN** um controller envia um command via `ICommandMediator.SendAsync()`
- **THEN** o handler correspondente é executado e retorna `Result<T>` com sucesso

#### Scenario: Query despachada com sucesso

- **WHEN** um controller envia uma query via `IQueryMediator.QueryAsync()`
- **THEN** o handler correspondente é executado e retorna `Result<T>` com os dados solicitados

#### Scenario: Handler não registrado

- **WHEN** um request é despachado sem handler registrado
- **THEN** o LiteBus retorna erro de resolução de handler antes de atingir qualquer comportamento de negócio

---

### Requirement: Pipeline Behavior de Logging

O sistema SHALL registrar automaticamente cada request de command/query no LiteBus com nome do request, TenantId, duração e resultado (sucesso ou falha).

#### Scenario: Request bem-sucedida

- **WHEN** qualquer request é processada com sucesso pelo pipeline do LiteBus
- **THEN** um log de nível `Information` é emitido com nome do request, TenantId e duração em ms

#### Scenario: Request com falha de negócio

- **WHEN** um handler retorna `Result.Fail()`
- **THEN** um log de nível `Warning` é emitido com o nome do request, TenantId, duração e a mensagem de erro

#### Scenario: Request com exceção não tratada

- **WHEN** um handler lança uma exceção não capturada
- **THEN** um log de nível `Error` é emitido com stack trace antes de propagar a exceção

---

### Requirement: Pipeline Behavior de Validação

O sistema SHALL executar automaticamente todos os `IValidator<TRequest>` registrados do FluentValidation antes de cada handler, retornando `Result.Fail` agregado se houver falhas de validação.

#### Scenario: Request válida

- **WHEN** um request passa por `ValidationBehavior` sem validators registrados ou com validators que não reportam erros
- **THEN** o pipeline prossegue para o próximo behavior/handler sem interrupção

#### Scenario: Request inválida com validator registrado

- **WHEN** um `IValidator<TRequest>` reporta um ou mais erros de validação
- **THEN** o pipeline é interrompido e retorna `Result.Fail` com os erros concatenados, sem executar o handler

#### Scenario: Múltiplos validators registrados

- **WHEN** múltiplos `IValidator<TRequest>` estão registrados para o mesmo request
- **THEN** todos são executados e todos os erros são agregados em um único `Result.Fail`

---

### Requirement: Pipeline Behavior de Métricas

O sistema SHALL registrar automaticamente métricas de execução (duração, sucesso/falha) para cada request LiteBus via `IMetricsService`.

#### Scenario: Command executado com sucesso

- **WHEN** um handler de command é executado com sucesso
- **THEN** uma métrica de duração e um contador de sucesso são registrados com o nome do command como label

#### Scenario: Query executada com falha

- **WHEN** um handler de query retorna `Result.Fail`
- **THEN** um contador de falha é registrado com o nome da query como label

---

### Requirement: Separação Semântica Command/Query

A camada Application SHALL distinguir explicitamente operações que mutam estado (Commands) de operações de leitura (Queries) através de interfaces marcadoras tipadas.

#### Scenario: Command sem retorno de dados

- **WHEN** uma operação de escrita é modelada como `ICommand<Result>`
- **THEN** o handler executa a mutação e retorna apenas o status de sucesso/falha

#### Scenario: Query retorna dados sem side effects

- **WHEN** uma operação de leitura é modelada como `IQuery<Result<T>>`
- **THEN** o handler retorna os dados solicitados sem alterar o estado da aplicação

