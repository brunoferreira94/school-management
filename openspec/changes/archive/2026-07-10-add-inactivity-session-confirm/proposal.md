# Proposal — add-inactivity-session-confirm

## Context

A nota do Obsidian aponta a necessidade de **autologout após inatividade configurável: 15/30/60 minutos**. Porém, por ser um SaaS de uso frequente, forçar login novamente sempre que a sessão ficar inativa pode prejudicar a experiência do usuário, especialmente porque o sistema já implementa renovação de token quando o token expira.

## Problem

Usuários autenticados podem deixar a aplicação aberta em computadores compartilhados, aumentando o risco de acesso indevido. Ao mesmo tempo, um logout automático rígido por inatividade pode ser frustrante para usuários ativos que estão lendo telas longas, participando de reuniões ou alternando entre abas.

## Proposed Change

Implementar um **guarda de sessão por inatividade com confirmação suave**, em vez de logout imediato:

- timeout configurável: `15`, `30` ou `60` minutos;
- valor padrão: `30` minutos;
- persistência da configuração em `localStorage`;
- reinício do timer em eventos de atividade;
- ao atingir o tempo de inatividade, exibir confirmação/modal avisando que a sessão será encerrada;
- janela de confirmação de `5` minutos;
- se o usuário confirmar que ainda está presente, renovar o token e resetar o timer;
- se o usuário não responder dentro da janela, executar logout e redirecionar para `/login`;
- não alterar o fluxo existente de refresh de token por expiração.

## Scope

### In scope

- Criar serviço reutilizável para monitorar inatividade e emitir eventos de sessão.
- Integrar a confirmação no fluxo autenticado.
- Persistir a configuração em `localStorage`.
- Expor helpers/constants para os valores permitidos.
- Criar testes unitários do serviço.
- Garantir que a renovação de token por expiração continue funcionando.

### Out of scope

- Alterar política de expiração de tokens no backend.
- Alterar refresh token.
- Implementar push notifications, PWA ou calendário.
- Criar tela administrativa completa para configuração do timeout.

## Acceptance Criteria

- [ ] Usuário autenticado recebe aviso após período configurado sem atividade.
- [ ] Usuário pode continuar a sessão sem fazer login novamente.
- [ ] Ao continuar, o token é renovado e o timer de inatividade é resetado.
- [ ] Usuário é deslogado apenas se ignorar o aviso até o fim da janela de confirmação.
- [ ] A configuração persiste entre recarregamentos da página.
- [ ] Atividades do usuário reiniciam o contador de inatividade.
- [ ] O valor padrão é `30` minutos.
- [ ] Valores permitidos são `15`, `30` e `60` minutos.
- [ ] A change Openspec valida com `openspec validate add-inactivity-session-confirm --strict`.

## Recommendation

Aprovar esta versão ajustada como a próxima implementação, pois mantém a preocupação de segurança sem prejudicar o uso frequente típico de um SaaS.
