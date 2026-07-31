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
| `ASAAS_API_KEY` | API key do Asaas produção | Sim |
| `ASAAS_WEBHOOK_TOKEN` | Token de validação de webhooks Asaas | Sim |

## Como configurar

```bash
gh secret set GH_PAT --body "ghp_..."
gh secret set DOCKER_USERNAME --body "seu-user"
gh secret set DOCKER_PASSWORD --body "seu-token"
```

## Observação

O workflow atual faz build e publish localmente. Para deploy real em VM/Docker host,
adicione um step de `ssh`/`scp` ou use self-hosted runner com Docker.
