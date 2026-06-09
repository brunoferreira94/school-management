# Tasks — update-portal-registration-next-steps

## Planejamento e alinhamento

- [x] Inventariar dependências de spec: self-service-portal, notifications, communications, automated-onboarding, academic-year. (owner: product)
- [x] Estruturar pacote OpenSpec completo para o roadmap de registro. (owner: product)
- [ ] Validar o change via openspec validate --strict. (owner: product)

## Backend

- [ ] Implementar rate limiting de 5 tentativas/min por IP no endpoint de registro. (owner: backend)
- [ ] Registrar eventos de 429 e tentativas excedidas em trilha de auditoria. (owner: backend)
- [ ] Expor métricas de tentativas e bloqueios para observabilidade. (owner: backend)
- [ ] Implementar endpoint de reenvio de e-mail de verificação com idempotência básica. (owner: backend)

## Frontend

- [ ] Implementar rota e tela de verificação de e-mail com feedback de sucesso/erro. (owner: frontend)
- [ ] Limpar dados sensíveis de sessionStorage ao concluir o fluxo de verificação. (owner: frontend)
- [ ] Adicionar link de navegação login -> registro com requisitos de acessibilidade. (owner: frontend)
- [ ] Adicionar telemetria de eventos de navegação e submissão no fluxo de registro. (owner: frontend)

## Qualidade

- [ ] Criar suíte E2E Cypress cobrindo fluxo positivo e fluxos negativos. (owner: qa)
- [ ] Adicionar testes unitários para link no login e tela de email-verification. (owner: qa)
- [ ] Adicionar testes automatizados de rate limiting no backend. (owner: qa)
- [ ] Validar não regressão de permissões/escopo de responsável no login do portal. (owner: qa)

## Segurança e operação

- [ ] Revisar política de mensagens transacionais vs quiet hours/opt-out. (owner: security)
- [ ] Garantir retenção mínima e mascaramento de dados sensíveis nos logs. (owner: security)
- [ ] Definir alertas de abuso (pico de 429 por IP/tenant). (owner: sre)

## Encerramento

- [ ] Atualizar documentação funcional/técnica do portal com o fluxo final. (owner: docs)
- [ ] Marcar tarefas concluídas após implementação e validação em produção. (owner: product)
