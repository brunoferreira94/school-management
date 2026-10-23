## Why

Competidores entregam dashboards passivos; ninguém oferece uma fila diária priorizada de ações. Diretores não precisam de mais gráficos — precisam saber o que fazer hoje. A pesquisa de mercado 2026 (Didatiko/Jacad) mostra que "BI em tempo real" virou commodity, mas o loop "prever → agir" não foi fechado por nenhum concorrente. Já temos `ai-drafts` (resumo semanal com citação de dados) e `add-churn-retention-flows` (win-back) como base.

## What Changes

- Nova capability `director-today-screen`: painel "Tela de Hoje" com fila de ações priorizada por impacto (cobrança, evasão, pedagógico)
- Consolida em um único cockpit: riscos financeiros (billing-cadence), risco de evasão (predictive), rascunhos IA pendentes de aprovação (ai-drafts), tarefas operacionais do dia
- Cada ação tem: base de dados citada, ação sugerida (1 clique) e registro de resolução
- Score de "dia resolvido" para engajamento diário (micro-loop do spec `product-differentiation`)

## Impact

- Affected specs: director-today-screen (novo), consome billing-cadence, ai-drafts, advanced-analytics
- Affected code: `src/app/features/home` (UI), novo `TodayScreenController`, integração com `SubscriptionService`, `CommunicationService`
