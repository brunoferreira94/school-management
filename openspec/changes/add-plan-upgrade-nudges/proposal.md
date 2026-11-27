# Nudges de upgrade de plano (soft gate visual)

Autor: Bruno Ferreira (assistente)
Data: 2026-11-27
Status: draft — aguarda aprovação do dono (copy, escopo dos 4 recursos e tom)

## Motivação

Hoje o upgrade só aparece quando o backend **bloqueia**: `402 subscription_expired` (trial vencido)
ou `403 feature_not_in_plan` (feature fora do plano). As messaging e o visual dos menus ainda não
comunicam valor antes do bloqueio — o cliente só descobre o plano ao esbarrar no limite.

O dono propôs usar **gatilhos mentais éticos** para antecipar a decisão: mostrar o que está
incluído, o que o cliente já construiu e o que falta, **sem** bloquear acesso, sem escassez falsa
e sem prova social inventada.

Este change **planeja** o que e onde fazer. Não altera enforcement, preços nem checkout.

## Escopo

- **Soft gate visual**: itens de menu de recursos fora do plano aparecem com cadeado + badge
  "Premium"; o clique abre o modal de upgrade em vez de navegar (mesmo com `FeatureGating:Enforce=false`).
- **Tela do recurso indisponível**: estado de preview travada (mock desfocado), título de
  benefício, 3 bullets de valor e CTA "Desbloquear com Premium" + secundário "Falar com vendas".
- **Mensagens específicas por feature** e pelo menos um dado real do tenant (alunos/turmas
  cadastrados) para ancoragem — nunca números inventados.
- **Regra de frequência**: primeiro acesso por recurso, com *dismiss* de 7 dias (sem nagging).
- **Telemetria**: `nudge_shown`, `nudge_dismissed`, `upgrade_clicked`, `checkout_started` por feature.

## Fora de escopo

- Ligar `FeatureGating:Enforce` ou `Entitlement:Enforce` (decisão separada).
- Alteração de preço, catálogo, checkout ou contrato.
- Contador regressivo falso, "últimas vagas", prova social inventada, culpa ou medo.
- Modificar a API — o plano é somente frontend + i18n + telemetry.

## Critérios de aceitação

- Nenhum visitante/cliente é impedido de navegar por causa deste change (soft gate apenas visual).
- Nenhuma mensagem usa urgência, escassez ou prova social sem dado real.
- `openspec validate add-plan-upgrade-nudges --strict` passa.
- Copy aprovado pelo dono antes da implementação (tasks 1.x).
