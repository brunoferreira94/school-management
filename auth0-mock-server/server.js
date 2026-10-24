// Express mock backend para Auth0
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Mock data baseado em mock-auth0.json
const mockData = {
  oauth: {
    token: {
      access_token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhdXRoMHxNSU1FbmV0SXNzdWVzIiwiaXNzIjoiaHR0cHM6Ly9leGFtcGxlLmNvbSIsImV4cCI6MTcyODU5OTk5OX4.xxxxx',
      token_type: 'Bearer',
      expires_in: 86400
    }
  },
  userinfo: {
    sub: 'auth0|12345678',
    email: 'dev@schoolmanagement.app',
    name: 'Usuário Desenvolvimento',
    picture: 'https://via.placeholder.com/150'
  }
};

// Endpoint OAuth token
app.post('/oauth/token', (req, res) => {
  const { client_id, client_secret, audience } = req.body;
  
  // Validação básica para desenvolvimento
  if (!client_id || !client_secret || !audience) {
    return res.status(400).json({
      error: 'invalid_request',
      error_description: 'Missing required parameters'
    });
  }
  
  // Retorna token mockado
  res.json(mockData.oauth.token);
});

// Endpoint userinfo
app.get('/userinfo', (req, res) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'unauthorized',
      error_description: 'Invalid or missing token'
    });
  }
  
  const token = authHeader.split(' ')[1];
  
  // No mock, apenas valida o formato do token
  if (!token || token.split('.').length !== 3) {
    return res.status(401).json({
      error: 'invalid_token',
      error_description: 'Token malformatado ou inválido'
    });
  }
  
  // Retorna mock user-info
  res.json(mockData.userinfo);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'auth0-mock', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`🚀 Auth0 mock backend rodando na porta ${PORT}`);
  console.log(`📡 Endpoints disponíveis:
   POST /oauth/token
   GET  /userinfo
   GET  /health
`);
});