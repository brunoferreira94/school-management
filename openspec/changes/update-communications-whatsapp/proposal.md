## Why

A pesquisa 2026 aponta WhatsApp como canal oficial de cobrança e comunicação escolar — todos os artigos de tendência o citam, e o comparativo Didatiko mostra que só a referência o tem completo. Nosso spec `communications` tem templates e agendamento mas não tem WhatsApp como canal, e a régua financeira (`billing-cadence`) precisa de um canal multicanal para disparar.

## What Changes

- Delta no spec `communications`: WhatsApp como canal oficial integrado (envio rastreável dentro do sistema, não número avulso)
- Templates com variáveis do aluno/fatura (2ª via PIX em 1 toque na mensagem)
- Eventos pedagógicos e financeiros disparam comunicação com registro de leitura/entrega
- Health check do provedor WhatsApp no monitoramento existente

## Impact

- Affected specs: communications (ADDED requirements), integra com billing-cadence e notifications
- Affected code: `CommunicationService` (novo canal WhatsApp Business API), provider abstraction existente
