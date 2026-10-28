# Tasks — apply-product-strategy-discipline

## 1. Instrumentação de uso (fonte do SKI e adoção)

- [ ] 1.1 Adicionar eventos de descoberta/uso por feature no `school-management-api` (telemetria/analytics) — estender `advanced-analytics`.
- [ ] 1.2 Persistir contagem de usuários ativos elegíveis e usuários que usaram cada feature na frequência apropriada (janela 30d).
- [ ] 1.3 Endpoint `GET /api/analytics/feature-adoption` retornando taxa por feature + threshold.
- [ ] 1.4 Endpoint `GET /api/analytics/swiss-knife-index` retornando SKI + lista de baixa adoção (<10% / <0.3).

## 2. Governança de portfólio (product-feature-discipline)

- [ ] 2.1 Modelo de inventário ranqueado de features com score `(Novos Usuários + Nova Receita + Impacto) / Esforço`.
- [ ] 2.2 Gate de "qual feature mato?" obrigatório na triagem de roadmap (bloqueio sem resposta).
- [ ] 2.3 Widget de SKI + adoção no dashboard owner (`advanced-analytics`).

## 3. Descoberta e adoção (feature-adoption)

- [ ] 3.1 Empty states direcionais nos pontos de uso (ex.: CTA de convidar responsável no cartão de turma).
- [ ] 3.2 Triggered onboarding disparado por comportamento (ex.: notas → comparativo de desempenho), uma única vez.
- [ ] 3.3 Regra de revisão: feature < threshold por 2 janelas → mover para configurações avançadas (hide, não delete).

## 4. Hierarquia de atenção pós-login (automated-onboarding MODIFIED)

- [ ] 4.1 Painel pós-setup prioriza visualmente a feature de maior retenção (primeira turma) sobre nicho.
- [ ] 4.2 Instrumentação de quais empty states/triggers convertem em uso real.

## 5. Validação

- [ ] 5.1 `openspec validate apply-product-strategy-discipline --strict` verde.
- [ ] 5.2 Testes de unidade/integração dos endpoints de SKI e adoção.
- [ ] 5.3 E2E (token real) para empty state direcional + triggered onboarding em pelo menos um fluxo.
