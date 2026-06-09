# Design — Implementar tela de Comunicações

## Principais conceitos

- Template: subject, body (HTML/text), placeholders
- Segment: query builder (filtros por turma, curso, situação financeira)
- SendJob: payload, scheduledAt, status

## Endpoints sugeridos

- GET /api/communication/templates
- POST /api/communication/send
- GET /api/communication/logs

## UI

- Editor com preview e variáveis
- Builder de segmentação com filtros predefinidos

## Notas

- Escalar envios grandes via filas e workers
- Registrar métricas (open/click) quando aplicável
