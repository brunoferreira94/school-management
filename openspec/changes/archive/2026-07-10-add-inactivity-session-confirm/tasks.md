# Tasks — add-inactivity-session-confirm

## Planejamento e alinhamento

- [x] Revisar a sugestão de autologout considerando o uso frequente de um SaaS.
- [x] Considerar a renovação de token já existente.
- [x] Ajustar a mudança para confirmação suave de sessão inativa, em vez de logout imediato.
- [x] Validar a change com `openspec validate add-inactivity-session-confirm --strict`.

## Implementação

- [x] Criar `SessionInactivityService`.
- [x] Definir constantes de configuração: `15`, `30` e `60` minutos.
- [x] Persistir timeout em `localStorage`.
- [x] Registrar listeners de atividade no `AppComponent`.
- [x] Emitir aviso quando o timeout de inatividade expirar.
- [x] Oferecer ação de continuar sessão via `ConfirmDialogComponent`.
- [x] Ao continuar, chamar `AuthService.refresh()` e reiniciar o timer.
- [x] Ao ignorar o aviso até a janela de graça expirar, chamar `AuthService.logout()` e navegar para `/login`.
- [x] Criar testes unitários do serviço.

## Validação

- [x] Executar testes unitários do serviço:
  - `npm test -- --include='src/app/services/session-inactivity.service.spec.ts'`
  - Resultado: `TOTAL: 8 SUCCESS`
- [x] Executar build do frontend:
  - `npm run build`
  - Resultado: passou
- [x] Executar validação final da change Openspec:
  - `openspec validate add-inactivity-session-confirm --strict`
  - Resultado: `Change 'add-inactivity-session-confirm' is valid`

## Critérios de aceite

- [x] Usuário autenticado recebe aviso após o período configurado sem atividade.
- [x] Usuário pode continuar a sessão sem fazer login novamente.
- [x] Ao continuar, o token é renovado e o timer de inatividade é resetado.
- [x] Usuário é deslogado apenas se ignorar o aviso até o fim da janela de confirmação.
- [x] Configuração persiste entre recarregamentos.
- [x] Atividades do usuário reiniciam o contador.
- [x] Valor padrão é `30` minutos.
- [x] Valores permitidos são `15`, `30` e `60` minutos.
- [x] A change valida com `openspec validate add-inactivity-session-confirm --strict`.
