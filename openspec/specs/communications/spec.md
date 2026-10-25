# communications Specification

## Purpose
Esta capacidade cobre a gestão de comunicação da escola com responsáveis e alunos. Permite criar, editar, clonar e arquivar templates de mensagem (e-mail, SMS, push) com placeholders e conteúdo por canal, além de envios segmentados por série, turma, tag ou filtro customizado, com agendamento para data/hora futura com awareness de timezone.

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

### Requirement: WhatsApp as an official communication channel

The system SHALL support WhatsApp as a first-class communication channel through the same template, segmentation, and delivery-tracking infrastructure used for e-mail and SMS, with every message traceable inside the system.

#### Scenario: Segmented WhatsApp send with tracking

- **GIVEN** a coordinator sends a notice to a class group selecting WhatsApp as channel
- **WHEN** the send is processed
- **THEN** each recipient's delivery and read status is recorded in the existing communication history

### Requirement: Channel consent with fallback

The system SHALL only send WhatsApp messages to guardians who opted in to the channel, and SHALL fall back to e-mail (recording the reason) when consent is absent.

#### Scenario: No consent falls back to e-mail

- **GIVEN** a guardian has no WhatsApp opt-in recorded
- **WHEN** a billing reminder is dispatched via WhatsApp
- **THEN** the reminder is sent by e-mail instead and the fallback reason is recorded in the delivery log

### Requirement: WhatsApp templates with actionable variables

WhatsApp templates SHALL support student and invoice variables, including a one-tap PIX second-copy link, so billing reminders are actionable inside the message.

#### Scenario: Billing reminder with PIX link

- **GIVEN** an overdue invoice for a student
- **WHEN** the billing cadence triggers the WhatsApp reminder
- **THEN** the message includes the amount, due date, and a working second-copy link
