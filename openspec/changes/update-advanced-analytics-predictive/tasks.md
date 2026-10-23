# Tasks — Scores preditivos de risco (evasão/inadimplência)

## 1. Backend
- [x] 1.1 `RiskScore` model (aluno, tipo evasão|inadimplência, score 0-100, fatores[] em linguagem simples, recalculadoEm) + migration `AddRiskScoreAndTodayActions`
- [x] 1.2 Recálculo sobre dados consolidados: frequência (faltas 30d via AcademicContext→ClassGroup→SchoolUnit), notas abaixo da média (Assessment→ClassGroup), atrasos financeiros (Installment→StudentPlan→SchoolUnit) — executado com staleness de 20h (recompute-on-read via `RecomputeIfStaleAsync`)
- [x] 1.3 `GET /api/analytics/risk-scores?type=churn|delinquency`: lista priorizada por tenant
- [x] 1.4 `GET /api/analytics/risk-scores/{studentCpf}`: score individual com fatores explicáveis
- [x] 1.5 Score acima do limiar (`ChurnActionThreshold`) publica ação na fila da Tela de Hoje com dados citados

## 2. Frontend
- [ ] 2.1 Painel "Risco" no advanced-analytics existente: lista priorizada com score e fatores
- [ ] 2.2 Detalhe do aluno: fatores em linguagem simples — **parcialmente coberto pela Tela de Hoje (fatores citados no card); painel dedicado pendente**
- [ ] 2.3 Ação direto do painel: "criar rascunho de contato" (ai-drafts) ou "adicionar à fila de hoje" — **depende da implementação de ai-drafts; resolver pela Tela de Hoje já disponível**

## 3. Testes
- [x] 3.1 Unitário: score de evasão sobe com faltas; fatores listados refletem os pesos; aluno sem problemas não tem score; ausência de outro tenant é ignorada; staleness não recalcula (5 testes)
- [x] 3.2 Integração: score acima do limiar gera ação na Tela de Hoje com base citada (fila contém ação churn a partir dos scores)
- [ ] 3.3 E2E: diretora abre o painel de risco, escolhe um aluno e gera rascunho de contato
