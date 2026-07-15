## 1. Cancel flow (win-back)

- [ ] 1.1 Criar componente `cancel-flow` (3 passos: perda concreta → alternativa → motivo)
- [ ] 1.2 Passo 1: exibir perda concreta (contagem real de alunos/turmas/meses de histórico)
- [ ] 1.3 Passo 2: oferecer alternativa (pausar 30 dias / 1 mês grátis)
- [ ] 1.4 Passo 3: coletar motivo via pergunta aberta (texto livre + tag opcional)
- [ ] 1.5 Substituir `CANCEL_CONFIRM` (confirm nativo) pelo novo fluxo em `subscriptions.component`
- [ ] 1.6 API: endpoints de pausa e cancelamento com persistência do motivo + timestamp
- [ ] 1.7 Garantir que o cancelar permanece acessível e honesto em cada passo (sem dark pattern)

## 2. Health score (risco de churn)

- [ ] 2.1 API: calcular health score por conta (janelas 14/30 dias, sinais de login + ações-chave)
- [ ] 2.2 API: endpoint read-only expondo score + sinais contribuintes
- [ ] 2.3 UI: widget de contas em risco no dashboard do owner
- [ ] 2.4 Limiares conservadores validados contra dados reais antes de exibir

## 3. Expansion prompt (usage-based)

- [ ] 3.1 Detectar proximidade do limite do plano (ex.: 90% do teto de alunos)
- [ ] 3.2 Banner contextual não-bloqueante na área relevante (sem interromper a tarefa)
- [ ] 3.3 Link para upgrade/checkout existente

## 4. Re-engagement anchor

- [ ] 4.1 Mapear eventos recorrentes do calendário (início de bimestre, matrícula, fechamento de notas)
- [ ] 4.2 Trigger de notificação vinculado a evento via módulo `notifications`/`communications`
- [ ] 4.3 Fallback de cadência simples quando não há calendário configurado

## 5. Portal — jargão e FAQ contextual

- [ ] 5.1 Auditar copy do portal e reescrever termos técnicos/legalês em linguagem simples
- [ ] 5.2 Adicionar FAQ contextual in-product na seção financeira (e outras de alto atrito)

## 6. Métricas e verificação

- [ ] 6.1 Instrumentar NRR, taxa de save no cancel screen, % contas em risco reativadas
- [ ] 6.2 Testes unitários (cancel-flow, health score) + smoke E2E do fluxo de cancelamento
- [ ] 6.3 `openspec validate add-churn-retention-flows --strict` verde
