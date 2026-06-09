# Design — Implementar Analytics Avançado

## Pipeline sugerido

- Capture eventos (user actions, payments, attendance, grades)
- Stream para um broker (Kafka) e carregar em DW
- Camada de agregação para dashboards

## Dashboards prioritários

- Retenção por coorte
- Inadimplência por período e segmento
- Ocupação de turmas e utilização de salas

## Notas

- Considerar privacidade e anonimização quando necessário
