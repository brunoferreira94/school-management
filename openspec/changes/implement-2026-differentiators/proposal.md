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
