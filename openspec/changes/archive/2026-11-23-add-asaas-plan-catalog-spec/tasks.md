# tasks.md — Bateria de testes executada (Asaas Sandbox, 2026-11-23)

> Executor: agente via MCP `asaas` (`execute-request`), chave sandbox via `{env:ASAAS_SANDBOX_API_KEY}`.
> Ambiente: `https://api-sandbox.asaas.com/v3` · Customer do catálogo: `cus_000010087639`
> ("Planos School Management (Sandbox)", `externalReference=plans_catalog`).
> Resultado ao final: **39 itens de teste (32 da bateria inicial + 7 da rodada de revisão)
> · todos concluídos · 5 registraram comportamento divergente da expectativa inicial**
> (T21×2 → `INACTIVE` em vez de `CANCELED`; T25 inicial inválido — filtros de
> `/v3/payments` ignorados —, refito com filtro client-side; R2/R3 → `PUT` ignora
> silenciosamente campos inválidos em vez de rejeitar) · **0 falhas de produto** ·
> 0 resíduos no sandbox (estado final:4 assinaturas + 4 cobranças `PENDING`, verificado em R7).

## 1. Leitura e consistência do catálogo

- [x] 1.1 T1 — `GET /v3/subscriptions?customer=` retorna exatamente os 4 planos (`totalCount=4`).
- [x] 1.2 T2 — `GET /v3/subscriptions/{id}` para os 4 ids bate com a doc:
      `plan_premium_monthly|299.9|MONTHLY`, `plan_premium_yearly|2999|YEARLY`,
      `plan_enterprise_monthly|999.9|MONTHLY`, `plan_enterprise_yearly|9999|YEARLY`
      (todos `ACTIVE` + `billingType=PIX`).
- [x] 1.3 T3 — `GET /v3/customers/{id}` confere `externalReference=plans_catalog`.
- [x] 1.4 T4 — filtro `?description=Plano Premium` acha os 2 Premium (`totalCount=2`).
- [x] 1.5 T5 — `GET` de id inexistente falha com HTTP 404 (exceção lançada pelo MCP).
- [x] 1.6 T6 — paginação `limit=2&offset=2` devolve os outros 2 (`totalCount=4`).

## 2. Validação negativa (criação)

- [x] 2.1 T7 — POST sem campos obrigatórios → HTTP 400 `invalid_customer`.
- [x] 2.2 T8 — POST com `customer` inexistente → HTTP 400 `invalid_customer`.
- [x] 2.3 T9 — POST `value=0` → HTTP 400 `invalid_value` ("deve ser informado").
- [x] 2.4 T10 — POST `value` negativo → HTTP 400 `invalid_value` ("maior que R$ 0,00").
      **Implicação:** o plano `Free` (R$ 0) não é representável como assinatura no Asaas —
      justifica ficar fora do catálogo (provisionado pelo seeder local).
- [x] 2.5 T11 — POST `cycle` inválido → HTTP 400 `invalid_cycle`.
- [x] 2.6 T12 — POST `billingType` inválido → HTTP 400 `invalid_billingType`.
- [x] 2.7 T13 — POST `nextDueDate` malformada → HTTP 400 `parse_error`.
- [x] 2.8 — nenhum objeto acidental criado pelos testes negativos.

## 3. Ciclo de vida (fixture descartável `fixture_teste_spec`)

- [x] 3.1 T14 — POST cria assinatura `ACTIVE` (`sub_tsrhggc62szejwhm`).
- [x] 3.2 T15 — criação gera cobrança pendente (`PENDING`, `value=10`).
- [x] 3.3 T16 — `PUT description` atualiza.
- [x] 3.4 T17 — `PUT value` (10 → 12.34) atualiza a assinatura.
- [x] 3.5 T17b — **registro:** `PUT value` **não** propaga para a cobrança pendente
      já gerada (`charge.value` permaneceu 10). Cobranças são snapshot.
- [x] 3.6 T18 — `PUT billingType` PIX → BOLETO aceito.
- [x] 3.7 T19 — **registro:** `PUT cycle` (MONTHLY → YEARLY) é aceito — o ciclo **é mutável**.
- [x] 3.8 T20 — **registro:** POST com mesmo `externalReference` cria **duplicata**
      (`sub_hwlblatuxy989icz`) — a API **não é idempotente** por `externalReference`;
      a unicidade é responsabilidade do chamador.
