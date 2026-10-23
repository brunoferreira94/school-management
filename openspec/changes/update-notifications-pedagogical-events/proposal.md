## Why

Automação por evento é critério #4 dos ERP escolares 2026. O spec `notifications` tem rule engine e multicanal, mas os gatilhos pedagógicos (falta recorrente, ocorrência, boletim publicado) não estão mapeados como eventos automáticos — só a régua financeira (`billing-cadence`) está especkada. Faltam os eventos pedagógicos com leitura registrada e anti-ruído.

## What Changes

- Delta no spec `notifications`: catálogo de eventos pedagógicos automáticos (falta recorrente X faltas, ocorrência registrada, nota abaixo da média, boletim publicado)
- Cada evento: canal preferido (respeita opt-in do change de WhatsApp), segmentação por turma/perfil, leitura registrada
- Regra de anti-ruído: máximo de notificações por responsável por dia (configurável), agrupamento quando múltiplos gatilhos no mesmo dia

## Impact

- Affected specs: notifications (ADDED requirements), integra com billing-cadence e communications
- Affected code: `NotificationRuleEngine` (novos tipos de gatilho), eventos de domínio existentes (Attendance, Occurrence, Grades)
