# Cadastro self-service de escola (school registration)

## Why

O funil ao vivo exige que o visitante anônimo **logue** para comprar. Não existe um caminho
para um visitante criar a escola + a conta de administrador sozinho — o único caminho de
cadastro anônimo é o **portal do responsável** (`POST /api/portal/auth/register`), que cria uma
conta de aluno/responsavele **sem tenant escolar**. É impossível aquisição real sem contato.

## What Changes

- Endpoint público `POST /api/onboarding/register-school` (nome da escola, nome/email/cpf do
  gestor, senha) → cria **Tenant + SchoolUnit + Staff (Admin) + assinatura Free/trial** em uma
  única transação, devolve `redirectUrl` (`/login` com flag de "conta criada") ou login direto
  via token.
- UI no `/cadastro` (rota pública) com formulário controlado + aceite de termos + feedback de
  e-mail já usado.
- A página de pricing ("Iniciar") e a landing apontam para `/cadastro`.

**BREAKING** (mínimo): nenhum — endpoint novo, não afeta existentes.

## Impact

- Specs: `self-service-onboarding` (delta, complementa o já existente no change
  `implement-2026-differentiators`)
- Código API: novo controller `SchoolRegistrationController` + `TenantProvisioningService` +
  migration para garantir a assinatura trial é criada
- Código UI: nova feature `onboarding/`, rota pública `/cadastro`
