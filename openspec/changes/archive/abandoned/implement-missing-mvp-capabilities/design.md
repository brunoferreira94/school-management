# Design — Implementar capacidades faltantes do MVP escolar

## Visão de solução

A mudança se divide em seis blocos integrados, cada um com responsabilidades claras:

1. Pagamentos
2. Portal familiar e mobile
3. Dashboards e BI
4. Funcionalidade pedagógica avançada
5. Integrações com ecossistema escolar
6. Maturidade de produto e operação

Cada bloco deve ser projetado para ser testável e incrementável sem criar dependências circulares entre módulos.

## Arquitetura proposta

### Backend

- Adicionar um serviço de pagamento genérico (PaymentGateway) que abstrai provedores como Pix, boleto e cartão.
- Implementar endpoints REST para criação de transações, consulta de status e reconciliação.
- Criar views/serviços de backend para métricas de BI usando a base de dados existente e possíveis materialized views.
- Proteger dados do portal familiar com permissões finas e separação clara entre dados autenticados de responsáveis/alunos.
- Expor APIs públicas documentadas em swagger/openapi para integrações externas.

### Frontend

- Construir o portal familiar como uma área dedicada no Angular, com rotas e componentes PWA-friendly.
- Implementar dashboard administrativo com gráficos e cartões de desempenho para inadimplência, retenção e presença.
- Reforçar a experiência mobile com layout responsivo e comportamento de app progressivo.
- Estender formulários pedagógicos para avaliações por competência, tarefas e relatórios de progresso.

### Observabilidade e qualidade

- Registrar eventos críticos de pagamento, consentimento e acesso ao portal em logs estruturados e métricas.
- Adicionar testes de integração para fluxos de pagamento, dashboard e portal familiar.
- Incluir validações de segurança, LGPD e autorização nas APIs públicas.

## Dependências

- Provedores de gateway de pagamento externos.
- Auth0 / JWT para autenticação de usuários e permissões.
- Biblioteca de gráficos do frontend para dashboards (já existente ou nova, dependendo do stack atual).
- Ferramentas de documentação de API (Swagger/OpenAPI).

## Critérios de divisão de entregas

### Fase 1: Pagamentos + Portal familiar

- Entregar integração de pagamento mínima viável e portal de consulta de boletos.
- Validar fluxo de transações e segmentar permissões de acesso.

### Fase 2: Dashboards + BI

- Entregar dashboard com indicadores básicos e visualização de inadimplência/retenção.
- Garantir performance com cache ou materialização quando necessário.

### Fase 3: Pedagogia + Integrações

- Entregar funcionalidades pedagógicas avançadas e APIs externas com documentação.
- Preparar conectores legados e testes de integração.

### Fase 4: Maturidade operacional

- Documentar onboarding, treinamento e pacote comercial do MVP.
- Formalizar suporte, SLA e lançamento piloto.
