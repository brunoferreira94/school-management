# Design — Implementar tela de Comunicados

## Modelo de dados (sugestão)

Notice

- id, title, body (html), publishedAt, scheduledAt, audience (enum), attachments

## Endpoints

- GET /api/notices
- POST /api/notices
- POST /api/notices/{id}/publish

## UI

- Página pública listando comunicados publicados
- Painel administrativo com filtros e agendamento
