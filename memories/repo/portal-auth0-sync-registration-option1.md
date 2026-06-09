# Portal Auth0 Sync Registration - Opcao 1

- Implementada opcao 1 de cadastro portal sincronizado com Auth0.
- Novo endpoint: POST /api/portal/auth/register.
- Provisionamento no Auth0 via Management API usando fluxo client_credentials.
- Persistencia local do identificador Auth0 em Guardian.Auth0Sub.
- Rollback implementado: se a persistencia local falhar, o usuario criado no Auth0 e removido.
- Fallback de resolucao de responsavel em perfil e financeiro por auth0Sub e, se necessario, email.
- Testes executados e aprovados:
  - PortalHandlersTests e PortalServiceTests: 12/12.
  - Suite Portal: 20/20.
- Data de registro: 2026-05-12.

## Atualizacao arquitetural - ExternalIdentity (provider-agnostic)

- Decisao: migrar de Guardian.Auth0Sub para ExternalIdentity para desacoplar o dominio de provedor especifico e evitar lock-in.
- Contexto/motivacao: o acoplamento direto em Auth0Sub dificultava evolucao para multi-provider e aumentava custo de troca de IdP.
- Mudancas implementadas:
  - Novas entidades/classes de identidade externa e repositorios dedicados.
  - Ajustes no SchoolContext para mapear relacionamento one-to-many entre Guardian e identidades externas.
  - Atualizacao do PortalService para usar ExternalIdentity como fonte primaria de vinculo.
  - Migration aplicada para criacao/ajuste de tabela, relacionamento e indices necessarios.
- Estrategia de seguranca:
  - Sem fallback por email quando sub existe sem vinculo local (fail-closed para evitar associacao indevida).
  - Segredo removido de appsettings.Development.
- Resultados de testes:
  - PortalServiceTests: passando.
  - Suite Portal: passando.
- Referencias oficiais:
  - https://learn.microsoft.com/ef/core/modeling/relationships/one-to-many
  - https://learn.microsoft.com/ef/core/modeling/indexes
  - https://learn.microsoft.com/ef/core/managing-schemas/migrations/managing
  - https://learn.microsoft.com/aspnet/core/security/authentication/social/
- Data de registro: 2026-05-12.
