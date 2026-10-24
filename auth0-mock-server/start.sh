# Script para iniciar o mock do Auth0

## Instalação

```bash
cd auth0-mock-server
npm install
```

## Execução

```bash
# Start em modo de desenvolvimento (mock)
node server.js

# Ou com ambiente especificado para usar o mock
export AUTH_MODE=***
node server.js
```

## Verificando se está rodando

```bash
# Abre navegador em http://localhost:3001
# Teste o endpoint /userinfo
curl -X GET http://localhost:3001/userinfo \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```