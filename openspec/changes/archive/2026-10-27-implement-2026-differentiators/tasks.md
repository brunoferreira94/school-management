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
- [x] **Checkout usa o gateway** (2026-10-25, fechado via `connect-gateway-checkout` + ajustes de hoje): a UI chama `POST /api/subscriptions/checkout-intents` (GatewayCheckoutRouter: PIX/BOLETO/CARNE → Asaas/Mock; cartão → Stripe/Mock) com o **slug** do plano; retorno do mock segue o fluxo interno (`demo-payments.local`) e o real redireciona ao hosted checkout. Pendente honesto: reconciliação por webhook real (chaves de staging)
- [x] **Cadastro self-service de escola** (fechado via changes `self-service-self-service-onboarding`/`self-service-registration` arquivadas): landing → `/cadastro/:plan` cria o tenant; specs `school-self-service-signup.cy.ts` + funnel live `school-funnel.cy.ts` (8/8)
- [x] **Trial automático**: provisionamento Free/trial na criação do tenant (`ITrialSubscriptionProvisioner`), assinatura já persistida no seed
- [x] **Landing pública** (archived `public-landing-page`, 2026-10-25): raiz `/` roteia a landing sem guard; early-redirect invertido (anônimo fica na landing, autenticado vai a `/home`); E2E `public-landing.cy.ts` 2/2
- [x] **Onboarding checklist**: progresso gravado no servidor via `POST /api/onboarding/progress` nos passos (turma criada, professores convidados, boletim visto) — verificado hoje no código (`onboarding.service.ts` chama `updateProgress` nos 3 marcos)
- [ ] Validar o funil completo em **staging** (Render) — hoje validado em local com API+seed demo (funnel live 8/8 com DB real); Render 402 (fatura pendente) bloqueia

## 1. BillingCadence (régua de cobrança)
- [x] Entidade/infra: `BillingCadenceRule` (D-3/hoje/D+2/D+5, ativo), `BillingCadenceOccurrence` (dedup por fatura+regra+data, com `SentChannels`) e `BillingCadenceRun` (log de execuções) + repos; migration `20261025184254_AddBillingCadence`
- [x] Serviço de engine (`BillingCadenceEngine`) com replay seguro (ocorrência persistida ANTES do envio; dedup por fatura+regra+data) e log de execuções (`BillingCadenceRun` com skip/fatal-notas); seeds padrão idempotentes por escola
- [x] Endpoints: `GET/PUT /api/billing-cadence/rules` (por escola, GET semeia defaults), `POST /api/billing-cadence/run` (manual/dry-run), `GET /api/billing-cadence/metrics` (por regra + canal; SLA de 3 dias via ocorrência→fatura paga), `GET /api/billing-cadence/runs`; `[Authorize(Policy = "Permission:finance.manage")]`
- [x] Notificações com link de pagamento: `IInvoicePaymentLinkProvider` + `MockInvoicePaymentLinkProvider` (demo-payments.local, espelha `MockPaymentCheckoutService`) — **honesto**: o provider real por billing type (PIX/boleto no Asaas / hosted checkout no Stripe) aguarda chaves de cobrança per-student; canal efetivo respeita consentimento do responsável (`IGuardianChannelConsentService`, WhatsApp exige opt-in → fallback e-mail)
- [x] Testes unitários: 7 xUnit (`BillingCadenceEngineTests`: lembrete gerado+link no body, dedup replay, dry-run, regra desativada, offset positivo +2, seeds padrão, sem duplicar seeds); suíte completa 718/0 (5 skips pré-existentes)
- [x] E2E `billing-cadence-flow.cy.ts` — **ao vivo** (API local + Postgres/seed, como `school-funnel`; sem UI para cadence): 6/6 (1 regras semeadas, 2 desativa/reativa auditável, 3 lembrete gerado→ocorrência, 4 dedup replay+run log, 5 dry-run não persiste, 6 métricas por regra+canal; setup determinístico/idempotente via `cy.exec`+psql no container, cleanup no after)

## 2. WhatsApp deep links (communications)
- [x] Handler de handoff: template por evento (inadimplência, publicação de notas, aviso) com consentimento e mascaramento de dados — 2026-10-27: `WhatsAppHandoffService` + POST /api/communications/whatsapp-handoff; mascaramento = sem CPF, primeiro nome do aluno; consentimento via IGuardianChannelConsentService
- [x] UI: botão "WhatsApp" no item de fatura (finance, `*can` finance.manage) → wa.me deep link com texto do template; fallback mostra motivo em toast
- [x] Testes E2E de handoff (deep link inicia da escola, não envio automático) — `whatsapp-handoff-export-trust.cy.ts` 2.3a/2.3b; **descobriu bug real**: FindGuardianAsync não buscava por CPF → consentimento de opt-in nunca aplicado (régua e handoff seguiam WhatsApp e o wa.me recebia CPF como telefone) — corrigido em GuardianChannelConsentService

