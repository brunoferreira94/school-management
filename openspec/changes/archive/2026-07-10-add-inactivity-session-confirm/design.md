# Design — add-inactivity-session-confirm

## Decision

Implementar um guarda de sessão por inatividade com confirmação suave, em vez de logout imediato.

O fluxo será:

1. monitorar atividade do usuário;
2. quando a inatividade atingir o timeout configurado, emitir um evento de aviso;
3. exibir uma confirmação modal ou toast com ação de continuar sessão;
4. se o usuário confirmar, chamar `AuthService.refresh()` e reiniciar o timer;
5. se o usuário ignorar até a janela de confirmação expirar, chamar `AuthService.logout()` e navegar para `/login`.

## Configuration

A configuração fica em `localStorage`:

```ts
export const SESSION_INACTIVITY_TIMEOUT_KEY = 'sma_session_inactivity_timeout_minutes';
export const SESSION_INACTIVITY_TIMEOUTS = [15, 30, 60] as const;
export const DEFAULT_SESSION_INACTIVITY_TIMEOUT_MINUTES = 30;
export const SESSION_CONFIRMATION_GRACE_MINUTES = 5;
```

Regras:

- `15`, `30` e `60` são os únicos valores aceitos.
- Qualquer valor ausente ou inválido normaliza para `30`.
- A mudança do valor reinicia o timer.
- A janela de confirmação é fixa em `5` minutos.

## Service behavior

### Start

- registra listeners de atividade no `window`;
- agenda o primeiro timer;
- ignora chamadas duplicadas.

### Stop

- remove listeners;
- limpa timers pendentes;
- descarta estado de aviso pendente.

### Activity events

Os eventos abaixo reiniciam o contador:

- `mousemove`;
- `keydown`;
- `click`;
- `scroll`;
- `touchstart`;
- `visibilitychange` quando o documento volta a estar visível.

### Warning

Quando o timeout de inatividade expira:

1. emitir evento de aviso;
2. iniciar timer de graça;
3. aguardar confirmação do usuário.

### Continue session

Quando o usuário confirma que ainda está presente:

1. chamar `AuthService.refresh()`;
2. resetar o timer de inatividade;
3. remover estado de aviso pendente.

### Logout

Quando o timer de graça expira sem resposta:

1. chamar `AuthService.logout()`;
2. navegar para `/login`;
3. remover a configuração de timeout da sessão atual, se necessário.

## Dependency strategy

Para manter o serviço testável:

- injetar `AuthService`;
- injetar `Router`;
- injetar `DOCUMENT` para obter `defaultView`;
- usar `localStorage` com fallback seguro.

## Test strategy

- `fakeAsync` + `tick` para validar expiração e grace period.
- spies em `addEventListener`/`removeEventListener`.
- `localStorage` simulado para validar persistência.
- teste de normalização para valor inválido.
- teste de atividade reiniciando timer.
- teste de confirmação chamando `refresh()` e resetando timer.

## Files to change

- `school-management-ui/src/app/services/session-inactivity.service.ts`
- `school-management-ui/src/app/services/session-inactivity.service.spec.ts`
- `school-management-ui/src/app/app.component.ts`
- `openspec/changes/add-inactivity-session-confirm/tasks.md`
