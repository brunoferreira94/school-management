# Especificação: Contrato de Sincronização Offline

## Purpose

Este contrato defina um mecanismo robusto de sincronização offline para o sistema de gestão escolar, permitindo que clientes (especialmente dispositivos móveis em ambientes de rede instável) façam upload de dados quando offline e sincronizem quando a conexão é restaurada, com garantias de idempotência, detecção de conflitos e consistência de versão.

## ADDED Requirements

### Requirement: Idempotency-Globale (F0)

The system SHALL provide global idempotency for critical operations.

#### Scenario: Client repeats same operation via Idempotency-Key
- **WHEN** a client is offline and just completed an operation
- **AND** the client syncs with `Idempotency-Key: abc123`
- **WHEN** the same client attempts to sync again with `Idempotency-Key: abc123`
- **THEN** the server responds with `422 Unprocessable Entity`
- **AND** the body contains `type: "https://school-management.example.com/errors/idempotency-key-reused"`
- **AND** no additional database changes occur

#### Scenario: Each new operation generates unique key
- **GIVEN** that the client generates a new operation
- **WHEN** the client includes `Idempotency-Key` with a unique UUID
- **THEN** the server processes the operation normally
- **AND** stores the result in cache for 24 hours

### Requirement: Optimistic Revision with ETag (F1)

The system SHALL use optimistic revision for conflict detection.

#### Scenario: Update succeeds with valid ETag
- **GIVEN** that a resource exists with `ETag: "3-1.0.0-abc123"`
- **WHEN** the client sends `If-Match: "4-1.0.0-def456"` (updated revision)
- **THEN** the server accepts the update
- **AND** returns `200 OK` with a new `ETag`

#### Scenario: Revision conflict detected
- **GIVEN** that the resource was modified by another client
- **AND** my ETag is stale (revision 3)
- **WHEN** I send `If-Match` with old ETag (revision 3)
- **THEN** the server responds with `412 Precondition Failed`
- **AND** the body contains `"currentRevision": 4`

#### Scenario: Concurrent updates with the same ETag — only one applies
- **GIVEN** that two clients read the same revision of a resource (same ETag)
- **WHEN** both send a mutation with that `If-Match` concurrently
- **THEN** exactly one mutation is applied
- **AND** the other responds with `412 Precondition Failed`
- **AND** the revision reservation is atomic (no lost update)

#### Scenario: Failed write does not consume the revision
- **GIVEN** that a client sent a mutation with a valid `If-Match`
- **WHEN** the endpoint fails (4xx/5xx) and nothing is applied
- **THEN** the revision returns to its previous value
- **AND** the client can retry with the **same** `If-Match` and succeed

#### Scenario: Enforcement scoped to the paths the client protects
- **GIVEN** that the revision enforcement is enabled for the patterns `PUT /api/grades/{id}` and `PUT /api/grading-formulas/{id}`
- **WHEN** a client sends `PUT /api/grades/42` without `If-Match`
- **THEN** the server responds with `428 Precondition Required`
- **WHEN** the same client creates a grade (`POST /api/grades`) or updates a formula outside the pattern
- **THEN** the server processes the request normally (no ETag exists for those operations)

#### Scenario: Revision adherence measured per resource
- **GIVEN** that a client mutates a resource in scope
- **WHEN** the request carries a specific `If-Match`
- **THEN** the server records the adherence counter for the normalized route with state `provided`
- **WHEN** the request carries `If-Match: *` or no `If-Match` at all
- **THEN** the server records the same counter with state `wildcard` or `missing` respectively
- **AND** the route label never contains a raw resource identifier (cardinality is bounded)

### Requirement: Batch Sync (F2)

The system SHALL support batching multiple operations for synchronous sync.

#### Scenario: Batch with mixed operations
- **GIVEN** that the client has 5 pending operations
- **WHEN** the client sends `POST /api/offline/sync-batch` with all operations
- **THEN** the server responds with `200 OK`
- **AND** the body contains a unique `batchId`
- **AND** the `outcomes` array contains 5 elements
- **AND** at least 3 are `applied` (operations processed)
- **AND** at least 1 is `unchanged` (no changes needed)

#### Scenario: Operation rejected in batch
- **GIVEN** that an operation in the batch violates validation
- **WHEN** the batch is processed
- **THEN** the outcome is `rejected`
- **AND** the body contains `errors: ["CPF is invalid"]`

### Requirement: X-Server-Time (F3)

The system SHALL provide server timestamp for clock synchronization.

#### Scenario: Client synchronizes clock
- **GIVEN** that the client makes any request
- **WHEN** the response includes `X-Server-Time: 1763215200`
- **THEN** the client calculates its clock offset
- **AND** adjusts Idempotency-Key TTL if necessary

#### Scenario: Health check includes server time
- **WHEN** the client calls `GET /api/support/health`
- **THEN** the response body contains `serverTimeUtc: 1763215200`

### Requirement: Metrics and LGPD Compliance (F4)

The system SHALL collect sync metrics without exposing PII.

#### Scenario: Metrics are exported
- **GIVEN** that sync operations are occurring
- **WHEN** Prometheus scrapes metrics
- **THEN** `offline_sync_total` increments
- **AND** `offline_sync_success` increments only for successes
- **AND** `offline_sync_conflicts` increments for conflicts

#### Scenario: Logs do not contain PII
- **GIVEN** that sync completed successfully
- **WHEN** the log is created
- **THEN** the log contains only `tenantId`, `batchId`, `operationType`
- **AND** does not contain CPF, names, or other sensitive data

#### Scenario: Adherence metrics are queryable by resource
- **GIVEN** that the metrics pipeline is configured (OTLP endpoint pointing to the collector)
- **WHEN** Prometheus queries the adherence counters
- **THEN** the revision adherence series is named `revision_adherence` (instrument name translated to underscore, without a `_total` suffix)
- **AND** the series carries the normalized `route` and the `state` (`provided` | `wildcard` | `missing`) labels
- **AND** the key adherence series are named `idempotency_key_missing` and `idempotency_key_provided`

#### Scenario: Metric naming drift is caught before the rollout
- **GIVEN** that an alerting rule references a metric name
- **WHEN** the rule is validated against the exported metric names
- **THEN** the validation fails if the name does not exist in the OTLP pipeline
- **AND** the validation fails if an OTLP metric is referenced with a `_total` suffix

#### Scenario: Adherence metrics reach the production Prometheus
- **GIVEN** that the API runs without an OTLP collector (production topology)
- **WHEN** Prometheus scrapes `GET /metrics` of the API
- **THEN** the response contains the adherence series `revision_adherence` with the normalized `route` and `state` labels
- **AND** the response contains the idempotency series (`idempotency_key_missing`, `idempotency_key_provided`)
- **AND** the response keeps the analytics gauges and the prometheus-net registry in the same scrape
- **AND** the HTTP request metric label `route` never contains a raw resource identifier