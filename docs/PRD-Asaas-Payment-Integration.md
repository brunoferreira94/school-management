# PRD: Integração de Pagamentos com Asaas

## 1. Objetivo

Desenvolver a integração de pagamentos com o provedor Asaas de forma a permitir cobrança self-service de assinaturas e planos, reconciliar status de pagamento via webhook, e preparar o sistema para suportar o portal financeiro de responsáveis/alunos.

O documento deve orientar a equipe a implementar a solução em modo autopilot, aproveitando o que já existe e identificando claramente os próximos passos.

## 2. Contexto atual

O repositório já contém uma integração parcial com Asaas:

- `AsaasCheckoutService` implementa `IPaymentCheckoutService` e pode criar cobranças no Asaas.
- `SubscriptionsController` expõe `POST /api/subscriptions/checkout-intents` para iniciar checkout e `POST /api/subscriptions/webhooks/asaas` para receber notificações.
- `AsaasOptions` configura `ApiBaseUrl`, `ApiKey`, `TimeoutSeconds` e `WebhookToken`.
- `appsettings.Development.json` e `appsettings.Testing.json` já possuem o bloco `Asaas` configurável.
- Existe documentação de webhook em `school-management-api/docs/WEBHOOK_ASAAS_SETUP.md`.
- O serviço já resolve cliente por CPF/CNPJ, cria customer e cria cobrança PIX no Asaas.

### Estado de implementação atual

O que já está disponível:

- checkout self-service para o plano `Premium`
- cobrança criada no Asaas com `billingType = PIX`
- webhook mínimo que valida `asaas-access-token`
- persistência de status de assinatura no domínio via `ExternalSubscriptionId`

Gaps identificados:

- suporte limitado a PIX e a um fluxo de assinatura `Premium`
- integração incompleta com o módulo financeiro e boletos do sistema
- falta de persistência explícita de `boletoUrl`, `paymentUrl` e `paymentStatus` associados a invoices/parcelas
- ausência de UI dedicada ao pagamento e à consulta de cobranças no portal familiar
- necessidade de testes de integração específicos para Asaas
- suporte incompleto a múltiplos eventos de webhook (vencido, recebido, cancelado, reembolsado)

## 3. Escopo do PRD

### In scope

- Estabilizar o fluxo de pagamento Asaas já iniciado.
- Suportar cobrança por `PIX` e `BOLETO` no MVP.
- Garantir webhook seguro e idempotente.
- Registrar mapeamento entre cobrança Asaas e assinatura local.
- Expor dados de cobrança no portal de autoatendimento.
- Criar documentação de configuração e testes de sandbox.

### Out of scope

- Implementação de fluxo de cartão de crédito completo (pode ser fase 2).
- Conciliação bancária offline avançada.
- API de pagamento de terceiros além do Asaas.
- Suporte a cobranças recorrentes complexas (pro-rate, upsell, downgrade) além de ciclo mensal/anual básico.
- Integração com ERP ou sistemas contábeis externos.

## 4. Sucesso esperado

### Métricas

- `80%` do fluxo de cobrança Asaas coberto por código e testes automatizados.
- `100%` de eventos webhook relevantes recebidos e processados com idempotência.
- `0` segredos Asaas expostos em código fonte.
- Portal financeiro capaz de mostrar pelo menos um link de boleto/PIX a partir do backend.
- Documentação operacional completa para configuração sandbox e produção.

### Critérios de aceitação

- O backend cria uma cobrança Asaas válida e retorna `checkoutUrl`.
- O webhook valida `asaas-access-token` e atualiza o status local.
- O sistema mantém `ExternalSubscriptionId` e `ExternalCustomerId` no domínio.
- A cobrança pode ser encontrada e exibida no portal financeiro.
- O processo está documentado em `docs/WEBHOOK_ASAAS_SETUP.md` e no novo PRD.

## 5. Proposta de implementação

### Fase 1: Estabilização da integração existente

1. Revisar `AsaasCheckoutService`.
   - Validar e refinar tratamento de erros HTTP.
   - Adicionar suporte a `billingType` dinâmico (`PIX`, `BOLETO`).
   - Incluir campo `PaymentUrl` / `BoletoUrl` na resposta quando disponível.
   - Padronizar nomes de `externalReference` e `externalSubscriptionId`.
2. Revisar `SubscriptionsController`.
   - Confirmar endpoint de checkout e webhook.
   - Adicionar ou documentar testes unitários para `CreateCheckoutIntent` e `ProcessAsaasWebhook`.
3. Garantir configuração segura.
   - Validar `AsaasOptions` no startup.
   - Documentar uso de user secrets / env vars para `ApiKey` e `WebhookToken`.

### Fase 2: Conexão com o domínio financeiro / tenant

1. Mapear a cobrança externa para as entidades locais.
   - Persistir `ExternalSubscriptionId`, `ExternalCustomerId`, `ExternalReference` em `TenantSubscription` ou `Installment` conforme modelo.
2. Expandir webhook para status financeiros.
   - `payment.received` / `payment.confirmed` → status pago.
   - `payment.overdue` → status vencido.
   - `payment.cancelled` / `payment.refunded` → status cancelado/refund.
3. Criar endpoint de leitura de cobranças/boletos.
   - possivelmente em `GET /api/portal/payments` ou `GET /api/finance/asaas-invoices`.
4. Adicionar testes de integração populares para fluxo completo.

### Fase 3: Portal e self-service

1. Expor dados de cobrança no portal familiar.
   - `boletoUrl`, `dueDate`, `amount`, `status`, `paymentUrl`, `provider`.
