# Design — Implementar tela de Serviços

## Modelo de dados sugerido

Service

- id: uuid
- name: string
- code: string
- description: text
- defaultPrice: decimal
- unit: enum (per month, per occurrence)
- recurrence: enum (one-time, monthly, yearly)
- active: boolean
- createdAt, updatedAt

PriceHistory

- id, serviceId, price, startDate, endDate

## API endpoints (exemplos)

- GET /api/services
- POST /api/services
- GET /api/services/{id}
- PUT /api/services/{id}
- DELETE /api/services/{id}
- GET /api/services/{id}/prices

## UI sketches

- Lista com filtros por categoria/ativo
- Form de edição com abas: Geral, Preços, Regras de cobrança

## Notas

- Permissões por role (VIEW/MANAGE)
- Considerar performance em listagens com paginação
