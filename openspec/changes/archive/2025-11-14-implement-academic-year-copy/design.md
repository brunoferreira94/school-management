# Design — Implementar Cópia de Ano Letivo Completo

## Estratégia

- Operação idempotente com transaction scope e checkpoints.
- Dry-run que cria um relatório de ações sem persistir alterações.
- Mapeamentos configuráveis para IDs e relacionamentos.

## Endpoints

- POST /api/admin/copy-academic-year (body: fromYearId, toYearId, options)

## Notas

- Pode ser uma operação custosa; considerar execução assíncrona (job queue).
