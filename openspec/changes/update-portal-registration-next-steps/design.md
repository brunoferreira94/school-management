# Design — update-portal-registration-next-steps

## Objetivo técnico

Definir como o fluxo de registro do Portal do Responsável evolui com segurança, observabilidade e experiência consistente, sem romper capacidades existentes do ecossistema de portal e notificações.

## Decisões arquiteturais

1. Registro fail-closed

- O backend deve rejeitar qualquer estado ambíguo de identidade externa.
- Nenhum fallback permissivo é aceito para vinculação de responsável/aluno.

2. E-mail de verificação como mensagem transacional crítica

- O envio de verificação é tratado como transacional e auditável.
- Em caso de conflito com quiet hours/opt-out, a política deve priorizar segurança/ativação de conta de forma explícita e registrada.

3. Rate limiting orientado a abuso

- Limite por IP com resposta 429 amigável.
- Registro de tentativas excedidas para trilha de auditoria e alertas operacionais.

4. Estado sensível no cliente

- Dados transitórios do registro permanecem em sessionStorage apenas pelo tempo necessário.
- Limpeza obrigatória após verificação ou abandono do fluxo.

## Integrações com capacidades existentes

- self-service-portal: autenticação, escopo por dependentes, auditoria.
- notifications: disparo e monitoramento de e-mails de verificação.
- communications: template e log de entrega transacional.
- automated-onboarding: garantia de vínculo inicial responsável/aluno em jornadas novas.
- academic-year: compatibilidade com contexto acadêmico quando o portal exigir escopo por ano.

## Estratégia de testes

- Unitários frontend para estados de UI e navegação.
- Unitários/integração backend para rate limiting e endpoint de reenvio.
- E2E Cypress para jornada ponta a ponta (positivo e negativo).
- Critérios de aprovação incluem validação de logs/métricas e não regressão de segurança.

## Impactos esperados

- Melhor defesa contra abuso no endpoint de registro.
- Menor fricção para novos responsáveis no primeiro acesso.
- Maior rastreabilidade operacional do funil registro -> verificação -> login.