2. Garantir experiência mobile/PWA.
3. Suportar download de boleto e apresentar status em tempo real.
4. Ligação com notificações de pagamento vencido/aviso.

### Fase 4: Rollout e observabilidade

1. Adicionar métricas de webhook e checkout no backend.
2. Registrar logs de auditoria para criação de cobrança e evento webhook.
3. Publicar a documentação operacional atualizada.
4. Preparar checklist de rollout para produção.

## 6. Arquitetura proposta

### Fluxo de dados

1. Usuário seleciona `Premium` no frontend.
2. Frontend chama `POST /api/subscriptions/checkout-intents` com:
   - `Plan`
   - `BillingCycle`
   - `Name`
   - `Email`
   - `Document`
   - `TotalPrice`
   - opcional: `BillingType`
3. `AsaasCheckoutService` cria ou encontra cliente no Asaas.
4. Cria cobrança Asaas com `billingType` e `externalReference`.
5. Backend retorna `CheckoutIntentResponse` com `CheckoutUrl` e status.
6. Cliente paga via Asaas.
7. Asaas envia webhook para `/api/subscriptions/webhooks/asaas`.
8. Backend valida `asaas-access-token`, mapeia `ExternalSubscriptionId`, atualiza estado local.
9. Portal familiar consome endpoint local e mostra boleto/PIX e status.

### Componentes

- `AsaasOptions`
- `IPaymentCheckoutService`
- `AsaasCheckoutService`
- `SubscriptionsController`
- `TenantSubscriptionRepository`
- `SubscriptionPlanRepository`
- frontend de checkout e portal financeiro
- `WEBHOOK_ASAAS_SETUP.md`

## 7. Implementação em modo autopilot

### O que já podemos entregar imediatamente

- Fase 1 completa com correções no código existente.
- Fase 2 iniciada com persistência de IDs externos e status no domínio.
- Documentação e testes de webhook.

### Tarefas que podemos iniciar agora

1. Atualizar `CreateCheckoutIntentRequest` para aceitar `BillingType`.
2. Ajustar `AsaasCheckoutService` para:
   - suportar `BOLETO` e `PIX`
   - retornar `checkoutUrl` e `boletoUrl` quando disponíveis
   - gerar `externalReference` e mapear `externalSubscriptionId`
3. Garantir que `SubscriptionsController.ProcessAsaasWebhook` trata status de pagamento adicionais.
4. Criar testes unitários para a camada de serviço e para o webhook.
5. Revisar `appsettings.*.json` e `AsaasOptions`.
6. Documentar no README e na pasta `docs` o passo a passo de configuração sandbox e produção.

### Itens que precisarão de validação manual durante rollout

- Registro de webhook no painel Asaas.
- Configuração de secrete manager / env vars em produção.
- Teste de fluxo de boleto real no sandbox Asaas.

## 8. Dependências

- Conta Asaas ativa (sandbox e produção).
- Chave de API Asaas válida.
- Token de webhook seguro configurado.
- Ambiente público acessível para webhook (ngrok, túnel ou domínio real).
- Documentação de API do Asaas para event type e payload atualizados.

## 9. Riscos e mitigação

- `Risco:` webhook não chegar devido a URL pública incorreta.
  - `Mitigação:` usar ngrok em sandbox e verificar histórico no dashboard Asaas.
- `Risco:` `billingType` incompatível com Asaas.
  - `Mitigação:` começar com `PIX` e `BOLETO` apenas; validar com sandbox.
- `Risco:` divergência entre valor cobrado e valor do plano.
  - `Mitigação:` continuar com validação de `TotalPrice` no backend.
- `Risco:` segredos vazarem em dev config.
  - `Mitigação:` documentar claramente o uso de user secrets e env vars.

## 10. Tempo e entregas sugeridas

### Sprint 1 (1-2 dias)

- Completar Fase 1: estabilizar checkout e webhook.
- Adicionar testes unitários.
- Atualizar documentação de configuração.

### Sprint 2 (2-3 dias)

- Conectar cobrança Asaas ao domínio local.
- Expor cobrança no portal de pagamento.
- Adicionar testes de integração básicos.

### Sprint 3 (1-2 dias)

- Revisar rollout de produção.
- Adicionar métricas, logs e validação operacional.
- Fechar documentação final.

## 11. Recomendação de arquivo de entrega

Criar ou atualizar os seguintes artefatos:

- `docs/PRD-Asaas-Payment-Integration.md` (este documento)
- `school-management-api/docs/WEBHOOK_ASAAS_SETUP.md`
- `school-management-api/src/SchoolManagement/Services/AsaasCheckoutService.cs`
- `school-management-api/src/SchoolManagement/Controllers/Finance/SubscriptionsController.cs`
- `school-management-api/src/SchoolManagement/Options/AsaasOptions.cs`
- `school-management-api/src/SchoolManagement.Configuration/RepositoryAndInfrastructureRegistration.cs`
- testes em `school-management-api/tests` ou `SchoolManagement.Tests`
- frontend checkout/portal em `school-management-ui/src/app/features/portal` ou `finance`

## 12. Resumo do que pode ser implementado agora

- Implementação do checkout Asaas para `Premium` está disponível e deve ser completada.
- Podemos iniciar a reconciliação de status de webhook imediatamente.
- O campo `WebhookToken` e o endpoint já existem; o foco agora é adicionar cobertura de status e rastreabilidade.
- O portal financeiro pode ser conectado usando os dados de cobrança que já são retornados.

> A conclusão deste PRD permite que a implementação avance em modo autopilot usando o código existente como base, com entregas incrementais claras.
