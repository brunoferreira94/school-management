# Design — modelo de preços e superfícies comerciais

Data: 2026-11-26
Status: draft (pesquisa de mercado concluída; decisão A/B/C pendente)

## 1. Contexto

A auditoria (`docs/auditoria-precos.md`) comparou o modelo atual (preço fixo por plano) com a
referência de mercado usada na pesquisa original (SophiA, antiga Primasoft: **base + por aluno +
por unidade**). Para calibrar a decisão, foi feita uma **pesquisa de preços de concorrentes em
26/11/2026**, com verificação direta nas páginas dos fornecedores.

## 2. Pesquisa de preços de concorrentes (26/11/2026)

### 2.1 Metodologia e limitações

- Busca: o `websearch` do harness estava sem resultados; Google/Bing/DuckDuckGo/Brave/Ecosia
  bloquearam ou degradaram (captcha, IP, respostas de dicionário) a partir deste IP. A verificação
  foi feita **abrindo as páginas de preço de cada fornecedor** (Chrome headless + Jina Reader) e
  lendo o conteúdo publicado.
- WPensar: site não respondeu deste ambiente (timeout de conexão) — sem dado verificado.
- Preços consultados em 26/11/2026; mercado muda, registrar a data junto do número.

### 2.2 Resultado

| Concorrente | Modelo | Preço público verificado | Fonte |
|---|---|---|---|
| **Quality** | base + por aluno | **Básico R$ 99/mês + R$ 4,99/aluno**; **Completo R$ 199/mês + R$ 6,99/aluno** | `sistemaquality.com.br/quanto-custa-sistema-para-escolas/` |
| **DKSoft** | fixo, usuários ilimitados | **Local R$ 96,50/mês**; **Online R$ 126,50/mês**; **Online+ R$ 196,20/mês**; add-ons R$ 29,90 e R$ 9,90/mês. Frase literal: *"Não cobramos por aluno e não há limite de cadastros"* | `dksoft.com.br/adquirir.php` |
| **Activesoft** | planos Básico/Padrão/Avançado | sem preço público; *"o investimento varia conforme as necessidades… fatores como número de alunos"*; **cobra implantação e migração de dados** além da mensalidade | `activesoft.com.br/planos/` |
| **SophiA** (ex-Primasoft) | base + por aluno + por unidade | não publica preço (venda consultiva, "demonstração gratuita") | `sophia.com.br` + informação do dono |
| **Sponte** | consultivo | sem preço público | `sponte.com.br` |
| **Didatiko** | consultivo | sem preço público | `didatiko.com.br` |

### 2.3 Leitura

