# Auditoria de Preços e Sustentabilidade do Negócio

**Data:** 26/11/2026 · **Escopo:** modelo de cobrança atual (planos, preços, limites, superfícies comerciais, execução de billing) vs. sustentabilidade do negócio
**Referência de mercado citada:** Sophia (ex-Primasoft) cobra **por aluno + por unidade**, clientes como Anglo (rede com diversas escolas)
**Fontes:** catálogo no banco (`SubscriptionPlans`), código de limites/checkout, páginas públicas em produção, dump de produção `backups/prod-20261125T145221Z.sql.gz`, pesquisa de mercado do repo (`docs/Pesquisa_SaaS_Gestão_Escolar.md`, com fontes citadas) e `openspec/changes/monetization-strategy/`.
**Limitação:** busca web indisponível na data da auditoria — preços de concorrentes vêm da pesquisa versionada no repo; o preço real da Sophia não foi verificado publicamente (informação do dono).

---

## 1. Veredito

> **O modelo atual não sustenta o negócio — e, na prática, hoje não cobra nada.**
> São três problemas em camadas:
>
> 1. **Execução (crítico, imediato):** produção aponta Asaas para **sandbox**, a página pública de preços está com **placeholder em inglês**, existem **3 tabelas de preço divergentes** e nenhum limite de unidade é aplicado. Não dá para fechar uma venda limpa nem cobrar.
> 2. **Modelo (estratégico):** preço **fixo por tier** (R$ 299,90 / R$ 999,90) não escala com o cliente. O preço efetivo por aluno despenca de **R$ 3,75 → R$ 0,11** conforme a escola cresce — e o segmento que a Sophia cobraria (rede multi-unidade tipo Anglo) pagaria **R$ 999,90 fixos**.
> 3. **Ancoragem:** o Free entrega quase tudo (só limites de volume) e **nenhuma feature do plano é bloqueada** — o único gatilho de upgrade real é passar de 50 alunos.
>
> **Custos diretos hoje ≈ R$ 0 (free tiers), então 1 cliente já cobre a infraestrutura** — o problema não é break-even de infra, é que **a receita por cliente é pequena demais para sustentar fundador + suporte + crescimento** (ver §6).

**Recomendação:** manter Free/Premium/Enterprise como **camadas de recurso**, mas trocar a métrica de cobrança para **base + por aluno (com teto) + por unidade** (híbrido, igual ao mercado e ao modelo Sophia), com **preço-piloto fechado para o primeiro cliente**. Antes de qualquer coisa: **consertar as superfícies comerciais e ligar a cobrança real** (bloqueadores em §8).

---

## 2. O que está definido hoje (fonte de verdade)

Catálogo no banco — `school-management-api/src/SchoolManagement.Infrastructure/Data/Seeders/SubscriptionPlanSeeder.cs`:

| Plano | Mensal | Anual | Alunos | Unidades | Staff | Storage | Gateways |
|---|---|---|---|---|---|---|---|
| **Free** | R$ 0 | R$ 0 | 50 | 1 | 5 | 100 MB | — |
| **Premium** | **R$ 299,90** | R$ 2.999,00 (−16,7%) | 500 | 5 | 50 | 10 GB | checkout self-service |
| **Enterprise** | **R$ 999,90** | R$ 9.999,00 (−16,7%) | ∞ | ∞ | ∞ | ∞ | "falar com vendas" |

- **Trial:** todo tenant novo recebe Free `Trial` de **14 dias** (`TrialSubscriptionProvisioner.cs:70`, spec `subscription-model`).
- **Checkout self-service:** **só Premium** (`CheckoutIntentService.cs:54-56`), mensal ou anual, via Asaas (assinaturas do catálogo em `BOLETO`, spec `asaas-plan-catalog`).
- **Metering:** `CurrentStudentCount` é incrementado/decrementado por evento de criação/exclusão de aluno (`Students/Events/IncrementStudentCountOnStudentCreated.cs`) — **a base técnica para cobrança por aluno já existe**.
- **Entitlement:** middleware de bloqueio de escrita para assinatura vencida (402) existe (`EntitlementEnforcementMiddleware`), mas a flag `Entitlement:Enforce` **não está definida em produção** → **desligada**.