## 3. AiDrafts (rascunhos com revisão)
- [x] Contrato do provedor de rascunhos (IAiDraftProvider + RiskScoreForDraft/ReportCardForDraft/WeeklySummaryForDraft) + MockAiDraftProvider determinístico p/ dev; consentimento de dados por escola (TenantAiConsent + endpoint GET/PUT /api/ai-drafts/consent)
- [x] 3 artefatos (POST /api/ai-drafts/generate): mensagem p/ responsável em risco (ancorada no RiskScore, score+fatores na mensagem e no data basis), comentário de boletim (média consolidada + status + nº de avaliações), resumo semanal do diretor (alunos em risco >= 60 + faturas em aberto)
- [x] Estado "review required" (PendingReview → Approved/Rejected) + audit trail (ReviewedBy/ByName/AtUtc/Note, OriginalContent imutável, EditedContent na aprovação) + BLOQUEIO de envio sem revisão (SendAiDraftCommand falha se != Approved) — 11 testes unitários (AiDraftServiceTests: consentimento recusa, 3 artefatos, revisão c/ edição, revisão duplicada recusada, envio bloqueado pending/rejected, envio aprovado enfileira c/ canal consentido, consentimento revogado entre aprovação e envio)

## 4. ProductTrust (transparência de confiabilidade)
- [x] Página "confiabilidade & mudanças": rota pública /confiabilidade (TrustStatusComponent) — changelog de releases, MTTR-30d (AuditLog 5xx→próximo <400), status das integrações (gateway de pagamento, e-mail, armazenamento) + checks de infraestrutura do health existente
- [x] Endpoint público de integridade: GET /api/support/trust-status (AllowAnonymous) reutilizando `/api/support/health` (IHealthService) + status das integrações por configuração + MTTR-30d do AuditLog + changelog (TrustStatusService/TrustStatusController)

## 5. DataPortability (export no cancel)
- [x] Export CSV/JSON com dados da fatura (ID, aluno, escola, plano, parcelas, data de vencimento, valores, status)
- [x] Progress tracking + checksum (tracking progresso da exportação)
- [x] Testes E2E do cancelamento com export bem-sucedido + re-export em grace window (`whatsapp-handoff-export-trust.cy.ts` 5.3: export com checksum + re-export idêntico; cancela → re-export na janela de 7 dias → recusa "janela de carência" quando expirada; endpoints POST /tenants/{id}/export + GET /tenants/{id}/export/{exportId})

## 6. SelfServiceOnboarding (cadastro self-service da escola)
- [x] Endpoint POST /api/onboarding/register-school (nome, escola, e-mail, CPF/CNPJ, senha) → cria tenant + usuário pending + assinatura Free/trial — validado AO VIVO: 201 com tenantId, 409 na duplicação, TenantSubscription Status=1 (Trial) com trialEnds 15 dias, transação atômica (tenant+unidade+conta+staff+ano letivo+trial+progresso, ITrialSubscriptionProvisioner); **fix bug real**: UserAccount.StudentCpf violava FK_Students (o CPF do diretor não é Student — todas as UserAccounts reais têm o campo NULL); campo removido do cadastro, dedup por Username/StudentCpf mantida
- [x] UI: rota /cadastro (escola) com validação, aceite dos termos e confirmação de e-mail — register-school-form.component com Validators.requiredTrue no acceptTerms (checkbox dedicado), rota hideLayout, mock de e-mail em dev via intercept; confirmação via toast/modal pós-201
- [x] Integração com o funil: `pricing` → `cadastro` → `checkout` (via `checkout-intents`) → onboarding guiado (2026-10-24: `/cadastro/:planId` não perdia mais o plano — após o cadastro navega direto para `/checkout/:planId`, que cria a checkout-intent e redireciona para o gateway quando `checkoutUrl` presente, ou segue para a tela interna de sucesso; e2e live do checkout aguarda chaves de gateway)
- [x] E2E: school-self-service-signup.cy.ts 3/3 (cadastro→trial→login→dashboard, pricing→/cadastro/planId→checkout, 409 sem sair da tela) + school-funnel.cy.ts AO VIVO 8/8 (landing, pricing com planos reais, fronteira de autenticação, login real, aquisição Premium, assinatura persistida, navegação completa sem 5xx, dashboard com dados reais) — a spec mock-based é contra a UI e2e (ng serve --configuration e2e), a ao vivo é API-driven; o bug da FK foi pego no teste ao vivo do register-school
