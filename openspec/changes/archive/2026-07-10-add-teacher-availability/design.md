# add-teacher-availability

## Context

A feature de criação automática de horários depende de restrições reais de professor. A disponibilidade foi modelada como janelas semanais recorrentes por professor e tenant.

## Goals / Non-Goals

- Goals:
  - Permitir cadastro de janelas de disponibilidade por professor.
  - Usar essas janelas para validar horários automáticos.
  - Manter escopo por tenant.
- Non-Goals:
  - Não implementa exceções pontuais por data específica.
  - Não implementa substituição automática de professor indisponível.
  - Não implementa calendário de feriados.

## Decisions

- Decision: `TeacherAvailability` é tenant-scoped e usa `DayOfWeek`, `StartTime` e `EndTime`.
- Decision: `IsStaffAvailableAsync` retorna `true` somente quando a janela solicitada está totalmente contida em uma disponibilidade registrada.
- Decision: A UI fica em professores/staff, não dentro do scheduler, para ser reutilizável por qualquer fluxo de horário.

## Risks / Trade-offs

- Risco: se o usuário não cadastrar disponibilidade, o scheduler pode não conseguir alocar professores.
- Mitigação: o scheduler já deve retornar falha clara quando não houver professor disponível.

## Migration Plan

- A migration `20260620195817_AddTeacherAvailabilityTable` cria a tabela `TeacherAvailabilities` com FK para `Staff` e `Tenants`.
