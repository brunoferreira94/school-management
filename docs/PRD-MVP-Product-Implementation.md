# PRD: MVP Completo do Sistema de Gestão Escolar

## 1. Objetivo

Entregar o MVP completo do sistema de gestão escolar com todas as capacidades faltantes identificadas na apresentação de produto. O foco é transformar a solução atual em um produto comercializável que cobre:

- pagamentos e conciliação financeira
- portal familiar e mobile/PWA
- dashboards e BI básicos
- funcionalidades pedagógicas avançadas
- integrações com o ecossistema escolar
- maturidade de produto e operação

## 2. Contexto

O produto já possui um núcleo técnico sólido:

- backend em ASP.NET Core 10 com arquitetura em camadas
- frontend Angular com experiência administrativa e Auth0
- módulos acadêmicos para anos letivos, turmas, cursos e planos financeiros
- notificações e comunicação multi-canal
- analytics MVP de retenção e inadimplência
- integração inicial com Asaas para cobranças

Mas o MVP ainda não entrega a experiência completa para clientes e usuários finais.

## 3. Escopo do MVP

### 3.1. Integração de pagamentos

#### Objetivo

Suportar cobrança self-service e reconciliação de receitas via Asaas, com foco em Pix e boleto.

#### Recursos a implementar

- Suporte a `billingType` dinâmico: `PIX` e `BOLETO`
- Criação de checkout e cobrança no Asaas para planos/parcelas
- Persistência de `ExternalSubscriptionId`, `ExternalCustomerId` e `ExternalReference`
- Tratamento de eventos de webhook: `payment.received`, `payment.confirmed`, `payment.overdue`, `payment.cancelled`, `payment.refunded`
- Validação segura do webhook via header `asaas-access-token`
- Endpoint para consulta de cobranças e boletos no backend
- Exposição de dados de boleto/PIX no portal familiar
- Documentação e configuração de sandbox/produção

#### Critérios de aceite

- Criar cobrança Asaas válida e retornar `checkoutUrl`/`boletoUrl`
- Atualizar status local via webhook idempotente
- `PIX` e `BOLETO` aparecem como opções do checkout
- Portal familiar mostra link ou PDF de boleto quando disponível

### 3.2. Portal familiar e mobile

#### Objetivo

Criar a experiência de self-service para responsáveis e alunos consultarem finanças, notas, frequência e comunicados, com interface responsiva ou PWA.

#### Recursos a implementar

- Área dedicada "Minha Área" para responsável/aluno
- Seção de pagamentos com boletos, status e detalhes de parcelas
- Seção de notas e frequência com histórico de desempenho
- Seção de comunicados e mensagens relevantes
- Perfil do usuário e dados pessoais básicos
- Autenticação segura com roles e permissões
- Layout mobile-friendly e PWA-friendly
- Conexão com endpoint/backend de `portal` ou `my-area`

#### Critérios de aceite

- Usuário autenticado acessa portal familiar e vê dados de financeiro, notas e frequência
- Layout responde em telas mobile
- Não exibe dados de outros alunos/tenants

### 3.3. Dashboards e BI

#### Objetivo

Entregar visibilidade administrativa com indicadores operacionais chave.

#### Recursos a implementar

- Dashboard de inadimplência com ageing buckets
- Dashboard de retenção de alunos por coorte
- Indicadores de matrícula e presença
- Filtros por período e tenant
- Cache ou views materializadas para desempenho inicial
- Visualização de métricas de uso/limites do plano

#### Critérios de aceite

- Dashboard carrega com dados reais e filtros funcionais
- Indicadores de inadimplência e retenção atualizam com filtros
- Dashboard administrativo está disponível para usuários com permissão

### 3.4. Funcionalidade pedagógica avançada

#### Objetivo

Aprimorar o módulo pedagógico com avaliações baseadas em competências e relatórios de progresso.

#### Recursos a implementar

- Avaliações por competência com peso e domínio de habilidade
- Lançamento de notas com base em competências
- Cadastro de atividades/tarefas pedagógicas
- Relatórios de progresso por aluno e competência
- Visualização de desempenho por turma e por habilidade

#### Critérios de aceite

- Professor cria avaliação com competências e pesos
- Notas associadas a competências são armazenadas e exibidas
- Relatório de progresso mostra evolução por aluno/competência

### 3.5. Integrações com ecossistema escolar

#### Objetivo

Abrir o sistema para integrar com outros sistemas escolares e bibliotecas digitais.

#### Recursos a implementar

- APIs REST públicas documentadas
- Endpoints de consulta de dados de aluno, turma e financeiro para parceiros
- Contract tests básicos para API externa
- Conector de importação de dados legados via payloads CSV/JSON
- Mapeamento de integração com bibliotecas digitais e marketplaces educacionais

