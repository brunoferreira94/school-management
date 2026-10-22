# Tasks — Implementar diferenciais 2026

## 0. Lacunas encontradas no teste do funil ao vivo (landing → aquisição → navegação)

Diagnóstico feito em 2026-10-22 com o funil real (API local + Postgres local + seed demo),
rodando a suíte `cypress/e2e/school-funnel.cy.ts` (8/8 verde após as correções abaixo).

### Corrigidos nesta rodada (commitar)
- [x] API: `SetupProgressRepository` recebia `DbContext` genérico → DI quebrava em Development (ValidateOnBuild) — trocado por `SchoolContext`
- [x] API: `AuditLoggingMiddleware` capturava `ITenantProvider` (scoped) no construtor → o binder do .NET 10 instancia no build com o root provider (congela o tenant da 1ª requisição) — resolvido por requisição
- [x] API: seed demo quebrava com "nested/concurrent transactions" (SchoolContext e AcademicContext compartilham a mesma conexão) — AcademicContext agora adere à transação via `UseTransactionAsync`
- [x] API: `SetupProgress` não existia no modelo EF (500 em `GET /api/onboarding/progress`) — `DbSet` adicionado + migration `AddSetupProgressEntity`
- [x] API: matriz de permissões incompleta no seed (faltavam `academic-years.*`, `teachers.read`, `timetables.*`, `assets.*`, `services.*`, `finance.manage`, `audit.read`, `owner.*`, `admin.*`) → 403 em várias telas — seed corrigido (Diretor/Coordenador/Professor)
- [x] API: refresh token rotacionado invalidava a 2ª chamada concorrente → 401 → logout spurio — janela de tolerância (`Jwt:RefreshGraceWindowSeconds`, default 30s) + 2 testes unitários
- [x] API: rate limit de auth era hardcoded (10/min) e travava o funil local — agora configurável (`RateLimiting:*`) com defaults iguais aos de produção
- [x] UI: `getValidToken()` sobrescrevia o token em memória com o valor antigo do storage → a sessão real era revertida para o stub `dev-token` e as chamadas saíam como anônimas — agora o storage nunca sobrescreve um token válido em memória
- [x] UI: `applyAuthResponse` persistia a sessão só no fim (depois de notificar `user$`) → corrida com o interceptor — agora persiste antes de notificar
- [x] UI: refresh falhando derrubava a sessão inteira — o interceptor mantém o access token válido e só desloga em 401 sem chance de refresh
- [x] UI: `listPlans()` fazia cast cru do payload (`monthlyPrice`/`annualPrice`) num modelo que espera `price` → todos os planos apareciam como "Sob consulta" e o checkout não carregava o plano — mapeamento corrigido (preço, intervalo, features, `maxTeachers`)
- [x] UI/infra: `ng serve` sem `--configuration` sobe com `environment.prod.ts` (sem `devAuth`) → qualquer rota guardada expulsa o usuário para o Auth0 hosted — suíte E2E passa a rodar com `--configuration e2e`

### Pendentes (bloqueiam o funil self-service)
- [ ] **Checkout não usa o gateway**: a UI chama `POST /api/subscriptions/tenant` direto, sem `checkout-intents` → nenhum link de pagamento (Asaas/Stripe/Mock) é gerado e nenhum webhook reconcilia. Ligar a UI ao `GatewayCheckoutRouter` (PIX/BOLETO/CARNE → Asaas; cartão → Stripe) e tratar o retorno do gateway no checkout
- [ ] **Não há cadastro self-service de escola**: o visitante anônimo não consegue criar conta de escola (só existe o portal do responsável) — implementar `self-service-onboarding` (spec criada neste change)
- [ ] **Sem plano trial automático**: conta nova não recebe assinatura Free/trial (hoje o seed cria plano, mas não assinatura)
- [ ] **Anglo: landing pública**: a raiz `/` redireciona para `/login` em build sem `devAuth`; no funil anônimo a "landing" é a tela de login — Landing/marketing page real ainda não existe
- [ ] **Onboarding checklist**: o modal de boas-vindas depende de `GET /api/onboarding/progress` (agora 200) mas o progresso ainda não é gravado no servidor em todos os passos
- [ ] Validar o funil completo em **staging** (Render) — hoje validado só em ambiente local com seed demo

## 1. BillingCadence (régua de cobrança)
- [ ] Entidade/infra: `BillingCadenceRule` (D-3/hoje/D+2/D+5, ativo), `BillingCadenceOccurrence` (dedup por fatura+regra+data) e repositórios
- [ ] Serviço de engine (`BillingCadenceEngine`) com replay seguro e log de execuções; integração foco de faturamento do Asaas
- [ ] Endpoints: `GET/PUT /api/billing-cadence/rules` (por escola), `POST /api/billing-cadence/run` (manual/dry-run), `GET /api/billing-cadence/metrics`
- [ ] Notificações com link de pagamento resolvido pelo `ISubscriptionGateway` de acordo com o billing type da fatura
- [ ] Testes unitários + E2E `billing-cadence-flow.cy.ts` (lembrete gerado, dedup, métricas)

## 2. WhatsApp deep links (communications)
- [ ] Handler de handoff: template por evento (inadimplência, publicação de notas, aviso) com consentimento e mascaramento de dados
- [ ] UI: botão "WhatsApp" no item de notificação/fatura → wa.me deep link com texto do template
- [ ] Testes E2E de handoff (deep link inicia da escola, não envio automático)

## 3. AiDrafts (rascunhos com revisão)
- [ ] Contrato do provedor de rascunhos (interface) + provedor mock p/ dev; circuito de consentimento de dados por escola
- [ ] 3 artefatos: mensagem p/ responsável em risco, comentário de boletim (report-builder), resumo semanal do diretor na tela de hoje
- [ ] Estado "review required" + audit trail de quem editou/aprovou; testes de bloqueio de envio sem revisão

## 4. ProductTrust (transparência de confiabilidade)
- [ ] Página "confiabilidade & mudanças": changelog de releases, MTTR-30d, status das integrações (gateways/notifications/storage)
- [ ] Endpoint público de integridade reutilizando `/api/support/health` + dados de reconciliação existentes

## 5. DataPortability (export no cancel)
- [ ] Gerador de pacote CSV/JSON (alunos, turmas, notas, faturas, documentos) no cancel-flow, com progresso e checksum
- [ ] Testes E2E do cancelamento com export bem-sucedido + re-export em grace window

## 6. SelfServiceOnboarding (cadastro self-service da escola)
- [ ] Endpoint `POST /api/onboarding/register-school` (nome, escola, e-mail, CPF/CNPJ, senha) → cria tenant + usuário pending + assinatura Free/trial
- [ ] UI: rota `/cadastro` (escola) com validação, aceite dos termos e confirmação de e-mail (mock em dev)
- [ ] Integração com o funil: `pricing` → `cadastro` → `checkout` (via `checkout-intents`) → onboarding guiado
- [ ] E2E: `school-self-service-signup.cy.ts` (cadastro → trial ativo → primeira navegação)
