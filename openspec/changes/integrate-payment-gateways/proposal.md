# Integrar com Gateways de Pagamento (Stripe / Pagar.me) e Conciliação Financeira

Autor: _a definir_
Data: 2025-10-18
Status: draft

Resumo

Integrar a plataforma com provedores de pagamento (Stripe, Pagar.me) para emissão de cobranças, checkout, webhooks e conciliação automática.

Motivação

- Reduzir fricção no pagamento e automatizar conciliação financeira para reduzir erros manuais.

Escopo

- Integração de checkout, tokenização de cartões, webhooks para eventos (payment_intent.succeeded), e um painel de conciliação.
- Mapeamento entre transações do gateway e registros financeiros internos.

Critérios de aceitação

- Pagamentos processados e conciliados automaticamente com status correto.
- Webhook resiliente e idempotente.

Próximos passos

- Selecionar provider(s) iniciais e criar tasks de integração.

Documentação pós-implementação

- Após integração e configuração, documentar no `README.md` os provedores habilitados, fluxos de webhook, passos para reinstalar chaves e o painel de conciliação.

---

## Decisão de gateway (2026-10-21)

**Dual gateway: Asaas + Stripe** — autorizado por Bruno Ferreira (founder). O `SubscriptionGatewayAbstraction` deve isolar providers; Asaas como primary BRL (pix/boleto/carnê), Stripe para USD/internacional. Desbloqueia a execução das tasks 1–5 deste change.
