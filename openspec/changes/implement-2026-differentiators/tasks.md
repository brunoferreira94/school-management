# Tasks — Implementar diferenciais 2026

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
