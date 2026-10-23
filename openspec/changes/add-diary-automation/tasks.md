## 1. Backend
- [ ] 1.1 Modelar `WeeklyDiaryEntry` (aula dada, conteúdos, faltas registradas) por professor/turma/semana — ou reaproveitar LessonPlan/Assignments existentes como fonte
- [ ] 1.2 `GET /api/diary/weekly/{teacherId}/{week}` e `POST /api/diary/weekly` (upsert)
- [ ] 1.3 `POST /api/diary/weekly/{id}/coordination-report`: gera relatório de coordenação a partir dos dados do diário (sem novo lançamento)
- [ ] 1.4 `POST /api/diary/report-card-comment-draft`: rascunho IA por aluno citando notas e frequência do diário (estado "review required", padrão ai-drafts)
- [ ] 1.5 `POST /api/diary/lesson-plan-draft`: sugestão de plano com BNCC mapeada por disciplina/ano (editável, nunca salvo como final sem revisão)

## 2. Frontend
- [ ] 2.1 Tela do diário semanal do professor (lançamento único: aula + faltas + conteúdos)
- [ ] 2.2 Botão "Gerar relatório para coordenação" com preview e exportação PDF
- [ ] 2.3 Rascunho de comentário de boletim: revisão obrigatória antes de salvar (badge "pending review")
- [ ] 2.4 Plano de aula com sugestão BNCC: código da habilidade pré-preenchido, edição livre

## 3. Testes
- [ ] 3.1 API: relatório de coordenação contém exatamente os dados do diário (sem entrada duplicada)
- [ ] 3.2 API: rascunho de comentário fica bloqueado para envio sem aprovação; trilha de auditoria registra quem aprovou
- [ ] 3.3 E2E: professor lança diário → gera relatório → coordenação visualiza
