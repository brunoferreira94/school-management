# Tasks — Diário único → relatórios automáticos

## 1. Backend
- [x] 1.1 `WeeklyDiaryEntry` por professor/turma/semana (upsert; migration `AddWeeklyDiaryAndDiaryDrafts`) — faltas **não** são redigitadas: vêm do Attendance existente (fonte única)
- [x] 1.2 `GET /api/diary/weekly` (turma + semana, com faltas agregadas da semana) e `POST /api/diary/weekly` (upsert via claim staff_id)
- [x] 1.3 `POST /api/diary/weekly/coordination-report`: relatório de coordenação gerado **somente** dos dados do diário (conteúdos, observações, faltas, professor) — sem novo lançamento
- [x] 1.4 `POST /api/diary/report-card-comment-draft`: rascunho por aluno citando notas e faltas reais, status `PendingReview` (bloqueado até aprovação) — **v1: composição determinística com dados reais; integração com LLM externa quando `ai-drafts` for implementado**
- [x] 1.5 `POST /api/diary/lesson-plan-draft`: plano com habilidades BNCC citadas no conteúdo, editável, revisão obrigatória — **v1: códigos BNCC informados na geração; catálogo completo já existe na tela /bncc**

## 2. Fluxo de revisão (padrão ai-drafts)
- [x] `POST /api/diary/drafts/{id}/approve` (com edição opcional; OriginalContent preservado p/ auditoria) e `/reject` (com motivo) — dupla aprovação bloqueada
- [x] `GET /api/diary/drafts?status=`: fila de revisão

## 3. Frontend
- [x] 3.1 `/diario`: diário semanal (lançamento único: conteúdos + observações; faltas read-only vindas da frequência), navegação por semana
- [x] 3.2 Botão "Gerar relatório para coordenação" com preview + imprimir/PDF (print CSS)
- [x] 3.3 Rascunhos com badge "pendente de revisão", edição inline, aprovar/rejeitar
- [x] 3.4 Sidebar: item "Diário" (após Frequência)

## 4. Testes
- [x] 4.1 API: relatório contém exatamente os dados do diário (7 testes: upsert sem duplicar, relatório sem diário lança erro, rascunho cita notas/faltas, auditoria de aprovação + dupla aprovação bloqueada, plano com BNCC, isolamento por tenant)
- [x] 4.2 Unitário frontend: carrega semana com faltas, salva, gera relatório, cria/aprova rascunhos (6 testes)
- [x] 4.3 E2E `diary-automation.cy.ts` (2026-10-25): professor lança conteúdos/observações da semana → salva → gera relatório para coordenação → relatório visível com professor, conteúdos, faltas da semana e botão Imprimir/PDF