#### Critérios de aceite

- Existe documentação de API para integrações externas
- Parceiro pode consultar dados de aluno/autenticar via token
- Importação de dados legados funciona com validações claras

### 3.6. Maturidade de produto e operação

#### Objetivo

Preparar o MVP para validação comercial com onboarding, treinamento e modelo SaaS.

#### Recursos a implementar

- Documentação de onboarding de cliente piloto
- Guia de instalação/configuração para ambiente sandbox e produção
- Materiais de treinamento para secretaria e coordenadores
- Definição de modelo de preço inicial por aluno e módulos
- Checklists de rollout, suporte e SLA
- Atualização do roadmap comercial e estratégia de lançamento

#### Critérios de aceite

- Documentação de onboarding está disponível e testada
- Existe modelo comercial básico definido
- Processo de suporte e SLA está documentado

## 4. Requisitos e funcionalidades detalhadas

### 4.1. Pagamentos

- `POST /api/subscriptions/checkout-intents`
- `POST /api/subscriptions/webhooks/asaas`
- `GET /api/finance/asaas-invoices` ou equivalente
- Campos de retorno: `CheckoutUrl`, `BoletoUrl`, `PaymentStatus`, `Provider`, `Amount`, `DueDate`
- `AsaasOptions` com `ApiKey`, `WebhookToken`, `ApiBaseUrl`, `TimeoutSeconds`
- Serviço `AsaasCheckoutService` com suporte a `PIX` e `BOLETO`
- Registro e persistência de IDs externos no domínio de assinatura

### 4.2. Portal familiar

- Frontend `portal/dashboard`, `portal/payments`, `portal/grades`, `portal/attendance`
- `PortalService` consumindo endpoints de `my-area`
- Permissões para `student`, `guardian` e `admin`
- Exibição de boletos e links de pagamento seguros
- Atualização de preferências de notificações e consentimento

### 4.3. Dashboards e BI

- Serviço backend para métricas de inadimplência, coorte e presença
- UI de dashboard administrativo em Angular
- Filtros de período e tenant
- Uso de views SQL para desempenho
- Possível cache em memória ou agrupamentos pré-computados

### 4.4. Pedagogia avançada

- Entidade `Competency` ou equivalente
- CRUD de avaliações por competência
- Lançamento de notas vinculadas a habilidades
- Relatórios de progresso de alunos

### 4.5. Integrações externas

- Documentação OpenAPI atualizada
- API pública para consulta de dados de alunos/turmas/financeiro
- Token-based auth para parceiros
- Importação segura de payloads legados

### 4.6. Operação e suporte

- Guia de onboarding do cliente piloto
- Roadmap de pricing e FAQ
- Checklist de setup de ambiente e deploy
- Material de treinamento para suporte interno

## 5. Roadmap de entrega

### Sprint 1: Core de pagamentos e portal inicial

- Completar Asaas checkout e webhook
- Expor boleto/PIX no backend
- Criar portal familiar mínimo com section de pagamentos
- Documentar sandbox e webhook

### Sprint 2: Dashboards e BI

- Construir indicadores de inadimplência e retenção
- Entregar página de dashboard administrativo
- Garantir performance com cache/views

### Sprint 3: Pedagogia e integrações

- Implementar avaliações por competências e Tarefas
- Criar relatórios pedagógicos
- Documentar e expor APIs de integração

### Sprint 4: Maturidade de produto

- Finalizar onboarding e treinamento
- Definir pricing e modelo SaaS
- Publicar documentação operacional

## 6. Métricas de sucesso

- Pagamentos: cobrança Asaas em sandbox funcionando com webhook
- Portal: usuário final acessa dados financeiros e escolares
- BI: dashboard carrega e responde a filtros
- Pedagogia: avaliação por competência criada e exibida
- Integrações: API externa documentada e consumível
- Operação: onboarding e modelo de preço definidos

## 7. Dependências

- Conta Asaas com chaves sandbox/produção
- Auth0 para gerenciamento de usuários
- API pública acessível para webhooks e integrações
- Dados iniciais de clientes, alunos e planos
- PWA/Angular libraries para experiência mobile

## 8. Riscos e mitigação

- Escopo muito grande: priorizar pagamentos + portal primeiro
- Webhook Asaas não entregando eventos: usar sandbox e ngrok
- Dados sensíveis no portal: validar roles e tenant
- Performance de dashboards: usar views e cache
- Adoção lenta do MVP: documentar onboarding e piloto com clareza

## 9. Notas finais

Este PRD serve como plano de implementação completo do MVP e deve ser usado como referência para dividir a entrega em tarefas operacionais, commits e sprints. O objetivo é criar um produto que já possa ser apresentado a clientes e investidores com funcionalidades necessárias para operação e validação comercial.
