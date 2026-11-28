# Rollout de produção — modelo de preços híbrido (27/11/2026)

## Estado final

| Componente | Referência | Verificação |
|---|---|---|
| API (Render `school-management-api`, branch `main`) | merge `2e962e2`, deploy `dep-dc4vjq7f3r2c73cv0rk0` **live** | `GET /api/v1/subscriptions/plans` → Premium **149,00**, `includedStudents=150` |
| Gateway de pagamento | `Asaas__ApiBaseUrl=https://api.asaas.com/v3` + chave de produção | GET read-only ao Asaas → **200** (chave nunca exibida) |
| UI (Vercel `main`) | commit `4ecef1f`, deployment `dpl_9jwYvm7M6Z53jQQgjdD5sMs6sK1o` **READY/PROMOTED** | bundle `main-K5PB4J7C.js` contém `Simule o valor` e `feature_not_in_plan`, sem `Hero Title`/`Cta Start` |
| Cotação | `GET /api/v1/subscriptions/price-quote?plan=premium&cycle=Monthly&students=300&units=1` | `total=524`, `basePrice=149`, `studentSurcharge=375` |

## URLs corretas

- **API de produção (direta)**: `https://school-management-api-sik5.onrender.com`
- **UI de produção (aliases)**: `https://school-management-ui-three.vercel.app`,
  `https://school-management-ui-brunoferreira94s-projects.vercel.app`,
  `https://school-management-ui-git-main-brunoferreira94s-projects.vercel.app`
- URL de deployment avulso (ex.: `school-management-a6603y37o-...vercel.app`) **não é alias** —
  fica presa ao build daquele deploy. Usar sempre um alias para verificar produção.

## Armadilhas deste rollout

1. **`git merge development → main` na UI sobrescreve `vercel.json`**: o branch `development`
   aponta `/api` e `/metrics` para a API de staging (`school-management-api-dev`). Após o merge,
   o `main` passou a rotear produção para staging. Restaurar sempre para
   `https://school-management-api-sik5.onrender.com` (commit `4ecef1f`). Já havia acontecido em
   `4c9f374` — checar `vercel.json` após **todo** merge para `main`.
2. **Env var no Render com `autoDeploy=no` não dispara deploy**: trocar `Asaas__ApiBaseUrl`/
   `Asaas__ApiKey` exigiu `POST /v1/services/{id}/deploys` explícito.
3. **`PUT /env-vars` substitui o conjunto e `GET` pagina em 20**: usar
   `scripts/render-set-env-var.py` (GET `?limit=100` → merge → PUT), sem imprimir valores.
4. **Chave de produção**: lida de `/home/bruno/workspace/secrets.prod.env` (`ASAAS_API_KEY`)
   direto para variável de shell — nunca impressa, nunca versionada.

## Promoções posteriores (27/11, tarde)

- **Nudges de upgrade** (`add-plan-upgrade-nudges`): commit `ea5fef1` promovido para `main` via
  **cherry-pick** (evita o `vercel.json` de staging entrar em produção). Vercel production
  READY (`main`, sha `ea5fef16`), bundle `main-56ZR5I4Y.js` com "Mensalidades sem planilha".
- **Pricing no staging**: deploy `dep-dc534pmc6qcc73fi40p0` **live** (branch `development`).
  Verificado: catálogo Free 0 / Premium 149 / Enterprise 499 e `price-quote` 300 alunos → 524.
- **Gate offline**: o deploy zerou os contadores; nova base em
  `offline-sync-gate-base-2026-11-27-postpricing.json` (6 séries). A janela de ≥7 dias recomeça
  deste deploy.
- **`Entitlement:Enforce = true` em produção**: env var adicionada (21 → 22 vars), deploy
  `dep-dc53a9p7lnhs73afou10` **live**, verificado `Entitlement__Enforce = true` e API 200 com
  catálogo 149/499. O modal de upgrade (402 `subscription_expired`) já está em produção desde o
  rollout de preços. **Não foi feito smoke 402 em produção** (criaria tenant/cobrança real) — o
  comportamento 200/402/201 foi validado no staging em 27/11 07:xx. `FeatureGating:Enforce`
  continua `false` em produção.

## Pendências após o rollout

- ~~**3.2**: cadastrar URL/token do webhook no painel Asaas~~ → **concluído 27/11**: token aplicado
  em produção (deploy `dep-dc50emh7lnhs73a5fts0`) e webhook `c17af91e-…` corrigido via API para
  `/api/v1/subscriptions/webhooks/asaas`, preservando os 29 eventos e o authToken. A URL registrada
  originalmente (`/api/v1/webhook`) não existe na API; o arquivo local de segredos foi corrigido.
  Smoke sem cobrança: POST sem token → **401**, com token → **200** `processed:false`.
  Webhook reativado manualmente pelo dono e verificado via API: `enabled=true`,
  `interrupted=false`, 29 eventos, authToken presente.
- **3.4**: smoke de cobrança real (checkout → webhook → `Active` → reconciliação `ok`) —
  **não executado**, pois criaria cobrança real sem cliente piloto. Fazer no primeiro cliente.
- **Feature gating**: `FeatureGating:Enforce` segue `false` em produção; ativar só com decisão
  explícita. `Entitlement:Enforce` também segue `false` em produção (ativado só no staging).
