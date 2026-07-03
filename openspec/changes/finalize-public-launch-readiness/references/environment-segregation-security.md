# Segregação de Ambientes — TLS e Segurança

## Variáveis de Ambiente

| Variável | Ambiente | Descrição |
|---|---|---|
| `ASPNETCORE_ENVIRONMENT` | Todos | `Development`, `Staging`, `Production` |
| `JWT_SECRET` | Prod/Staging | Segredo JWT mínimo 32 caracteres |
| `AUTH0_*` | Prod/Staging | Credenciais Auth0 de produção |
| `ASAAS_API_KEY` | Prod/Staging | API Key do Asaas (produção usa ambiente prod) |
| `STRIPE_SECRET_KEY` | Prod/Staging | Stripe live key (não test key) |

## TLS/HTTPS

### Nginx Reverse Proxy (docker-compose.prod.yml)

Para habilitar TLS com nginx:

```bash
# Criar diretório SSL
mkdir -p nginx/ssl

# Gerar certificado (Let's Encrypt production)
certbot certonly --standalone -d api.yourdomain.com
certbot certonly --standalone -d app.yourdomain.com

# Copiar certificados
cp /etc/letsencrypt/live/api.yourdomain.com/* nginx/ssl/
```

### Configuração Nginx (`nginx/nginx.conf`)

```nginx
server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    location / {
        proxy_pass http://api:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Segregação Staging vs Production

### Staging (`docker-compose.staging.yml`)

- Usa `development` como base
- Auth0 sandbox
- Asaas sandbox  
- Secrets de staging (não reutiliza produção)

### Production (`docker-compose.prod.yml`)

- Usa `Production` environment
- Auth0 production
- Asaas production
- Secrets de produção via `.env`

## Segurança de Secrets

- NUNCA commitar `.env` no repositório
- Usar secrets management em produção:
  - Azure Key Vault
  - AWS Secrets Manager
  - Docker secrets

## CI/CD Variáveis

```yaml
# GitHub Actions
env:
  ASPNETCORE_ENVIRONMENT: Development  # CI usa dev
  JWT_SECRET: ${{ secrets.JWT_SECRET }}  # GitHub Secrets
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

## Verificação de Segurança

```bash
# Verificar endpoint em HTTPS
curl -v https://api.yourdomain.com/health

# Verificar headers de segurança
curl -I https://api.yourdomain.com/api/tenants/health | grep -i strict-transport
```