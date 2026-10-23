## Why

A coordenação perde horas remontando a grade quando há conflitos de horário. O spec atual de `timetabling` valida disponibilidade de professores mas não detecta conflitos na grade montada nem sugere correções. Detectar e sugerir a troca em 1 clique reduz o trabalho manual da coordenação.

## What Changes

- Delta no spec `timetabling`: detecção automática de conflitos (professor em duas salas, sala ocupada, turma sobreposta)
- Sugestão automática de slot alternativo livre ao detectar conflito
- Painel de validação da grade com lista navegável de conflitos

## Impact

- Affected specs: timetabling (ADDED requirements)
- Affected code: `TimetableService`/`TimetableRepository` (validação + sugestão), UI da grade
