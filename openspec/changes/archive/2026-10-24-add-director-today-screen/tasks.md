# Tasks — Tela de Hoje com fila de ações priorizada

## 1. Backend
- [x] 1.1 `TodayScreenController`: `GET /api/today` retorna a fila de ações do dia (tipo, prioridade, base citada, ação sugerida) + contagem de resolvidas
- [x] 1.2 `TodayScreenService`: agrega inadimplentes priorizados + risco de evasão (scores) — **v1: fontes `billing` e `churn` implementadas; ocorrências de billing-cadence e rascunhos IA entram na fila quando `implement-2026-differentiators` (billing-cadence/ai-drafts) for implementado**
- [x] 1.3 `POST /api/today/{id}/resolve`: registra resolução (done, deferred, dismissed com motivo) com trilha de auditoria (status, motivo, usuário, timestamp)
- [x] 1.4 Priorização configurável por escola (`TodayScreenOptions`: pesos por tipo de ação, via appsettings "TodayScreen")

## 2. Frontend
- [x] 2.1 Componente `today-screen` na rota `/hoje` (item de menu "Hoje" no sidebar)
- [x] 2.2 Card de ação com: base de dados ("3 faturas vencidas há 5 dias"), botão de ação sugerida (abre rota contextual), botões Resolver/Adiar
- [x] 2.3 Badge de contagem no menu; estado vazio com "dia resolvido" + contagem do dia
- [x] 2.4 Fila reordenada por prioridade; filtros por tipo (financeiro, evasão)

## 3. Testes
- [x] 3.1 API: fila contém ações priorizadas (billing + churn), resolve registra audit, idempotente por SourceKey, isolamento por tenant (5 testes)
- [x] 3.2 Unitário frontend: today-screen renderiza fila, resolve ação, filtra por tipo e mostra estado "dia resolvido" (5 testes)
- [x] 3.3 E2E `today-screen.cy.ts` (2026-10-25): diretor abre /hoje, resolve a ação de cobrança → card some da fila e badge atualiza de 0 para "1 resolvida(s) hoje"; filtro Financeiro mostra só billing
