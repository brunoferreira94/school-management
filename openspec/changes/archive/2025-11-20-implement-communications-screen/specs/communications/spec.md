<!-- markdownlint-disable MD041 -->

## ADDED Requirements

### Requirement: Gerenciamento de templates de comunicação

O sistema SHALL permitir o gerenciamento de templates de comunicação com placeholders dinâmicos.

#### Scenario: Criar template com placeholders

- Usuário acessa o gerenciador de templates, cria um novo template com campos dinâmicos e salva.

### Requirement: Agendamento de envios segmentados

O sistema SHALL possibilitar o agendamento de envios segmentados por grupos/audiências.

#### Scenario: Agendar envio segmentado

- Usuário seleciona um segmento (ex: turma), agenda o envio para data futura e confirma.

### Requirement: Registro e exibição de logs de entrega

O sistema SHALL registrar e exibir logs de entrega por canal (email, SMS, push, in-app).

#### Scenario: Visualizar logs de entrega

- Após envio, usuário acessa logs e visualiza status de entrega por canal para cada destinatário.

### Requirement: Monitoramento de saúde dos provedores

O sistema SHALL monitorar e exibir o status de saúde dos provedores de envio.

#### Scenario: Monitorar saúde dos provedores

- Usuário acessa painel de saúde e visualiza status (online/offline/erro) dos provedores de email, SMS e push.
