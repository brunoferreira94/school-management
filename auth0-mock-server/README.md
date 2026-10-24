# Mock Auth0 Server - Development Environment

This server simulates the Auth0 OAuth endpoints during development.

## Usage

Start the server:
```bash
# Linux/Mac
node server.js

# Windows
node server.bat
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Port to listen on | `3001` |

## Endpoints

### POST `/oauth/token`

Returns a mock JWT token for testing.

**Request Body:**
```json
{
  "client_id": "mock-client-id",
  "client_secret": "mock-client-secret",
  "audience": "https://example.com"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 86400
}
```

### GET `/userinfo`

Returns mock user information (requires Authorization header).

**Request:**
```
GET /userinfo
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "sub": "auth0|12345678",
  "email": "dev@schoolmanagement.app",
  "name": "Usuário Desenvolvimento",
  "picture": "https://via.placeholder.com/150"
}
```

## Mock Data

The mock data is stored in `mock-auth0.json` and includes:
- `/oauth/token` - fake token generation
- `/userinfo` - mock user profile

## Integration with the Backend

Set the environment variable `AUTH_MODE=***` before running the app to activate mock mode.

## Testing

Use curl or Postman to test:

```bash
# Test token endpoint
curl -X POST http://localhost:3001/oauth/token \
  -H "Content-Type: application/json" \
  -d '{"client_id":"mock-client-id","client_secret":"mock-client-secret","audience":"https://example.com"}'

# Test userinfo endpoint
curl -X GET http://localhost:3001/userinfo \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```