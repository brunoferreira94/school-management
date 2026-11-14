# Proposta: rascunho local e recuperação após queda de conexão

Autor: _a definir_
Data: 2026-11-14
Status: draft

## Why

Hoje quem digita conteúdo longo no sistema (comunicados, templates de relatório, cadastros, notas, diário, horários) perde tudo quando a internet cai no meio da edição: o `POST`/`PUT` falha, o formulário continua na tela sem nenhuma cópia local e um `F5`, um timeout de sessão ou o fechamento da aba apagam o trabalho. A PWA já cacheia o *app shell* e tem página `/offline`, mas nenhuma tela guarda o que o usuário escreveu. O resultado é retrabalho — e, em telas de notas e comunicados, retrabalho no fim do período letivo.

## What Changes

- Todo formulário longo passa a salvar automaticamente um **rascunho local** enquanto o usuário digita, sem depender da rede.
- Ao reabrir a tela (após queda, recarregamento ou re-login), o usuário recebe um **aviso de recuperação** com o horário do rascunho e as opções de restaurar ou descartar.
- Quando o envio falha por falta de conexão, a submissão fica **enfileirada localmente** e é reenviada ao reconectar, com chave de idempotência para não duplicar registros.
- Indicador visível de **estado de conexão + "salvo localmente às HH:MM"**, para o usuário saber que o trabalho está protegido.
- **Conflito explícito**: se a versão do servidor mudou desde o início da edição, o sistema nunca sobrescreve em silêncio — pede escolha ao usuário.
- Rascunhos são isolados por tenant + usuário, expiram por TTL e são apagados no sucesso do envio e no logout.
- Anexos/arquivos **não** entram no rascunho local (apenas referências), para não estourar a cota do navegador.

## Escopo

- Serviço de rascunho local (`DraftStore`) com IndexedDB, versionamento de schema e TTL.
- Diretiva/contrato `DraftableForm` reutilizável (serializar, restaurar, comparar versão).
- Registro das telas cobertas e integração em cada formulário longo.
- Fila de submissão pendente com idempotência e reenvio no evento de reconexão.
- Banner de recuperação, indicador de conexão/persistência e diálogo de conflito.
- Telemetria de rascunho criado/restaurado/descartado/reenviado.

## Fora de escopo

- Offline-first completo (editar listas, navegar em telas não visitadas e fazer CRUD offline).
- Sincronização em background via Background Sync (comportamento irregular entre navegadores) — o reenvio acontece em primeiro plano.
- Cache offline de anexos binários e uploads retomáveis.
- Colaboração em tempo real ou merge automático de edições concorrentes.
- Alterações de schema no backend além do suporte a chave de idempotência no envio.

## Impacto

- Specs afetadas: `offline-draft-recovery` (nova capability); deltas de compatibilidade em `communications`, `report-builder`, `grading-formulas`, `diary-automation` e `self-service-portal` somente se os requisitos dessas capabilities descreverem o fluxo de salvar (avaliar durante a implementação, sem reescrevê-las agora).
- Sistemas afetados: UI Angular (serviços + formulários + PWA), API .NET (idempotency key nos endpoints de escrita dos fluxos cobertos), observabilidade.
- Dependências: Service Worker existente (app shell/`/offline`), `session-autologout` (não deve apagar rascunho no logout automático), políticas da capability `data-compliance`.

## Critérios de aceite

- Existe capability OpenSpec com requisitos testáveis para captura, recuperação, reenvio, conflito, privacidade e degradação.
- Há tarefas verificáveis cobrindo frontend, backend e QA, com ordem de execução.
- A change valida em modo estrito do OpenSpec.
