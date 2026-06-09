# Atualizar roadmap de registro do portal com pacote OpenSpec completo

Autor: _a definir_
Data: 2026-05-12
Status: draft

## Resumo

Estruturar formalmente as próximas etapas do fluxo de registro do Portal do Responsável com pacote OpenSpec completo (proposal, tasks, design e delta spec), incluindo dependências com notificações, comunicações, onboarding, segurança e contexto acadêmico.

## Motivação

- O conteúdo de roadmap existia sem estrutura completa de change no OpenSpec.
- Faltavam arquivos operacionais para acompanhamento (tasks.md) e decisão técnica (design.md).
- É necessário rastrear claramente como o fluxo de registro depende de capacidades já existentes no produto.

## Escopo

- Definir backlog executável para:
  - E2E do fluxo de registro/validação/login.
  - Tela de verificação de e-mail com reenvio.
  - Rate limiting do endpoint de registro.
  - Link de navegação login -> registro com acessibilidade.
- Alinhar requisitos com specs existentes:
  - self-service-portal
  - notifications
  - communications
  - automated-onboarding
  - academic-year

## Fora de escopo

- Implementação de backend/frontend nesta mudança de spec.
- Alterações em pricing/planos comerciais.
- Alterações de arquitetura de autenticação além do necessário para os requisitos do registro.

## Critérios de aceite da mudança

- Existe um change OpenSpec completo em openspec/changes/update-portal-registration-next-steps/.
- O delta spec define requisitos e cenários testáveis para os 4 blocos de entrega.
- O tasks.md cobre etapas de análise, implementação e validação.
- O design.md documenta decisões de segurança, observabilidade e integração com notificações/comunicações.

## Riscos

- Acoplamento indevido entre registro e módulos de comunicação.
- Regressões no login do portal ao adicionar novos estados de verificação.
- Inconsistência entre regras de notificação (quiet hours/opt-out) e e-mails transacionais críticos.

## Mitigações

- Definir claramente no spec quais mensagens são transacionais críticas e como tratar quiet hours.
- Exigir testes E2E e unitários para os cenários de sucesso e falha.
- Validar métricas/logs de auditoria para todos os eventos sensíveis do fluxo.
