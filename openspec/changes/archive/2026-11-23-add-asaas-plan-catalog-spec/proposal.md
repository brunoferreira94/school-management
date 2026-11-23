# add-asaas-plan-catalog-spec

## Why

O catálogo de planos comerciais foi materializado no Asaas **Sandbox** como assinaturas
recorrentes (customer `cus_000010087639`, 4 assinaturas `ACTIVE`), mas nenhum artefato do
OpenSpec registrava o contrato comportamental observado da API do Asaas: validações de
criação, semântica de update, ciclo de vida de cancelamento, idempotência e filtros de
consulta. Sem essa base de verdade, mudanças futuras na integração (`checkout-gateway`,
`activate-dual-gateway-rollout`) não têm como distinguir regressão do app de comportamento
esperado do provedor.

## What Changes

- Nova capability `asaas-plan-catalog` com os requisitos de contrato derivados de testes
  reais executados contra `https://api-sandbox.asaas.com/v3` em 2026-11-23.
- Registro da bateria de testes (39 itens em 6 grupos: bateria inicial + rodada de
  revisão crítica) em `tasks.md`, incluindo comportamentos descobertos que divergem de
  expectativas iniciais (ex.: `POST` rejeita valores inválidos, `PUT` os ignora).
- Nenhuma alteração de código de aplicação; nenhum objeto novo criado no Asaas (os 4
  planos e o customer já existem e são o fixture de integridade da spec).

## Impact

- Affected specs: nova capability `asaas-plan-catalog`
- Affected code: nenhum (contrato externo; fixture Asaas Sandbox: customer
  `cus_000010087639` + subscriptions `plan_{premium,enterprise}_{monthly,yearly}`)
- Fora de escopo: webhook (sem URL pública neste ambiente), gateways Stripe/Pagar.me,
  plano `Free` (R$ 0 não é representável como assinatura — validado por teste).
