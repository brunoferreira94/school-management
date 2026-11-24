# tasks.md — Aplicação da opção (a) + sincronização da spec (2026-11-24)

> Executor: agente via MCP `asaas` (`execute-request`), chave sandbox via `{env:ASAAS_SANDBOX_API_KEY}`.
> Ambiente: `https://api-sandbox.asaas.com/v3` · Customer do catálogo: `cus_000010087639`.

## 1. Troca PIX → BOLETO (opção a)

- [x] 1.1 `PUT /v3/subscriptions/{id}` com `billingType=BOLETO` nas 4 assinaturas —
      todas `ACTIVE` com valor/ciclo intactos (`plan_{premium,enterprise}_{monthly,yearly}`).
- [x] 1.2 `PUT /v3/payments/{id}` com `billingType=BOLETO` em todas as cobranças
      pendentes localizadas (client-side: filtros de `/v3/payments` são ignorados).
- [x] 1.3 Verificação independente (re-GET): 4 assinaturas `ACTIVE`/`BOLETO` e cobranças
      `PENDING`/`BOLETO`.

## 2. Investigação das 2 cobranças extras (conta 67 → 69)

- [x] 2.1 Localizadas: 299,90 e 999,90 venc. 2027-01-01, vinculadas aos planos mensais
      certos, `dateCreated=2026-11-23` (criadas **ontem à noite**, após a checagem R1).
- [x] 2.2 Sonda com fixture descartável (`probe_put_cycle`):
      - `PUT billingType` **não** gera cobrança do próximo ciclo (count permaneceu 1);
      - `dateCreated` da cobrança = data real de criação (fixture criada em 24/11 →
        `2026-11-24`), logo as extras **não** vieram dos PUTs de hoje;
      - reconfirmou T17b: o `PUT` na assinatura não altera o `billingType` da cobrança
        existente (ficou `PIX`);
      - fixture removida, conta restaurada.
- [x] 2.3 Conclusão: pré-geração de ciclo pelo próprio provedor (janela abriu para o
      ciclo mensal de2027-01-01; o anual de2027-12-01 está fora da janela).

## 3. Decisão do dono do produto: excluir as2 extras

- [x] 3.1 `DELETE /v3/payments/pay_0_c9mj05xsacxilc` (299,90 jan/2027) → removida.
- [x] 3.2 `DELETE /v3/payments/pay_0_xcw06jx4tufg7n` (999,90 jan/2027) → removida.
- [x] 3.3 Estado final: conta = 67 charges; exatamente as 4 cobranças do catálogo
      (299,9 / 999,9 / 2999 / 9999, `BOLETO`, `PENDING`, venc. 2026-12-01); 4 assinaturas
      `ACTIVE`/`BOLETO`.

## 4. Sincronização da spec

- [x] 4.1 Delta `specs/asaas-plan-catalog/spec.md`: 3 `MODIFIED` (billing type, cenário
      de update, estado limpo) + 1 `ADDED` (pré-geração de ciclo).
- [x] 4.2 `openspec validate update-asaas-plan-catalog-contract --strict` → válida.
- [x] 4.3 `openspec archive update-asaas-plan-catalog-contract --yes` (+1 `ADDED`, ~3
      `MODIFIED` aplicados à spec `asaas-plan-catalog`).
- [x] 4.4 Commit + fast-forward da `main`.

## 5. Fora de escopo

- [ ] 5.1 Webhook do Asaas (URL pública + `Asaas__WebhookToken`).
- [ ] 5.2 Ambiente de produção (`api.asaas.com`).