### Matriz de enforcement (o que de fato é cobrado/travado)

| Limite / recurso do plano | Aplicado? | Onde |
|---|---|---|
| Máx. alunos (50/500) | ✅ | `StudentCreationService.cs:57` → `EnsureStudentLimitAsync` |
| Máx. staff (5/50) | ✅ | `StaffService.cs:38` |
| Máx. storage (100 MB/10 GB) | ✅ | `DocumentService.cs:47` |
| **Máx. unidades (1/5)** | ❌ **nunca chamado** | `SubscriptionLimitService.cs:54` existe, **0 callers** |
| **Features por plano** (portal, financeiro, analytics, API, branding) | ❌ | `CheckSubscriptionFeatureAsync` só expõe endpoint (`SubscriptionsController.cs:651`); **nenhum middleware/UI gateia** — Free usa tudo |
| **Assinatura paga / trial vencido** | ❌ off em produção | `Entitlement:Enforce` ausente nas 21 env vars de produção |

**Consequência:** um tenant **Free** (R$ 0) usa portal do responsável, módulo financeiro, analytics e API. O único freio é passar de 50 alunos / 5 staff / 100 MB.

---

## 3. Estado real de cobrança (produção, dump 25/11)

| Item | Estado |
|---|---|
| Tenants / alunos / assinaturas | **1 tenant (`default`), 0 alunos, 0 `TenantSubscriptions`** → **receita R$ 0** |
| `Asaas__ApiBaseUrl` em produção | **`https://sandbox.asaas.com/api/v3`** ⚠️ — runbook `activate-gateways.md:121` exige `https://api.asaas.com/v3` em produção |
| `Asaas__WebhookToken` | presente (painel Asaas continua como pendência manual) |
| `Entitlement__Enforce` | ausente → bloqueio por assinatura desligado |
| Infra | free tiers (Render 750 h/mês, Vercel Hobby) — custo direto ≈ R$ 0 |

**Hoje o produto é gratuito de ponta a ponta:** ninguém pode ser cobrado (sandbox), ninguém é bloqueado (entitlement off) e o plano Free já entrega tudo.

---

## 4. Superfícies comerciais divergentes (3 tabelas de preço + placeholders)

| # | Superfície | O que mostra | Problema |
|---|---|---|---|
| 1 | **API / banco** (fonte correta) | Free 50 · Premium R$ 299,90 (500) · Enterprise R$ 999,90 | — |
| 2 | **`/pricing` pública (produção)** | Cards vêm da API ✅, mas: H1 **"Hero Title"**, badge **"Hero Badge"**, preço do Free = **"Price On Request"** + botão **"Cta Start"/"Cta Sales"**, linhas "Plan Feature Students/Teachers", tabela "Plan Basic / Plan Pro" com **100 alunos (Free real = 50)** e **20 professores (real = 50)**, seções "Comparison Title"/"Faq Title" | **~30 strings de i18n em placeholder inglês** (`i18n-data.ts:752-795`); Free aparece como "sob consulta"; limites hardcoded contradizem a API e a própria card |
| 3 | **Tela interna "Planos Disponíveis"** (`subscriptions.component.html:35-60`) | **Básico R$ 99/mês (100 alunos)** · **Profissional R$ 299/mês (500, 20 prof)** · **Enterprise "Sob consulta"** | Terceira tabela, hardcoded, **preços e nomes diferentes** do catálogo |
| 4 | **Doc `docs/plans/pricing-page.md`** | Free 50 · Premium R$ 299,90 · Enterprise R$ 999,90 · **"desconto anual 15%"** | Desconto real = **16,7%** (2.999 vs 3.598,80) |

Evidência em produção: bundle `main-Y6EZDGCH.js` de `school-management-a6603y37o-...vercel.app` contém `PRICE_ON_REQUEST:"Price On Request"`, `HERO_TITLE:"Hero Title"`, `CTA_START:"Cta Start"` (grep em 26/11). A landing pública (`/`) linka para `/pricing` — **todo visitante cai nessa página**.

