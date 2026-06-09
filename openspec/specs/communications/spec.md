# communications Specification

## Purpose
TBD - created by archiving change implement-communications-screen. Update Purpose after archive.
## Requirements
### Requirement: Communication template management

The system SHALL allow users with `MANAGE_COMMUNICATIONS` permission to create, edit, clone, and archive message templates with support for placeholders and channel-specific content (email, SMS, push).

#### Scenario: Save template with placeholders

- **GIVEN** a user edits an email template inserting placeholders like `{{student.name}}`
- **WHEN** they save the template
- **THEN** the system validates placeholder syntax, persists the template version, and makes it available for future sends

### Requirement: Segmented and scheduled sends

The system SHALL provide a send interface that supports audience segmentation by grade, classgroup, tag, or custom filter and SHALL allow scheduling communications for a future datetime with timezone awareness.

#### Scenario: Schedule segmented send

- **GIVEN** a user targets all guardians of grade 9 and schedules delivery for 08:00 next Monday
- **WHEN** they confirm the send
- **THEN** the system enqueues the job with the selected audience and executes it at the scheduled time

### Requirement: Delivery tracking and history

The system SHALL maintain a delivery log for each communication, recording status transitions (queued, sent, delivered, failed), channel metadata, and engagement metrics when available, and SHALL expose the log in a searchable history view.

#### Scenario: Inspect delivery history

- **GIVEN** a campaign was sent yesterday
- **WHEN** the user opens its delivery history
- **THEN** they see per-recipient status, timestamps, failure reasons, and aggregated metrics such as delivery rate

### Requirement: Provider integration health

The system SHALL monitor external provider integrations (SMTP, SMS, push) exposing credential status, quota usage, and recent errors, and SHALL block scheduling when no active provider is available for the chosen channel.

#### Scenario: Block send without provider

- **GIVEN** the SMS provider credentials expired
- **WHEN** a user attempts to schedule an SMS campaign
- **THEN** the system prevents the send, surfaces the provider error, and suggests reconfiguring credentials

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

