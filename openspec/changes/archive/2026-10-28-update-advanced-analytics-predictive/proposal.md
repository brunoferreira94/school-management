## Why

Todos os concorrentes anunciam "BI preditivo", mas entregam gráficos passivos. Ninguém fecha o loop "prever → agir": o score alimentar uma fila de ação com contexto e rascunho de conversa. Já temos `add-churn-retention-flows` (win-back de assinatura) e `ai-drafts` (outreach com citação de dados) — falta o score preditivo de evasão/inadimplência que os dispara. A inadimplência escolar está em recorde (22,63%) e evasão é a variável que separa escolas que perdem 15%/semestre de 8%.

## What Changes

- Delta no spec `advanced-analytics`: scores preditivos de risco de evasão e inadimplência por aluno/família
- Scores explicáveis (fatores que pesaram, em linguagem simples) — não caixa-preta
- Integração: score alto entra na fila da Tela de Hoje com rascunho de outreach (ai-drafts) e priorização de recuperação (perfil regularizável vs. acordos)
- Recalculação diária sobre dados consolidados (frequência, notas, atrasos, uso do portal)

## Impact

- Affected specs: advanced-analytics (ADDED requirements), alimenta director-today-screen e ai-drafts
- Affected code: job diário de scoring, `RiskScore` na modelagem de analytics, endpoints de consulta