- [x] 3.9 T21 — `DELETE /v3/subscriptions/{id}` resulta em status **`INACTIVE`**
      (expectativa inicial `CANCELED` estava errada — comportamento real registrado).
- [x] 3.10 T22/T26 — ao cancelar a assinatura, as cobranças pendentes geradas por ela
      desaparecem da listagem (resíduo = 0; total da conta voltou de 69 → 67).

## 4. Integridade do sandbox

- [x] 4.1 T25 — cobranças criadas em 2026-11-23 = exatamente as 4 dos planos
      (299.9 / 999.9 / 2999 / 9999, todas `PENDING`, vencimento 2026-12-01).
      **Teste inválido inicial corrigido:** os filtros `?description=` e `?dateCreated=`
      em `/v3/payments` são **ignorados** pela API — refido com filtro client-side.
- [x] 4.2 T28 — total da conta = 67 charges (63 históricas + 4 dos planos) e 0 resíduo
      `Fixture`.
- [x] 4.3 T29 — customer tem exatamente as 4 assinaturas ativas do catálogo.
- [x] 4.4 T31 — `PUT` no-op com payload idêntico em plano real não altera o estado.

## 5. Consultas e detalhe

- [x] 5.1 T30 — `GET /v3/payments/{id}`: `value=299.9`, `dueDate=2026-12-01`,
      `status=PENDING`, vínculo `subscription=sub_1c7lv6gm7m8nnoip`.
- [x] 5.2 T32 — `GET /v3/subscriptions?externalReference=` **filtra** corretamente.
- [x] 5.3 T33 — `GET /v3/subscriptions?status=ACTIVE` filtra corretamente.
- [x] 5.4 T34 — snapshot final dos 4 planos (idem 1.2) — estado limpo para regressão.

## 6. Comportamentos descobertos (registrados como requisitos da spec)

- [x] 6.1 `nextDueDate` na resposta de criação vem **normalizado para o ciclo seguinte**
      (pedido 2026-12-01 → mensal 2027-01-01, anual 2027-12-01), enquanto a cobrança
      gerada usa a data solicitada (`dueDate=2026-12-01`).
- [x] 6.2 Filtros `description`/`dateCreated` em `/v3/payments` são ignorados;
      `customer`/`description`/`externalReference`/`status` em `/v3/subscriptions` funcionam.
- [x] 6.3 Sem idempotência por `externalReference` (ver 3.8).
- [x] 6.4 Cancelamento = `INACTIVE` + remoção das cobranças pendentes (ver 3.9/3.10).

## 7. Rodada de revisão crítica (complementa a bateria)

- [x] 7.1 R1 — **evidência que faltava:** as 4 cobranças de 2026-11-23 têm
      `dueDate=2026-12-01`, `status=PENDING` e vínculo `subscription` correto
      (requisito da spec agora verificado para todos os planos, não só o mensal).
- [x] 7.2 R2 — `PUT value=0` em assinatura existente → **HTTP 200 sem erro e sem
      mudança** (`value` permanece 299.9): diferente do POST (que rejeita com
      `invalid_value`), o PUT **ignora silenciosamente** o campo inválido.
- [x] 7.3 R3 — `PUT billingType` inválido → idem: **ignorado silenciosamente**
      (`billingType` permanece `PIX`), sem erro.
- [x] 7.4 R4 — integridade após os PUTs negativos: os 4 planos permanecem
      `ACTIVE`/`PIX` com os valores canônicos.
- [x] 7.5 R5 — `DELETE` de assinatura já `INACTIVE` → HTTP 200, status permanece
      `INACTIVE` (**cancel é idempotente**).
- [x] 7.6 R6 — assinatura `INACTIVE` continua acessível por `GET` by id (legível
      para auditoria, apenas fora da listagem padrão).
- [x] 7.7 R7 — integridade final: exatamente as 4 assinaturas do catálogo.

## 8. Fora de escopo deste run

- [ ] 8.1 Webhook do Asaas (`POST /api/subscriptions/webhooks/asaas`) — exige URL pública
      e `Asaas__WebhookToken`; não exercitável neste ambiente.
- [ ] 8.2 Fluxo de checkout da aplicação (submodules `school-management-api`/`-ui` não
      estão checkoutados neste worktree) — coberto por `checkout-gateway` / E2E.
- [ ] 8.3 Ambiente de produção (`api.asaas.com`) — exige chave de produção.
