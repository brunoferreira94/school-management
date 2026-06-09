# Implementar tela de Comunicações

Autor: _a definir_  
Data: 2025-10-18  
Status: archived

## Why

As comunicações (e-mail, SMS, push) estavam dispersas em fluxos manuais ou scripts isolados. A ausência de um ponto único gerava:

- Inconsistência de mensagem e branding.
- Dificuldade em auditar entregas e falhas.
- Retrabalho na preparação de campanhas recorrentes.

Centralizar em uma tela reduz esforço operacional, melhora rastreabilidade e agiliza campanhas segmentadas.

## What Changes

Entrega de uma interface unificada de comunicações com:

- CRUD de templates multi‑canal (e-mail, SMS, push) com placeholders.
- Segmentação por turma, série, tags e filtros customizados.
- Agendamento de envios (cron/data-horário único) e fila de execução.
- Histórico detalhado com status (queued, sent, delivered, failed) e métricas básicas.
- Monitoramento de provedores (credenciais/quota) para bloquear envios quando indisponíveis.

## Summary

Tela web (Angular) com abas para Templates, Segmentação/Envio e Histórico. Backend expõe endpoints REST para templates, jobs de envio e logs. Integra provedores existentes (SMTP, SMS, Push) via camada de abstração.

## Success Criteria

- Criar e salvar template com placeholders validados.
- Agendar envio segmentado e visualizar entrada na fila.
- Consultar histórico com status por destinatário.
- Bloquear envio quando canal estiver indisponível.

## Dependencies

- Provedores externos: SMTP, gateway SMS, serviço Push.
- Infra de fila já existente ou mínima (in-memory / database polling) nos primeiros incrementos.

## Out of Scope

- Tracking avançado (open/click analytics detalhado) — pode ser futuro incremento.
- Editor WYSIWYG avançado com upload de mídia.

## Risks

- Volume alto de destinatários pode exigir otimização/particionamento da fila.
- Placeholders não validados podem gerar falhas de renderização — mitigado por validação sintática simples (`{{var}}`).

## Follow-up / Post Implementation

Atualizar `README.md` com:

- Descrição de templates e placeholders suportados.
- Permissões necessárias (`MANAGE_COMMUNICATIONS`).
- Exemplos de payload de envio agendado e segmentado.
- Boas práticas de conteúdo (limite de caracteres SMS, tamanho de HTML email).

## Audit & Compliance

Registros de envio mantêm timestamp, canal, destinatário e status para conformidade. Dados pessoais minimizados nos logs (ID e canal, não corpo completo após envio).

## Change Log

Inicial: criação das abstrações de template, segmentação e job de envio; UI básica com abas. Incrementos futuros poderão adicionar métricas de engajamento.
