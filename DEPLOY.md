# School Management SaaS - Deploy Guide

## Pré-requisitos

- Docker 24+
- Docker Compose 2+
- Auth0 account (com API configurada)

## Deploy Rápido (docker-compose)

### 1. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Editar .env com suas credenciais
```

### 2. Build e Deploy

```bash
# Build das imagens
docker compose -f docker-compose.prod.yaml build

# Iniciar serviços
docker compose -f docker-compose.prod.yaml up -d

# Ver logs
docker compose -f docker-compose.prod.yaml logs -f
```

### 3. Inicializar banco de dados

```bash
docker compose -f docker-compose.prod.yaml exec api dotnet ef database update
```

## Deploy com Cloudflare Tunnel

### 1. Configurar Cloudflare Tunnel

```bash
# Instalar cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Autenticar
cloudflared tunnel login

# Criar tunnel
cloudflared tunnel create school-management

# Configurar
cloudflared tunnel route dns school-management app.suaescola.com
```

### 2. Iniciar com tunnel

```bash
# Iniciar aplicação
docker compose -f docker-compose.prod.yaml up -d

# Iniciar tunnel (em outro terminal)
cloudflared tunnel run school-management
```

## Variáveis de Ambiente

| Variável | Descrição | Obrigatório |
|----------|-----------|-------------|
| `DB_USER` | Usuário do PostgreSQL | Sim |
| `DB_PASSWORD` | Senha do PostgreSQL | Sim |
| `AUTH0_DOMAIN` | Domínio Auth0 | Sim |
| `AUTH0_CLIENT_ID` | Client ID do Auth0 | Sim |
| `AUTH0_CLIENT_SECRET` | Client Secret do Auth0 | Sim |
| `AUTH0_AUDIENCE` | Audience da API Auth0 | Sim |

## Monitoramento

- **API Health:** http://localhost:5000/health
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090

## Backup do Banco

```bash
docker compose -f docker-compose.prod.yaml exec postgres pg_dump -U postgres SchoolManagementDb > backup_$(date +%Y%m%d).sql
```

## Restaurar Backup

```bash
cat backup.sql | docker compose -f docker-compose.prod.yaml exec -T postgres psql -U postgres SchoolManagementDb
```
