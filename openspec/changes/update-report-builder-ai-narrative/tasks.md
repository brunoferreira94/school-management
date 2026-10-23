## 1. Backend
- [x] 1.1 Novo tipo de bloco `ai-narrative` no modelo de templates (renderer + catálogo de blocos disponíveis + DI)
- [x] 1.2 `ReportNarrativeService` compõe a narrativa a partir dos dados JÁ buscados para os blocos do próprio relatório (`context.Data`: reportCard/attendance/financialSummary), citando os números — original imutável (`NarrativeOriginalContent`, padrão ai-drafts)
- [x] 1.3 Estado de revisão na geração: relatório entra em `PendingNarrativeReview` sem PDF; download bloqueado (400) até aprovação; aprovação (com edição opcional) re-renderiza com badge "Aprovada", gera o PDF e registra auditoria (`NarrativeReviewedBy/AtUtc/Note`); rejeição preserva o trilho (migration `AddReportNarrativeReview`)
- [ ] 1.4 Template padrão "Resumo executivo mensal" (matrículas, inadimplência, frequência, evasão) — **parcial: o modelo de relatório é por aluno (StudentReportCard/AttendanceReport/balance do aluno), então o bloco já dá resumo executivo por aluno; template de escola (nível institucional, matrículas/evasão agregadas) aguarda modelo de relatório por escola**

## 2. Frontend
- [x] 2.2 Bloco de narrativa: badge de estado no preview renderizado (pendente/aprovada com quem aprovou); na lista de relatórios gerados, painel de revisão com edição antes de aprovar + botão rejeitar + cadeado explicando exportação bloqueada (tab "✍ Narrativas pendentes")
- [x] 2.3 No preview, números citados destacados como chips monoespaçados com hover "Fonte: dado do próprio relatório" (`data-basis`)

## 3. Testes
- [x] 3.1 API: aprovação rejeita estados não-pendentes (já aprovada / não pendente); download bloqueado por estado na geração (PDF nunca produzido) — 3 testes do fluxo de revisão
- [x] 3.2 Unitário: narrativa cita somente dados presentes nos blocos (6 testes — média/frequência/inadimplência, vazio não inventa, badges do renderer)
- [ ] 3.3 E2E: diretor gera relatório, revisa narrativa, aprova e exporta PDF — **pende de ambiente E2E estável (staging em Render 402)**
