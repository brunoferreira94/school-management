# Implementar diferenciais 2026 (régua, WhatsApp, rascunhos IA, transparência, portabilidade)

Autor: Bruno Ferreira (assistente)
Data: 2026-10-22
Status: draft

## Motivação

A pesquisa `explore-differentiation-2026` confirmou dores do mercado que o sistema ainda não
cobre: régua de cobrança automática, comunicação via WhatsApp, assistência de IA com revisão
humana, transparência de confiabilidade e portabilidade de dados no cancelamento. Este change
especifica (e depois implementa) os 5 diferenciais que faltam, sobre as alavancas que já
existem (financeiro + notificações + Asaas, communications, report-builder/BNCC, cancel-flow).

## Desenvolvimento proposto

1. **BillingCadence** — motor de régua de cobrança: eventos de fatura (vencendo D-3, vencida
   D+2/D+5) geram notificações com link de pagamento do gateway ativo; replay seguro, dry-run
   e métrica de conversão.
2. **WhatsApp deep links** — entrega em `communications`: wa.me com texto de modelo por evento
   (inadimplência, aviso, publicação), sem dependência de API paga no v1.
3. **AiDrafts** — rascunhos com revisão obrigatória (mensagem para responsáveis em risco,
   comentário de boletim, resumo semanal do diretor), audit trail e nunca envio sem aprovação.
4. **Transparência** — changelog de correções com MTTR visível no painel e status de integração.
5. **DataPortability** — exportação completa 1-clique (CSV/JSON) no fluxo de cancelamento.

## 6. Lacunas reveladas pelo teste do funil ao vivo (2026-10-22)

Além dos 5 diferenciais de produto, o funil real (landing → pricing → checkout → ativação →
navegação, com API + banco local e seed demo) expôs lacunas de **aquisição self-service** que
não estavam visíveis nos testes com mocks. Elas viraram requirement novo
(`self-service-onboarding`) e tasks da seção 0 do `tasks.md`:

- o checkout da UI **não passa pelo gateway** (`POST /api/subscriptions/tenant` direto, sem
  `checkout-intents`): nenhum link de pagamento é gerado e nenhum webhook reconcilia;
- **não existe cadastro self-service de escola** — o visitante anônimo não sai do login
  (o único cadastro existente é o portal do responsável);
- **não há plano trial/Free automático** na conta nova;
- a "landing" anônima é a própria tela de login (a raiz redireciona) — falta landing/marketing;
- checklist de onboarding não é persistido no servidor em todos os passos.

A mesma rodada corrigiu bugs que só aparecem com backend real (sessão revertida para o stub
dev, `SetupProgress` fora do modelo EF, matriz de permissões incompleta, refresh token
rotacionado derrubando sessão, DI quebrado em Development, seed demo com transação aninhada).

## Impacto

- Specs afetadas: `billing-cadence` (nova), `communications` (delta), `ai-drafts` (nova),
  `product-trust` (nova), `data-portability` (nova), `self-service-onboarding` (nova)
- Código: API (`AuthService`, `AuthService` refresh/grace window, seeders, `SchoolContext`,
  `Program.cs` rate limit) e UI (`auth.service.ts`, `auth.interceptor.ts`,
  `subscription.service.ts`)
- Testes: suíte E2E nova `cypress/e2e/school-funnel.cy.ts` (8/8 verde, backend real)
