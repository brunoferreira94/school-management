# Runbook — Ativar `Entitlement:Enforce` no staging

> Change: `openspec/changes/pricing-model-and-commercial-surfaces/` (task 2.6/2.9)
> Decisão do dono (26/11): trial vencido = **somente-leitura + modal de oferta** para assinar.
> Backend: `EntitlementEnforcementMiddleware` já bloqueia escrita com `402 subscription_expired`
> e mantém leitura; UI: modal entregue no commit `415965d`.
> **Status: PREPARADO, NÃO EXECUTADO** — aguardando o fechamento da janela do gate offline.

---

## 0. Por que esperar

`docs/runbooks/offline-sync-rollout.md` (regras de conduto, §Checkpoint):

> **não deployar no staging durante a janela** (o deploy zera os contadores em memória e a
> janela recomeça).

A janela de 24h do gate offline começou em **26/11 05:24 UTC** e fecha em **27/11 ~05:24 UTC**.
Trocar uma env var no Render **dispara deploy** (mesmo com `autoDeploy = no`), portanto a troca
só pode ser feita **depois** do fechamento e da verificação do gate.

---

## 1. Pré-requisitos (checar antes de qualquer mutação)

1. Janela fechada e verificada (ambos os comandos devem passar):

   ```bash
   cd /home/bruno/workspace/school-management
   ./scripts/check-offline-sync-gate.py --env staging \
       --baseline docs/runbooks/offline-sync-gate-base-2026-11-26.json
   ./scripts/check-offline-sync-gate.py --env staging --window 24h
   ```

   Critérios: Δ`missing{batch}` = 0, Δ`revision_missing` = 0, conflitos < 1%, adesão por rota
   ≥ 99%, `wildcard = 0`, nenhum alerta novo. Registrar o output em
   `docs/runbooks/offline-sync-gate-base-2026-11-27.md`.

2. Código da UI com o modal no branch `development` (commit `415965d` ou posterior) e preview
   Vercel do `development` já servindo esse build.

3. Staging com 24 env vars e **sem** `Entitlement__Enforce`:

   ```bash
   RENDER_API_KEY=$(grep -oP '(?<=^RENDER_API_KEY=).*' /home/bruno/workspace/secrets.env)
   curl -s -H "Authorization: Bearer $RENDER_API_KEY" \
     "https://api.render.com/v1/services/srv-d9r4shvqj5pc73ap72k0/env-vars?limit=100" \
     | python3 -c 'import sys,json; d=json.load(sys.stdin); print("total:",len(d),"Enforce:",
       [e["envVar"]["value"] for e in d if e["envVar"]["key"]=="Entitlement__Enforce"] or "AUSENTE")'
   ```

   > Nunca imprimir valores de outras vars (o comando acima só mostra a chave alvo).

---

## 2. Aplicar a env var (GET ?limit=100 → merge → PUT)

O `PUT /env-vars` **substitui o conjunto inteiro**; o `GET` pagina em 20 por default. Usar o
helper versionado (ele nunca imprime valores):

```bash
cd /home/bruno/workspace/school-management
export RENDER_API_KEY=$(grep -oP '(?<=^RENDER_API_KEY=).*' /home/bruno/workspace/secrets.env)
python3 scripts/render-set-env-var.py \
  --service srv-d9r4shvqj5pc73ap72k0 \
  --key Entitlement__Enforce \
  --value true
# saída esperada: "GET ok: 24 env vars" / "PUT ok: chave 'Entitlement__Enforce' adicionada; total 25 vars"
```

---

## 3. Deploy manual (autoDeploy está `no`)

```bash
curl -s -X POST \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"clearCache":"do_not_clear"}' \
  "https://api.render.com/v1/services/srv-d9r4shvqj5pc73ap72k0/deploys"
```

Aguardar o deploy ficar `live` (não usar `GET ?limit=100` aqui). O deploy **reinicia a janela
do gate offline** — por isso só acontece depois do passo 1.

---

## 4. Smoke pós-ativação

Base: preview Vercel do `development`
`https://school-management-s213ik1xm-brunoferreira94s-projects.vercel.app`
(rewrite `/api/v1` → Render staging). Usar a conta de validação do staging (credenciais fora do repo).

1. **Leitura continua liberada**

   ```bash
   curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer $TOKEN" \
     "https://school-management-s213ik1xm-brunoferreira94s-projects.vercel.app/api/v1/students?page=1&pageSize=1"
   # esperado: 200
   ```

2. **Escrita de tenant com trial vencido é bloqueada**

   Se não houver tenant expirado no staging, criar um de teste e ajustar `TrialEndsAtUtc` para o
   passado direto no Postgres do ambiente; **restaurar o valor depois do smoke**.

   ```bash
   curl -s -i -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"name":"Smoke bloqueio"}' \
     "https://school-management-s213ik1xm-brunoferreira94s-projects.vercel.app/api/v1/classrooms"
   # esperado: 402
   # corpo: {"error":"subscription_expired","reason":"trial_expired","message":"..."}
   ```

3. **Modal aparece na UI**

   No preview do `development`, com a conta de trial vencido, tentar uma escrita qualquer
   (ex.: criar uma sala). Esperado: dialog *"Seu teste grátis terminou"*, planos Premium/Enterprise
   e botão *"Assinar Premium"*; ao fechar, o usuário permanece na mesma tela com os dados visíveis.

   Automação equivalente (mock do 402, já verde em CI):
   `npx cypress run --spec cypress/e2e/subscription-upgrade-modal.cy.ts`

4. **Escrita de tenant ativo continua funcionando** (200/201) — garante que o gate não vazou para
   assinaturas vigentes.

---

## 5. Rollback

```bash
export RENDER_API_KEY=$(grep -oP '(?<=^RENDER_API_KEY=).*' /home/bruno/workspace/secrets.env)
python3 scripts/render-set-env-var.py --service srv-d9r4shvqj5pc73ap72k0 \
  --key Entitlement__Enforce --value false
curl -s -X POST -H "Authorization: Bearer $RENDER_API_KEY" -H "Content-Type: application/json" \
  -d '{"clearCache":"do_not_clear"}' \
  "https://api.render.com/v1/services/srv-d9r4shvqj5pc73ap72k0/deploys"
```

---

## 6. Registro da execução (27/11/2026)

- **07:13 UTC** — janela verificada: ver `offline-sync-gate-closure-2026-11-27.md`
  (Δmissing=0, Δrevision=0, Δconflitos=0 em 33.570 ops, 0 alertas, 100% adesão).
- **07:15 UTC** — `Entitlement__Enforce=true` aplicado no staging (24 → 25 vars).
- **Deploy `dep-dc4irc61egvs738jggjg`** — `build_in_progress → update_in_progress → live`.
- Smoke (token de validação, tenant `e00b2b67-…`):
  1. leitura `GET /api/v1/students` → **200**;
  2. trial do tenant expirado temporariamente (`TrialEndsAtUtc` = agora − 1 dia) → escrita
     `POST /api/v1/classrooms` → **402** com
     `{"error":"subscription_expired","reason":"trial_expired", ...}`; trial **restaurado**
     ao valor original (`2026-12-09 04:40:01.69479+00`) via `trap`;
  3. modal validado no build de produção com `cypress/e2e/subscription-upgrade-modal.cy.ts` → **2/2**;
  4. tenant ativo → escrita **201**, registro de teste removido (**204**).
- **Nova base do gate** após o deploy (contadores zerados):
  `offline-sync-gate-base-2026-11-27.json` (6 séries). A contagem da janela de ≥7 dias
  recomeça a partir deste deploy.
