# ADR: Mitigacao de Risco Residual no Portal Registration

## Contexto

No fluxo de registro do portal, dados sensiveis de correlacao (`guardianId` e `auth0Sub`) estavam sendo transportados por query params e persistidos em `sessionStorage`, aumentando superficie de exposicao.

## Referencias

- Angular docs: NavigationExtras.state (estado transitório de navegacao)
  - https://angular.dev/api/router/NavigationExtras
- OWASP: Information exposure through query strings in URL
  - https://owasp.org/www-community/vulnerabilities/Information_exposure_through_query_strings_in_url

## Decisao

- Remover `guardianId` e `auth0Sub` de query params.
- Remover persistencia de `guardianId` e `auth0Sub` em `sessionStorage`.
- Usar `NavigationExtras.state` e `history.state` apenas de forma transitoria entre rotas.
- Limpar `history.state` imediatamente apos consumo no destino, evitando reutilizacao indevida.

## Consequencias

- Reduz exposicao de identificadores em URL, logs, historico e analytics.
- Reduz janela de vazamento por armazenamento no browser.
- Exige comportamento fail-closed quando o contexto transitorio nao estiver presente.

## Fail-Closed

- Em `/portal/email-verification`, quando nao houver contexto esperado em `history.state`, bloquear fluxo e redirecionar para `/portal/register` (sem fallback permissivo).

## Evidencias de Validacao

- `npm run test -- --watch=false --browsers=ChromeHeadless` -> 280/280.
- `npm run e2e:ci:portal-registration` -> 6/6.
