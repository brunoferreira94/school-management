# Design — Implementar Notificações (Lembretes Automáticos)

## Componentes

- Rule Engine: define triggers and schedules
- Template Store: templates per channel
- Delivery Queue: workers and retry policies

## API

- POST /api/notifications/rules
- GET /api/notifications/logs

## Notas

- Considerar GDPR/LGPD: opt-out e registros de consentimento
