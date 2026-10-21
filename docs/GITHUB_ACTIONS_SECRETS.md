# GitHub Actions Secrets — School Management SaaS

Configure os seguintes secrets no repositório GitHub antes de habilitar deploy automático.

## Estado real (out/2026)

- Workflows que rodam hoje usam **somente `GH_PAT`** (checkout de submodules em 4 jobs) + secrets/vars opcionais do job deploy.
- `DOCKER_USERNAME/PASSWORD`, `AUTH0_*`, `DB_PASSWORD`, `JWT_*` **não são referenciados pelos workflows atuais** (o deploy cloud via Vercel/Render/Supabase usa configuração nas próprias plataformas). Mantidos aqui para o caminho self-hosted opcional.
- Recomendação de `GH_PAT`: **Fine-grained PAT** com escopo *Contents: Read-only* apenas nos repos `school-management-api` e `school-management-ui` (Nunca em classic `repo` full-machine). Rotacionar a cada 90 dias.

## Secrets necessários

| Secret | Descrição | Obrigatório |
|--------|-----------|-------------|
| `GH_PAT` | Personal Access Token **fine-grained** (read contents) para checkout de submodules | Sim |
| `RENDER_DEPLOY_HOOK` | URL de Deploy Hook do serviço Render (opt-in via var de repo `RENDER_DEPLOY_HOOK_ENABLED=true`) | Não (deploy API via CI) |
| `DOCKER_USERNAME` | Usuário Docker Hub (se usar push de imagens) | Sim |
| `DOCKER_PASSWORD` | Senha/token do Docker Hub | Sim |
| `AUTH0_DOMAIN` | Domínio Auth0 de produção | Sim |
| `AUTH0_CLIENT_ID` | Client ID Auth0 produção | Sim |
| `AUTH0_CLIENT_SECRET` | Client Secret Auth0 produção | Sim |
| `AUTH0_AUDIENCE` | Audience da API no Auth0 | Sim |
| `DB_PASSWORD` | Senha do PostgreSQL de produção | Sim |
| `JWT_SECRET` | Segredo JWT (mínimo 32 chars) | Sim |