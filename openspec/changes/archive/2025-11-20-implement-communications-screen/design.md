# Design: Communications Screen

## Overview

A tela de comunicações centraliza o envio de mensagens institucionais, permitindo segmentação, agendamento e rastreamento de entregas.

## Core Components

- **Template Manager:** CRUD de templates com placeholders.
- **Segment Manager:** Definição de público-alvo (turmas, grupos, cargos).
- **SendJob Scheduler:** Agendamento de envios e reenvios.
- **Delivery Log:** Visualização de status de entrega por canal.
- **Provider Health Monitor:** Status dos provedores de envio (email, SMS, push).

## Data Flow

1. Usuário cria template e define segmento.
2. Agenda envio (imediato ou futuro).
3. Sistema processa SendJob e distribui para provedores.
4. Logs de entrega são atualizados conforme resposta dos provedores.
5. Monitoramento de saúde exibe status dos canais.

## API Surface

- `GET /communications/templates` — Listar templates
- `POST /communications/templates` — Criar/editar template
- `GET /communications/segments` — Listar segmentos
- `POST /communications/send` — Agendar envio
- `GET /communications/logs` — Consultar logs de entrega
- `GET /communications/providers/health` — Status dos provedores

## Permissions

| Função        | Criar/Editar | Agendar | Visualizar Logs | Monitorar Saúde |
| ------------- | ------------ | ------- | --------------- | --------------- |
| Administrador | Sim          | Sim     | Sim             | Sim             |
| Coordenador   | Sim          | Sim     | Sim             | Sim             |
| Professor     | Não          | Não     | Parcial         | Não             |

## Non-Functional Considerations

- Escalabilidade para alto volume de envios.
- Logs persistentes para auditoria.
- Consentimento e opt-out conforme LGPD.
