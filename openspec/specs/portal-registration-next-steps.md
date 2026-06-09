# OpenSpec: Portal Registration - Próximas Etapas

> Status: documento de apoio.
> Fonte OpenSpec formal desta evolução: `openspec/changes/update-portal-registration-next-steps/`.

## Objetivo

Consolidar as próximas entregas para o fluxo de registro do Portal do Responsável, garantindo segurança, experiência do usuário, rastreabilidade entre specs e cobertura de testes ponta a ponta.

## Alinhamento e Dependências

Este delta depende e referencia requisitos dos seguintes specs:

- [Self-Service Portal](../changes/implement-self-service-portal/specs/self-service-portal/spec.md): autenticação, escopo de acesso, MFA, auditoria, painel financeiro e acadêmico.
- [Notifications](../specs/notifications/spec.md): envio de e-mail de verificação, opt-out, quiet hours, dashboard de monitoramento.
- [Communications](../specs/communications/spec.md): templates de mensagens transacionais, logs de entrega, integração com provedores.
- [Academic Year](../specs/academic-year/spec.md): vínculo do responsável/aluno ao ano letivo vigente, contexto de seleção.
- [Automated Onboarding](../specs/automated-onboarding/spec.md): onboarding inicial de responsáveis/alunos, importação em massa, provisionamento de vínculo.

Todos os fluxos e critérios de aceite deste delta devem ser validados à luz dos requisitos acima. Mudanças que impactem autenticação, notificações ou onboarding devem ser refletidas nos specs correspondentes.

---

## 1. E2E Testing com Cypress

### Objetivo

Cobrir o fluxo completo de registro, validação de e-mail (via canal de notificação transacional), login e acesso ao dashboard do responsável, considerando restrições de MFA, opt-out e contexto de ano letivo.

### Critérios de Aceite

- [ ] Teste automatizado cobre:
  - Acesso à rota `/portal/register`
  - Preenchimento do formulário com dados válidos
  - Validação de erros de formulário (email duplicado, senha fraca, termos não aceitos)
  - Submissão bem-sucedida → redirecionamento para `/portal/email-verification`
  - Simulação de backend para respostas de sucesso/erro (incluindo respostas de rate limit e MFA obrigatório)
  - Validação de contexto de ano letivo (se aplicável)
- [ ] Teste de fluxo negativo (email já cadastrado, senha inválida, bloqueio por opt-out, tentativa fora do horário permitido)
- [ ] Teste de fluxo positivo (registro, verificação, login, acesso restrito ao escopo do responsável)

### Observações

- Utilizar interceptação de requests para simular backend, incluindo respostas de notificações e comunicações
- Limpar sessionStorage/localStorage entre cenários
- Validar logs de auditoria e notificações disparadas (mock)

---

## 2. Implementar email-verification component

### Objetivo

Exibir tela de verificação de e-mail após registro, instruindo o usuário a confirmar o e-mail antes do primeiro acesso. O fluxo de verificação deve acionar o envio de notificação transacional (e-mail) conforme spec de Notifications/Communications, respeitando opt-out e quiet hours.

### Critérios de Aceite

- [ ] Rota `/portal/email-verification?guardianId={id}&sub={sub}`
- [ ] Mensagem clara: "Verifique seu e-mail para ativar a conta"
- [ ] Botão para reenviar e-mail de verificação (aciona endpoint de notificação, respeitando opt-out e quiet hours)
- [ ] Feedback visual de sucesso/erro ao reenviar
- [ ] Link para login
- [ ] Limpar sessionStorage após verificação
- [ ] Log de auditoria para cada tentativa de reenvio

### Observações

- Reaproveitar estilos do PortalRegisterComponent
- Backend: endpoint para reenviar e-mail de verificação (deve usar template transacional e registrar log de entrega)

---

## 3. Backend: Rate Limiting (5 tentativas/min/IP)

### Objetivo

Proteger endpoint de registro contra brute-force e abuso, registrando tentativas excedidas em log de auditoria e expondo métricas para observabilidade.

### Critérios de Aceite

- [ ] Limite de 5 tentativas de registro por minuto por IP
- [ ] Retorno HTTP 429 com mensagem amigável ao exceder limite
- [ ] Log de tentativas excedidas para auditoria (spec self-service-portal)
- [ ] Métricas expostas para dashboard de notificações/segurança
- [ ] Testes automatizados cobrindo cenário de rate limit

### Observações

- Implementar via middleware/policy (ex: AspNetCoreRateLimit, custom)
- Configuração parametrizável por ambiente
- Validar integração com logs de auditoria e dashboard de notificações

---

## 4. Frontend: Link no portal-login para "Não tem conta? Registre-se"

### Objetivo

Facilitar acesso ao registro para novos usuários diretamente da tela de login, garantindo acessibilidade e rastreabilidade de eventos de navegação.

### Critérios de Aceite

- [ ] Adicionar link "Não tem conta? Registre-se" abaixo do botão de login em `/portal/login`
- [ ] Link direciona para `/portal/register`
- [ ] Acessível via teclado e leitor de tela (WCAG)
- [ ] Teste unitário cobrindo renderização e navegação
- [ ] Evento de navegação registrado em log de auditoria

### Observações

- Seguir padrão visual do sistema
- Não duplicar links se já existir

---

## Referências

- [Self-Service Portal Spec](../changes/implement-self-service-portal/specs/self-service-portal/spec.md)
- [Notifications Spec](../specs/notifications/spec.md)
- [Communications Spec](../specs/communications/spec.md)
- [Academic Year Spec](../specs/academic-year/spec.md)
- [Automated Onboarding Spec](../specs/automated-onboarding/spec.md)
- [PortalRegisterComponent](../../school-management-ui/src/app/components/portal/portal-register.component.ts)
- [PortalService](../../school-management-ui/src/app/services/portal.service.ts)
