# GitHub Actions Secrets — School Management SaaS

Configure os seguintes secrets no repositório GitHub antes de habilitar deploy automático.

## Secrets necessários

| Secret | Descrição | Obrigatório |
|--------|-----------|-------------|
| `GH_PAT` | Personal Access Token com escopo `repo` para checkout de submodules | Sim |
| `DOCKER_USERNAME` | Usuário Docker Hub (se usar push de imagens) | Sim |
| `DOCKER_PASSWORD` | Senha/token do Docker Hub | Sim |
| `AUTH0_DOMAIN` | Domínio Auth0 de produção | Sim |
| `AUTH0_CLIENT_ID` | Client ID Auth0 produção | Sim |
| `AUTH0_CLIENT_SECRET` | Client Secret Auth0 produção | Sim |
| `AUTH0_AUDIENCE` | Audience da API no Auth0 | Sim |
| `DB_PASSWORD` | Senha do PostgreSQL de produção | Sim |
| `JWT_SECRET` | Segredo JWT (mínimo 32 chars) | Sim |