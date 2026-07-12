# add-teacher-availability

## Why

A geração automática de horários só funciona bem quando o sistema conhece os intervalos em que cada professor pode lecionar. Sem uma fonte confiável de disponibilidade, o scheduler pode sugerir horários inviáveis ou exigir retrabalho manual.

## What Changes

- Persistir janelas semanais de disponibilidade por professor, tenant, dia da semana, horário de início e fim.
- Expor API para cadastrar, listar, atualizar e remover disponibilidade de professores.
- Reutilizar a disponibilidade no scheduler automático para aceitar professores apenas quando o horário solicitado está dentro da janela registrada.
- Adicionar UI em professores/staff para registrar e revisar essas janelas.

## Impact

- Affected specs: `timetabling`
- Affected code: `TeacherAvailability` domain entity, repository, EF migration, scheduling service, controller, Angular teacher/staff availability UI.
