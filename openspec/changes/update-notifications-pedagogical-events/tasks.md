## 1. Backend
- [ ] 1.1 Novos gatilhos no NotificationRuleEngine: falta recorrente (limite configurável), ocorrência registrada, nota abaixo da média, boletim publicado
- [ ] 1.2 Eventos de domínio: publicar DomainEvent em Attendance/Occurrence/Grade publication (consumidos pelo engine)
- [ ] 1.3 Anti-ruído: limite por responsável/dia + agrupamento de gatilhos do mesmo aluno (digest diário quando exceder)
- [ ] 1.4 Registro de leitura por notificação (canal preferido respeita opt-in)

## 2. Frontend
- [ ] 2.1 Catálogo de eventos pedagógicos na tela de regras de notificação existente (criar/editar/ativar)
- [ ] 2.2 Digest diário: preview do agrupamento para o responsável

## 3. Testes
- [ ] 3.1 Unitário: 3 faltas consecutivas disparam uma notificação (não três)
- [ ] 3.2 Unitário: excedendo o limite diário, gatilhos do mesmo aluno viram digest único
- [ ] 3.3 E2E: professor registra ocorrência e o responsável recebe notificação com leitura registrada
