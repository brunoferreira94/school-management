# Como usar .NET User-Secrets para Asaas (billing) keys

## No ambiente de produção, armazene as chaves do Asaas usando o .NET User Secrets, não em arquivos de configuração.

### Passos

1. **Certifique-se de que o SDK .NET está instalado**
2. **Abra o terminal no diretório do projeto**
   ```bash
   cd /home/bruno/workspace/school-management/school-management-api/src/SchoolManagement
   ```
3. **Prepare o ambiente**
   ```bash
   dotnet user-secrets set ASAAS_API_KEY=<production-asaas-api-key>
   dotnet user-secrets set ASAAS_WEBHOOK_TOKEN=<production-asaas-webhook-token>
   ```
4. **Verifique**
   ```bash
   dotnet user-secrets list
   ```
5. **Reinicie o aplicativo**
   - Quando a aplicação .NET inicia, ela lê automaticamente os segredos de usuário para valores de configuração de ambiente.

### Em docker-compose.prod.yaml (produção)

```yaml
environment:
  - ASAAS_API_KEY = production Asaas API key (use .NET user-secrets)
  - ASAAS_WEBHOOK_TOKEN = production Asaas webhook token (use .NET user-secrets)
```

### Em .env.example (documentação)

```env
# Asaas (billing)
# ASAAS_API_KEY = production Asaas API key (use .NET user-secrets)
# ASAAS_WEBHOOK_TOKEN = production Asaas webhook token (use .NET user-secrets)
```

### Em appsettings.Production.json (produção)

```json
"Asaas": {
  "ApiBaseUrl": "https://api.asaas.com/v3",
  // Asaas API key and webhook token should be set via .NET user-secrets in production
  "ApiKey": "{{USER_SECRETS_KEY}}",
  "TimeoutSeconds": 30,
  "WebhookToken": "{{USER_SECRETS_KEY}}"
}
```

## Por que usar .NET User Secrets?

- **Seguro**: Chaves não são gravadas no código-fonte
- **Por perfil**: Diferentes segredos para dev/staging/produção
- **Integrado**: Funciona com key-per-file e contêineres (use mounts do host para se reaproveitar)
- **Não versionado**: Fica fora do controle do código, como deve ser

## Para container Docker (execução local)

### Usando volumes de host

```bash
docker run \
  -v ~/.dotnet/user-secrets:/root/.microsoft/usersecrets \
  -e ASPNETCORE_ENVIRONMENT=Production \
  schoolmanagement-api:latest
```

### Usando .NET User Secrets CLI dentro do container

```bash
docker exec -it <container_id> bash
cd /app
# Se você tiver montado ~/.dotnet/user-secrets:
dotnet user-secrets list
```