Adicional: `PLAN_FEATURES_BY_SLUG.free` promete "Portal do responsável" no Free, enquanto `docs/plans/pricing-page.md` coloca o portal no Premium — mais uma divergência de oferta.

---

## 5. Análise de preço: o fixo perde receita no topo

### 5.1 Preço efetivo por aluno hoje

| Escola | Alunos | Unid. | Plano | Pago/mês | **R$/aluno** |
|---|---|---|---|---|---|
| Pequena | 80 | 1 | Premium | R$ 299,90 | **R$ 3,75** |
| Média | 300 | 1 | Premium | R$ 299,90 | **R$ 1,00** |
| Grande | 800 | 2 | Enterprise | R$ 999,90 | **R$ 1,25** |
| Rede (Anglo-like) | 9.000 | 20 | Enterprise | R$ 999,90 | **R$ 0,11** |

> Para a rede tipo Anglo, vendemos **R$ 0,11 por aluno** — a Sophia (por aluno + por unidade) capturaria uma fração mínima disso como receita nossa.

Referências do mercado (pesquisa versionada no repo, `docs/Pesquisa_SaaS_Gestão_Escolar.md:90-106`):
- **Sistema Quality:** R$ 99,00 base + **R$ 4,99–6,99/aluno** (básico/completo)
- **DKSoft:** R$ 126,50 fixo (usuários ilimitados) — modelo agressivo de entrada
- **Add-on WhatsApp/SMS:** R$ 29,90/mês (receita recorrente modular)
- **Enterprise:** sempre "sob consulta"

### 5.2 Mesmos clientes, modelo Sophia-style (base + R$/aluno + R$/unidade)

Cenário A usa a taxa da Quality (R$ 4,99/aluno) + R$ 100/unidade; cenário B é conservador (R$ 2,50/aluno + R$ 100/unidade):

| Cliente | Alunos | Unid. | **Hoje (fixo)** | Cenário A | Cenário B |
|---|---|---|---|---|---|
| Pequena | 80 | 1 | R$ 299,90 | R$ 499,20 (**1,7×**) | R$ 300,00 (1,0×) |
| Média | 300 | 1 | R$ 299,90 | R$ 1.597,00 (**5,3×**) | R$ 850,00 (**2,8×**) |
| Grande | 800 | 2 | R$ 999,90 | R$ 4.192,00 (**4,2×**) | R$ 2.200,00 (**2,2×**) |
| Rede (Anglo) | 9.000 | 20 | R$ 999,90 | R$ 46.910,00 (**46,9×**) | R$ 24.500,00 (**24,5×**) |

Mesmo num cenário ultra-conservador, **um único cliente de rede supera toda a receita de 20+ escolas Premium no modelo atual**.

### 5.3 Cliff de preço (risso de churn)

Escola com 500 alunos paga R$ 299,90; ao cadastrar o 501º salta para Enterprise **R$ 999,90 (+233%)**. Degrau assim gera negociação, insatisfação ou evasão. Cobrança gradual (base + por aluno) elimina o cliff.

### 5.4 O modelo fixo é bom em quê

- **Venda simples:** preço de catálogo, checkout self-service já implementado para Premium, sem cálculo.
- **Previsibilidade:** MRR flat por cliente.
- **Posicionamento:** R$ 299,90 "fechado" é fácil de comparar em reunião.
- Para **escolas pequenas (50–150 alunos)** o preço é competitivo (a Quality cobraria R$ 349–848 pelo mesmo volume).

O modelo não está errado para *entrada* — está errado como *único* modelo, porque não captura crescimento nem redes.

---

## 6. Custos e sustentabilidade

| Custo | Hoje | Com 1º cliente real |
|---|---|---|
| Infra (Render/Vercel/Postgres/Auth0) | R$ 0 (free tiers) | R$ 50–150/mês (Render Starter ~US$ 7 + domínio próprio + storage de backup) |
| Taxas de cobrança (Asaas) | — | ~1% do ticket em boleto (**confirmar tabela vigente no painel**) |
| Suporte / onboarding / migração | tempo do fundador | **custo marginal real — escala por cliente, não por aluno** |

