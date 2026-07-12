# Tasks — Estratégia de Monetização

- [x] Research: market sizing and competitor analysis. (owner: product)
- [x] Define tiered pricing and feature mapping. (owner: product)
- [x] Docs: create pricing page and admin billing UI tasks. (owner: marketing)
- [ ] Legal: pricing terms and compliance. (owner: legal)
- [ ] Implementation plan: integrate billing gateway and meter usage. (owner: infra)
- [x] Backend: add canonical plans `Free`, `Premium`, `Enterprise` to subscription API and seed data. (owner: backend)
- [x] Backend: enforce tier limits for students, staff, school units, storage and feature gating. (owner: backend)
- [x] Backend: ensure Premium includes portal do responsável, notificações e módulo financeiro desde o primeiro dia. (owner: backend)
- [x] Backend: implement monetization KPIs endpoint with MRR, churn, ARPU, plan distribution, and conversion rate (owner: backend)
- [x] Backend: create integration tests for KPI endpoint validating metrics, plan distribution, and authorization (owner: qa)
- [x] Frontend: build pricing page UI using wireframe from `docs/plans/pricing-page.md`. (owner: frontend)
- [ ] Product: deliver Self-Service Portal for `Premium` and validate the onboarding value proposition. (owner: product)
- [ ] Infra: execute billing spike with Asaas and document webhook/contract requirements. (owner: infra)
- [ ] Marketing: prepare public pricing landing copy and FAQ based on the new plan definitions. (owner: marketing)

## Next execution slice

- [ ] Product: validar que o onboarding do Portal do Responsável sustenta a proposta de valor do `Premium` com evidência de ativação. (owner: product)
- [ ] Infra: transformar o spike de billing em contrato técnico MVP (criação de cobrança, status, webhook mínimo, idempotência). (owner: infra)
- [ ] Marketing: publicar copy final da landing com CTA principal no `Premium` e FAQ alinhado aos limites reais da API. (owner: marketing)
- [ ] Product/Finance: definir política operacional de trial, desconto anual e regra de upgrade/downgrade para o primeiro ciclo comercial. (owner: product)

## Implementation slices

### Slice 1 — Tela de planos

#### Goal

Entregar uma tela de planos que exponha `Free`, `Premium` e `Enterprise` de forma consistente com a API e com a proposta comercial pública.

#### Tasks

- [x] Frontend: consumir `GET /api/subscriptions/plans` e renderizar catálogo com `Free`, `Premium` e `Enterprise`. (owner: frontend)
- [x] Frontend: destacar `Premium` como plano recomendado com CTA principal. (owner: frontend)
- [x] Frontend: exibir limites e features por plano: alunos, staff, unidades, storage, portal, notificações, financeiro e analytics. (owner: frontend)
- [x] Frontend: tratar `Enterprise` como contato comercial em vez de compra self-service imediata. (owner: frontend)
- [ ] QA: validar estados de carregamento, erro e lista vazia. (owner: qa)

#### Acceptance criteria

- [x] Os 3 planos canônicos aparecem com dados coerentes com a API de assinaturas.
- [x] `Premium` aparece como oferta principal visual e comercial.
- [x] O CTA do `Enterprise` não tenta checkout automático e direciona para contato/vendas.

### Slice 2 — Tela de pagamento / checkout

#### Goal

Entregar o fluxo UI de seleção de ciclo e início de checkout para o `Premium`, sem acoplamento prematuro a regras finais de produção.

#### Tasks

- [x] Frontend: criar tela de checkout com resumo do plano selecionado, ciclo mensal/anual e valor final. (owner: frontend)
- [x] Frontend: incluir estado explícito para trial, desconto anual e observações comerciais. (owner: frontend)
- [x] Frontend: criar formulário mínimo do pagador com nome, email e documento quando necessário. (owner: frontend)
- [x] Frontend: integrar a tela a um endpoint backend de criação de intenção/ordem de cobrança. (owner: frontend)
- [ ] QA: validar fluxo feliz e erros de criação de cobrança. (owner: qa)

#### Acceptance criteria

- [x] O usuário consegue sair da tela de planos e chegar ao checkout do `Premium` sem ambiguidade.
- [x] O checkout exibe corretamente plano, ciclo e valor.
- [x] O frontend trata sucesso, erro e retry de criação da cobrança sem quebrar a navegação.

### Slice 3 — Integração com Asaas

#### Goal

Implementar o contrato técnico MVP com Asaas para criar cobrança, consultar status e receber webhook mínimo, mantendo rollout produtivo controlado.

