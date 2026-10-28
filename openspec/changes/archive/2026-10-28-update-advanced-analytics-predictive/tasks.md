# Tasks — Scores preditivos de risco (evasão/inadimplência)

## 1. Backend
- [x] 1.1 `RiskScore` model (aluno, tipo evasão|inadimplência, score 0-100, fatores[] em linguagem simples, recalculadoEm) + migration `AddRiskScoreAndTodayActions`
- [x] 1.2 Recálculo sobre dados consolidados: frequência (faltas 30d via AcademicContext→ClassGroup→SchoolUnit), notas abaixo da média (Assessment→ClassGroup), atrasos financeiros (Installment→StudentPlan→SchoolUnit) — executado com staleness de 20h (recompute-on-read via `RecomputeIfStaleAsync`)
- [x] 1.3 `GET /api/analytics/risk-scores?type=churn|delinquency`: lista priorizada por tenant
- [x] 1.4 `GET /api/analytics/risk-scores/{studentCpf}`: score individual com fatores explicáveis
- [x] 1.5 Score acima do limiar (`ChurnActionThreshold`) publica ação na fila da Tela de Hoje com dados citados

## 2. Frontend
- [x] Painel "Risco" no advanced-analytics existente: rota /analytics/risco (RiskPanelComponent) — lista priorizada (score desc) com score em destaque, tipo (evasão/inadimplência), recálculo e filtro por tipo; link no sidebar
- [x] Detalhe do aluno: fatores em linguagem simples — chips de fatores no card do aluno (split por ";", ex.: "frequência abaixo de 75%", "atraso financeiro de 2 parcelas"); recálculo automático se >20h (backend RiskScoringService)
- [x] Ação direto do painel: "criar rascunho de contato" via POST /api/ai-drafts/generate (GuardianRiskMessage, targetId=riskScore.id — Id agora exposto no RiskScoreDto) → preview inline do rascunho com data basis + aviso de revisão obrigatória; rascunho nasce PendingReview e o envio é bloqueado até aprovação (ai-drafts)

## 3. Testes
- [x] 3.1 Unitário: score de evasão sobe com faltas; fatores listados refletem os pesos; aluno sem problemas não tem score; ausência de outro tenant é ignorada; staleness não recalcula (5 testes)
- [x] 3.2 Integração: score acima do limiar gera ação na Tela de Hoje com base citada (fila contém ação churn a partir dos scores)
- [x] E2E (risk-panel-draft.cy.ts ao vivo): painel lista scores com fatores → gera rascunho de contato (PendingReview, sem CPF no texto, data basis com score) → envio bloqueado sem aprovação (400 "aprovação humana") → diretora aprova (review) → finalContent disponível
