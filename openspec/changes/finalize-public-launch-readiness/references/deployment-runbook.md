# Runbook de Deploy — School Management

## Pré-requisitos

- Docker + Docker Compose instalado
- .NET 10 SDK disponível
- Variáveis de ambiente configuradas (ver `.env.example`)

## Health Checks

### API Backend
```bash
curl -f http://localhost:5000/health || exit 1
curl -f http://localhost:5000/api/tenants/health || exit 1
```

### Frontend
```bash
curl -f http://localhost:4200/login || exit 1
```

## Deploy via Docker

```bash
# Build e start
docker compose -f docker-compose.prod.yml up -d --build

# Ver logs
docker compose -f docker-compose.prod.yml logs -f api

# Migrate database
docker compose -f docker-compose.prod.yml exec api dotnet ef database update

# Health check
docker compose -f docker-compose.prod.yml exec api curl http://localhost:5000/health
```

## Rollback

```bash
# Para rollback imediato
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build --force-recreate

# Restore DB se necessário (último backup automático)
docker compose -f docker-compose.prod.yml exec db pg_restore --clean --if-exists -d school_mgmt /backups/latest.dump
```

## Backup

```bash
# Backup diário automático via cron
# Executar manualmente:
pg_dump -h localhost -U school_mgmt school_mgmt > backups/school_mgmt-$(date +%Y%m%d).sql
```

## Estratégia de Migrações

1. Migrações são aplicadas automaticamente no startup via `context.Database.Migrate()`
2. Sempre testar migrações em ambiente de staging primeiro
3. Backup antes de migração em produção

## Contato de Incidentes

- **Primary On-call**: DevOps lead
- **Secondary**: Backend lead
- **Comunicação**: #ops-incidents no Discord