#### Tasks

- [x] Backend/Infra: definir client Asaas com autenticação, timeout e tratamento de erro padronizado. (owner: backend)
- [x] Backend: criar endpoint para iniciar cobrança do `Premium` a partir do checkout. (owner: backend)
- [x] Backend: persistir identificadores externos da cobrança/assinatura no domínio de assinaturas. (owner: backend)
- [x] Backend: implementar endpoint de webhook mínimo com idempotência para atualização de status. (owner: backend)
- [x] Backend: implementar validação de segurança do webhook com token no header `asaas-access-token`. (owner: backend)
- [ ] Infra: configurar variáveis seguras e estratégia de segregação sandbox/produção. (owner: infra)
- [ ] QA: validar sandbox com pelo menos 1 criação de cobrança e 1 atualização de status por webhook ou simulação equivalente. (owner: qa)

#### Acceptance criteria

- [ ] O backend cria uma cobrança sandbox válida para o plano `Premium`.
- [x] O status externo da cobrança pode ser refletido na assinatura local.
- [x] O webhook mínimo é idempotente e não duplica atualização de estado.
- [ ] O contrato fica pronto para rollout controlado sem expor segredos em código ou config insegura.

## Premium value validation sprint

### Goal

Provar que o `Premium` entrega valor percebido cedo o suficiente para sustentar o preço de R$ 299,90/mês, usando o Portal do Responsável como a principal feature comercial do MVP.

### Execution tasks

- [ ] Product: definir o checklist de ativação do `Premium` com 3 marcos observáveis: login concluído, dashboard carregado, acesso real a dados do responsável. (owner: product)
- [ ] QA/Product: executar um fluxo completo em tenant `Premium` e registrar evidência de tempo até valor (TTV) do primeiro acesso ao portal. (owner: qa)
- [ ] Product: consolidar a hipótese comercial do `Premium` em uma frase única para pricing/landing: portal do responsável + notificações + financeiro + analytics operacional. (owner: product)
- [ ] Marketing: alinhar CTA principal e FAQ pública ao valor validado no onboarding real. (owner: marketing)
- [ ] Product/Analytics: registrar resultado da validação com status `validated`, `partial`, ou `failed` e próximos ajustes necessários. (owner: product)

### Premium activation checklist

#### Entry conditions

- [ ] Tenant está no plano `Premium` com assinatura ativa
- [ ] Responsável ou administrador de teste possui identidade válida no Auth0
- [ ] Ambiente aponta para API funcional e endpoints `/api/portal/profile` e `/api/portal/financial/summary` respondem autenticados

#### Observable milestones

- [ ] Marco 1: usuário conclui login sem erro de callback, audience ou role
- [ ] Marco 2: dashboard do portal carrega com sucesso sem loop de autenticação
- [ ] Marco 3: ao menos um dado real de valor é visível no portal (perfil, financeiro, dependentes ou equivalente)

#### Evidence to capture

- [ ] Registrar horário de início e horário do primeiro valor percebido para calcular TTV
- [ ] Anotar tenant, usuário de teste e plano ativo usados na validação
- [ ] Salvar evidência objetiva do resultado: resposta 200 de endpoint protegido ou captura do dashboard carregado

#### Decision output

- [ ] Classificar resultado como `validated`, `partial` ou `failed`
- [ ] Se `partial` ou `failed`, registrar o principal bloqueador entre onboarding, auth, dados ou narrativa comercial
- [ ] Se `validated`, extrair os 3 argumentos de valor que irão para pricing/landing/FAQ

### Acceptance criteria

- [ ] Um tenant `Premium` consegue concluir login e acessar o dashboard do portal sem bloqueio operacional.
- [ ] O primeiro valor percebido do portal ocorre em até 10 minutos a partir do início do fluxo guiado.
- [ ] O time consegue apontar ao menos 3 elementos de valor concretos do `Premium` já entregues no produto real.
- [ ] A pricing copy pública fica consistente com o que foi validado no onboarding e no produto.
- [ ] O resultado da sprint produz uma decisão explícita: manter o preço atual, ajustar a narrativa, ou exigir mais valor antes de venda ativa.

## Notes

- `Free`, `Premium` and `Enterprise` are the canonical plan names for both backend API and public pricing.
- `Premium` is the primary commercial offer and must include enough value to justify R$ 299,90/mês.
- Keep analytics and financeiro no `Premium` for MVP, then introduce add-ons in a second phase.
- Use the existing subscription API docs in `school-management-api/docs/api/subscriptions.md` as the implementation source of truth.
