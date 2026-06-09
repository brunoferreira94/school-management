# ADR 2026-05-11: Incidente de autenticação Auth0 no portal

## Status
Aceito

## Contexto
Chamadas para `/portal/profile` e `/academic-years` estavam saindo sem token e retornando `401` no fluxo do portal.

## Decisão
- Remover a dependência de `SKIP_AUTH_INTERCEPTOR` do interceptor Auth0 em [school-management-ui/src/app/interceptors/auth0.interceptor.ts](../../school-management-ui/src/app/interceptors/auth0.interceptor.ts).
- Não enviar a request quando o token silencioso vier vazio.
- Pular `initAcademicYear` quando a rota atual começar com `/portal` em [school-management-ui/src/app/app.config.ts](../../school-management-ui/src/app/app.config.ts).
- Manter [school-management-ui/src/app/services/portal.service.ts](../../school-management-ui/src/app/services/portal.service.ts) usando contexto para pular o interceptor legado.

## Consequências
- As chamadas do portal passam a receber `Bearer` corretamente quando `USE_AUTH0_TOKEN` estiver habilitado.
- O bootstrap global deixa de disparar `academic-years` durante o acesso ao portal.
- O comportamento legado do `portal.service` continua isolado ao contexto explícito.

## Evidência
- O teste [school-management-ui/src/app/interceptors/auth0.interceptor.spec.ts](../../school-management-ui/src/app/interceptors/auth0.interceptor.spec.ts) passou com `5/5`.

## Referências
- [school-management-ui/src/app/interceptors/auth0.interceptor.ts](../../school-management-ui/src/app/interceptors/auth0.interceptor.ts)
- [school-management-ui/src/app/app.config.ts](../../school-management-ui/src/app/app.config.ts)
- [school-management-ui/src/app/services/portal.service.ts](../../school-management-ui/src/app/services/portal.service.ts)
- [school-management-ui/src/app/interceptors/auth0.interceptor.spec.ts](../../school-management-ui/src/app/interceptors/auth0.interceptor.spec.ts)