1. **O mercado brasileiro tem os dois polos vivos**: fixo (DKSoft, R$ 96–196/mês, "não cobramos
   por aluno") e por aluno (Quality, R$ 99 + R$ 4,99). Não existe um padrão único.
2. **O segmento médio/grande é consultivo** (Sponte, SophiA, Didatiko, Activesoft): preço sob
   proposta, influenciado por número de alunos, e **taxa de implantação/migração cobrada à parte**
   — nós cobramos R$ 0.
3. **Add-ons são receita real** no modelo fixo (DKSoft: WhatsApp/app/e-mail a R$ 9,90–29,90/mês).
4. O modelo **híbrido (Opção B)** fica entre os polos: base acessível (competindo com o DKSoft na
   porta de entrada) + variável por aluno/unidade (competindo com Quality/SophiA no crescimento).

## 3. Opções (resumo da §7 da auditoria)

| | Opção | Descrição | Prós | Contras |
|---|---|---|---|---|
| **A** | Manter fixo + corrigir execução | R$ 299,90 / R$ 999,90 como estão; consertar páginas, tabelas e gateway | menor risco; venda simples | receita teto baixa; redes grandes = prejuízo potencial; subprecifica médio/grande |
| **B** | **Híbrido (recomendado)** | Free/Premium/Enterprise viram **camadas de recurso**; preço = **base + R$/aluno (com teto) + R$/unidade** | alinha com Sophia e com os dois polos do mercado; cresce com o cliente; sem cliff; usa o metering já existente | exige limite de unidades implementado, cobrança variável no Asaas e recálculo de preço na UI |
| **C** | Por aluno puro | como Sophia, sem base | "justo" por valor | receita ≈ 0 em escola pequena; mais difícil de explicar; exige o mesmo metering |

**Recomendação: B**, com calibração-piloto (hipóteses a validar com o primeiro cliente).
Exemplos preliminares desta tabela foram **supersetidos pela calibração aprovada na §6** (faixa de
entrada plana):

| | Free | Premium | Enterprise |
|---|---|---|---|
| Fórmula | R$ 0 até **50 alunos / 1 unidade** | **R$ 149 + R$ 2,50/aluno** (teto 500) **+ R$ 49/unidade** (até 5) | **a partir de R$ 499 + R$ 2,00/aluno + R$ 99/unidade**, mínimo R$ 1.499 |
| Ex.: 300 alunos / 1 unid. | — | **R$ 524** (149 + 150×2,50) | — |
| Ex.: 800 alunos / 2 unid. | — | (→ Enterprise) | **R$ 1.499** (mínimo) |
| Ex.: 9.000 alunos / 20 unid. | — | — | **R$ 19.182** |

- **Desconto anual 16,7%** (manter; corrigir o doc que diz 15%).
- **Taxa de implantação única** (migração de dados): R$ 500–1.500 — o mercado cobra (Activesoft),
  nós cobramos R$ 0.
- **Add-ons depois** (WhatsApp/SMS a R$ 29,90 como âncora de mercado, relatórios avançados, API
  dedicada) — conforme `monetization-strategy/design.md`; não fragmentar antes de estabilizar billing.

## 4. Decisões

1. ~~**Dono escolhe A, B ou C**~~ → **26/11: aprovada a Opção B (híbrido) com faixa de entrada plana**
   (ver §6).
2. ~~Regra **trial→Free**~~ → **26/11 (dono): trial vencido = somente-leitura**. Leituras seguem
   livres (anti-retention), escritas retornam `402 subscription_expired` e a UI abre um aviso de
   oferta para assinar (upsell) em vez de erro genérico. Ver §6.1. **Decidido; falta implementar o
   upsell na UI antes de ligar `Entitlement:Enforce`.**
3. ~~**Feature gating**~~ → **26/11 (dono): conjunto do Free confirmado**. Liberações:

   | Recurso | Free | Premium/Enterprise |
   |---|---|---|
   | Gestão de turmas/alunos/notas/frequência | ✅ | ✅ |
   | Portal **admin** básico | ✅ | ✅ |
   | Portal do **responsável** | ❌ | ✅ |
   | Módulo financeiro / cobranças | ❌ | ✅ |
   | Analytics avançado | ❌ | ✅ |
   | API pública | ❌ | ✅ |
   | Suporte prioritário | ❌ | ✅ |
   | Branding personalizado | ❌ | ✅ |

   Corresponde aos flags do catálogo (`HasFinancialModule`, `HasAdvancedAnalytics`, `HasApiAccess`,
   `HasPrioritySupport`, `HasCustomBranding`). Tasks 2.7 implementa o enforcement.
4. **Taxa de implantação**: cobrar ou não no primeiro cliente. **Pendente** (recomendação: R$ 0 no
   piloto, como arma de conversão).

## 5. Riscos

- **Ligação do `Entitlement:Enforce` sem a regra trial→Free** bloqueia o Free (spec
  `asaas-plan-catalog`: Asaas rejeita assinatura de R$ 0). Fase 2 trata antes de ligar.
- **Cobrança variável no Asaas**: a spec `asaas-plan-catalog` mostra que updates de valor não
  propagam para charges já geradas — o valor variável precisa nascer correto na criação/ciclo.
- **Percepção de preço**: "a partir de" + simulador evita que o cliente veja o teto como preço.
- **Primeiro cliente**: otimizar aprendizado, não preço — piloto fechado (R$ 399–499/mês por 6
  meses) com cláusula de revisão para o modelo híbrido.

## 6. Decisão do dono (26/11) — Opção B com faixa de entrada plana

**Aprovado**: modelo híbrido, com a base cobrindo uma faixa de alunos (formato mais fácil de
vender e de converter de sistemas por aluno):

| Plano | Preço | Inclui | Variável |
|---|---|---|---|
| **Free** | R$ 0 | 50 alunos, 1 unidade | — |
| **Premium** | **R$ 149/mês** | **150 alunos + 1 unidade** | R$ 2,50/aluno adicional (teto 500); R$ 49/unidade adicional (até 5) |
| **Enterprise** | **R$ 499/mês** | **500 alunos + 3 unidades** | R$ 2,00/aluno adicional; R$ 99/unidade adicional; **mínimo R$ 1.499** |

- **Desconto anual 16,7%** (manter; corrigir o doc que diz 15%).
- **Migração/implantação R$ 0** no piloto — arma de conversão (concorrentes consultivos cobram à parte).
- **Add-ons depois** (WhatsApp/SMS a R$ 29,90 como âncora de mercado).
- **Piloto do 1º cliente**: R$ 399–499/mês por 6 meses, com cláusula de revisão para a tabela acima.

### 6.1 Exemplos (para conferência das contas)

| Escola | Alunos | Unid. | Híbrido aprovado | Comparação |
|---|---|---|---|---|
| Pequena | 80 | 1 | **R$ 149** | DKSoft R$ 126,50 · Quality Básico R$ 498 |
| Média | 300 | 1 | **R$ 524** (149 + 150×2,50) | Quality Básico R$ 1.596 |
| Média+ | 500 | 1 | **R$ 1.024** (149 + 350×2,50) | Quality Completo R$ 2.594 |
| Grande | 800 | 2 | **R$ 1.499** (mínimo Enterprise) | consultivo R$ 4.000+ |
| Rede | 9.000 | 20 | **R$ 19.182** (499 + 8.500×2 + 17×99) | hoje R$ 999,90 fixo |

### 6.2 Guardrails de lucro

1. **Piso por tenant** (R$ 149) cobre infra + suporte mínimo.
2. **Teto por aluno** evita susto e churn.
3. Custo marginal por aluno ≈ 0; o custo real é suporte/onboarding → **1 rede vale mais que 20
   escolas pequenas**.
4. **Sem cliff**: o 501º aluno custa R$ 2,50 (não R$ 700).

## 7. Estado pós-trial — somente leitura com oferta de upgrade (26/11)

**Decisão do dono**: com o trial de 14 dias vencido sem conversão, o tenant **continua lendo** todos
os seus dados (anti-retention) e **toda ação de escrita abre um aviso de oferta para assinar** —
não um erro genérico.

- **Backend**: já existe em `EntitlementEnforcementMiddleware` — escrita bloqueada com
  `402 Payment Required`, corpo `{ error: "subscription_expired", reason, message }`. A flag
  `Entitlement:Enforce` está `false` em produção/staging; o rollout depende do upsell da UI.
- **UI (fase 2)**: interceptar o `402 subscription_expired` no cliente HTTP e abrir um modal de
  upgrade com planos e CTA para `/checkout/:plan` (ou "falar com vendas" para Enterprise), mantendo
  o usuário na tela e os dados intactos.
- **Regra de conversão**: o modal é o gatilho de upgrade — substitui o "bloqueio silencioso" de hoje.
- **Rollout**: só ligar `Entitlement:Enforce` depois do modal aprovado e testado.