**Break-even de infra: 1 cliente Premium já cobre.** Mas:

| Meta de receita | Modelo fixo atual | Híbrido (cen. B §5.2, ~R$ 850 médio) |
|---|---|---|
| R$ 3.000/mês | 10 clientes | ~4 clientes |
| R$ 10.000/mês | **34 clientes Premium** | ~12 médios **ou 1 rede** (R$ 24,5k) |
| R$ 30.000/mês | 100 clientes | ~35 médios **ou 2 redes** |

Com fundador solo, **34 clientes exigem 34 onboardings + 34 suportes**; o modelo por aluno/unidade alinha receita ao custo de servir (mais alunos = mais suporte = mais receita). **Por isso a resposta é: o preço fixo não sustenta crescimento; sustenta no máximo os custos diretos com 1–2 clientes.**

---

## 7. Recomendação

### Opções para decisão do dono

| | Opção | Descrição | Prós | Contras |
|---|---|---|---|---|
| **A** | Manter fixo + corrigir execução | R$ 299,90/999,90 como estão; consertar páginas, tabelas e gateway | menor risco, venda mais simples | receita teto baixa; redes = prejuízo potencial; continua subprecificando médio/grande |
| **B** | **Híbrido (recomendado)** | Free/Premium/Enterprise viram **camadas de recurso**; preço = **base + R$/aluno (com teto) + R$/unidade** | alinha com Sophia e mercado BR; cresce com o cliente; sem cliff; usa o metering já existente | exige: limite de unidades implementado, cobrança variável no Asaas, recálculo de preço na UI |
| **C** | Por aluno puro | como Sophia, sem base | o mais "justo" por valor | receita ≈ 0 em escola pequena; mais difícil de explicar; exige mesmo metering |

**Recomendação: B**, com as seguintes calibrações (**hipóteses — validar com dados do primeiro cliente**):

| | Free | Premium | Enterprise |
|---|---|---|---|
| Fórmula | R$ 0 até **50 alunos / 1 unidade** | **R$ 149 + R$ 2,50/aluno** (teto 500) **+ R$ 49/unidade** (até 5) | **a partir de R$ 499 + R$ 2,00/aluno + R$ 99/unidade**, mínimo R$ 1.499 |
| Ex.: 300 alunos / 1 unid. | — | **R$ 948** (149 + 750 + 49; vs. R$ 299,90 hoje) | — |
| Ex.: 800 alunos / 2 unid. | — | (→ Enterprise) **R$ 2.297** | R$ 2.297 |
| Ex.: 9.000 / 20 | — | — | **R$ 20.479** |

- **Desconto anual 16,7%** (manter; corrigir o doc que diz 15%) — melhora cash flow e retenção.
- **Taxa de implantação única** (migração de dados): R$ 500–1.500 — o mercado cobra (`Pesquisa…:100`), nós cobramos R$ 0.
- **Add-ons depois** (WhatsApp/SMS R$ 29,90 como âncora de mercado, relatórios avançados, API dedicada) — conforme `monetization-strategy/design.md` (não fragmentar antes de estabilizar billing).

### Estratégia do primeiro cliente

**Não otimizar preço, otimizar aprendizado:** oferecer **preço-piloto fechado** (ex.: R$ 399–499/mês por 6 meses) com cláusula de revisão para o modelo híbrido. O piloto gera os dados que faltam (alunos reais, unidades, horas de suporte) para calibrar R$/aluno antes de publicar a tabela.

---

## 8. Bloqueadores de execução (independem da opção escolhida)

