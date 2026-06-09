# Estratégia de Monetização do Sistema

Autor: _a definir_
Data: 2025-10-18
Status: draft

## Why

O produto já possui a base técnica de assinaturas com os planos canônicos `Free`, `Premium` e `Enterprise`, mas o posicionamento comercial e a fase de billing ainda estão parcialmente difusos. Sem alinhar estratégia, pricing público e rollout de cobrança, o time corre risco de vender uma proposta diferente da que a API realmente suporta.

## What Changes

- Consolidar `Free`, `Premium` e `Enterprise` como o modelo comercial canônico em produto, API e comunicação pública.
- Definir `Premium` como oferta principal de venda no MVP, incluindo portal do responsável, notificações avançadas, dashboards operacionais e módulo financeiro.
- Adotar rollout em duas fases: fase 1 sem add-ons obrigatórios; fase 2 com billing gateway e possíveis add-ons após estabilização do contrato de cobrança.
- Formalizar a trilha de implementação de billing e medição de uso antes de ativar cobrança produtiva.

## Impact

- Affected specs: monetization
- Affected code: `school-management-api/docs/api/subscriptions.md`, catálogo de planos, pricing page pública, futura integração com gateway de cobrança
- Impacto operacional: marketing, produto, backend e infra passam a trabalhar sobre o mesmo catálogo e a mesma narrativa de valor

## Documentação pós-implementação

- Atualizar o material público de pricing com tiers, limites e valor principal do `Premium`
- Documentar a ativação de billing e os pré-requisitos de gateway somente após validação do contrato de cobrança
