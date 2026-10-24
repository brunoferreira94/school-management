# Instruções para iniciar o mock do Auth0

## 1️⃣ Preparar o ambiente

```bash
# Entre na pasta do mock server
cd /home/bruno/workspace/school-management/auth0-mock-server

# Instale as dependências (se ainda não estiverem instaladas)
npm install
```

## 2️⃣ Iniciar o servidor de mock

```bash
# Inicie o servidor (modo desenvolvimento)
node server.js

# OU, se preferir, use o script de start (já configurado para usar nodemon)
./start.sh
```

> O servidor ficará escutando em **http://localhost:3001**  
> - Endpoint `/oauth/token` → retorna token mockado  
> - Endpoint `/userinfo` → retorna dados de usuário mockados  
> - Endpoint `/health` → verifica se o serviço está ativo  

## 3️⃣ Configurar o backend para usar o mock

No seu projeto **school-management**, defina a variável de ambiente `AUTH_MODE` como `***` (ou outro valor que indique "modo mock") no seu arquivo `.env` ou no ambiente do seu servidor:

```bash
# Exemplo .env (adicione ao final do arquivo)
AUTH_MODE=***
# (Outras variáveis de ambiente da API, como DB connection string, etc.)
```

> **Importante:** O `Auth0Options` que você configurou no `appsettings.Development.json` já contém os valores de mock (`mock-auth0.local`, `mock-client-id`, etc.). O código do .NET lerá essas variáveis automaticamente.

## 4️⃣ Testar o mock

```bash
# Verificar se o servidor está rodando
curl -s http://localhost:3001/health
# → {"status":"ok","service":"auth0-mock"}

# Testar o endpoint de token
curl -X POST http://localhost:3001/oauth/token \
  -H "Content-Type: application/json" \
  -d '{"client_id":"mock-client-id","client_secret":"mock-secret-key","audience":"http://localhost:5066/api"}' \
  | jq .

# Testar o endpoint de usuário
curl -X GET http://localhost:3001/userinfo \
  -H "Authorization: Bearer <seu-token>" \
  | jq .
```

Se tudo estiver configurado corretamente, você verá respostas JSON com os dados mockados.

## 📌 Dicas rápidas

- **Alterar a porta**: basta mudar a variável `PORT` no `server.js` ou definir a variável de ambiente `PORT` antes de iniciar o servidor.  
- **Logs**: O servidor imprime mensagens de status ao iniciar; verifique o console para confirmar que está rodando.  
- **Parar o servidor**: `Ctrl + C` (ou `Ctrl + C` no Windows).  
- **Reiniciar**: basta rodar novamente `node server.js` ou `./start.sh`.

---

### 📌 Resumo rápido (para copiar e colar)

```bash
# 1. Entrar na pasta do mock
cd /home/bruno/workspace/school-management/auth0-mock-server

# 2. Instalar dependências (se ainda não estiverem)
npm install

# 3. Iniciar o servidor
node server.js        # ou ./start.sh

# 4️⃣ Verificar se está rodando
curl http://localhost:3001/health

# 5️⃣ Testar endpoints
curl http://localhost:3001/oauth/token -d '{"client_id":"mock-client-id","client_secret":"mock-secret-key","audience":"http://localhost:5066/api"}'
curl http://localhost:3001/userinfo -H "Authorization: Bearer <seu-token>"
```

Pronto! Seu ambiente de desenvolvimento agora tem um **mock completo do Auth0** que pode ser usado sem modificar o código da aplicação. Boa codificação! 🚀