| # | Item | Evidência | Esforço |
|---|---|---|---|
| 1 | **Asaas em sandbox na produção** → trocar `Asaas__ApiBaseUrl` para `https://api.asaas.com/v3` + chave de produção + webhook token no painel | Render env vars (produção) vs `activate-gateways.md:121` | config (meio-dia, com pendência manual do painel) |
| 2 | **Página `/pricing` com placeholder em inglês** (~30 strings) e Free exibido como "Price On Request" | `i18n-data.ts:752-795`; `pricing-page.component.html:61-99` | 0,5–1 dia |
| 3 | **3 tabelas de preço divergentes** → puxar tudo da API (cards ✅, tabela de comparação e tela interna ❌) | `pricing-page.component.ts:31-45`; `subscriptions.component.html:35-60` | 1 dia |
| 4 | **Limite de unidades nunca aplicado** (`EnsureSchoolUnitLimitAsync` sem callers) — pré-requisito de qualquer cobrança por unidade | grep: 0 chamadas fora da definição | 0,5 dia + teste |
| 5 | **Nenhuma feature é bloqueada por plano** → sem gatilho de upgrade além de >50 alunos | `CheckSubscriptionFeatureAsync` sem consumidor; UI não gateia | 1–2 dias (middleware + UI) |
| 6 | **`Entitlement:Enforce` off** — e **cuidado:** ligar hoje bloquearia o plano Free (trial de 14 d vencido = expirado, sem conversão para "Free ativo"; Asaas rejeita assinatura de R$ 0, spec `asaas-plan-catalog`) | `SubscriptionEntitlementEvaluator.cs:31-38`; `MigrateExistingTenantsToFreePlanAsync` | definir regra trial→Free antes de ligar |
| 7 | **Desconto anual 15% (doc) vs 16,7% (real)** e oferta do Free divergente (portal do responsável) | `docs/plans/pricing-page.md:38` vs seeder | 10 min |
| 8 | **Sem taxa de implantação** no funil de vendas | inexistente no checkout | decisão comercial |

---

## 9. Próximos passos

1. **Dono decide** entre A (manter fixo), **B (híbrido — recomendado)** ou C (por aluno puro) e aprova os números-piloto.
2. Change aberto: **`pricing-model-and-commercial-surfaces`** (proposal + design + deltas em
   `subscription-model`/`public-presence`/`payment-gateways`) — a implementação segue o `tasks.md`
   na ordem (fase 1 independe da decisão; fase 2 só após a escolha).
3. Em paralelo (não depende da decisão): **itens 2, 3 e 7** da §8 — consertar as superfícies comerciais para o primeiro cliente ver preço coerente.
4. Antes de qualquer cobrança real: **item 1** (gateway de produção) + decisão sobre **item 6** (entitlement × Free).
5. Calibrar R$/aluno com o **primeiro cliente piloto** antes de publicar tabela por aluno.

## 10. Pesquisa de preços de concorrentes (26/11/2026)

Verificação direta nas páginas dos fornecedores (busca web indisponível neste ambiente — Google/
Bing/DDG/Brave bloquearam ou degradaram; WPensar não respondeu).

| Concorrente | Modelo | Preço público verificado |
|---|---|---|
| **Quality** | base + por aluno | Básico **R$ 99/mês + R$ 4,99/aluno**; Completo **R$ 199/mês + R$ 6,99/aluno** |
| **DKSoft** | fixo, usuários ilimitados | Local **R$ 96,50**; Online **R$ 126,50**; Online+ **R$ 196,20/mês**; add-ons R$ 9,90–29,90. *"Não cobramos por aluno e não há limite de cadastros"* |
| **Activesoft** | Básico/Padrão/Avançado | sem preço público; cobra **implantação + migração** além da mensalidade; valor varia com nº de alunos |
| **SophiA** (ex-Primasoft) | base + por aluno + por unidade | não publica (consultivo) — referência do dono |
| **Sponte / Didatiko** | consultivo | sem preço público |

**Leitura**: o mercado BR tem os dois polos vivos (fixo DKSoft × por aluno Quality); o segmento
médio/grande é consultivo e cobra implantação à parte. O **híbrido (B)** fica entre os polos e é o
que sustenta crescimento sem cliff. Detalhe completo em
`openspec/changes/pricing-model-and-commercial-surfaces/design.md`.
