# Suporte Rápido - Chatbot com Perfis

## Dois perfis distintos

- **Staff** (`/api/support/options/staff`) — Funcionários da escola
- **Parent** (`/api/support/options/parent`) — Pais/Responsáveis

## Endpoints

### GET /api/support/options/staff

Opções para funcionários:
- acesso, turmas, horarios, notas, frequencia, relatorios, comunicado, importacao, suporte

### GET /api/support/options/parent

Opções para pais/responsáveis:
- acesso, notas, frequencia, pagamento, mensalidade, horario, evento, comunicado, contato

### POST /api/support/ask

**Headers:**
```
X-User-Type: staff | parent
```

**Request:**
```json
{ "option": "notas" }
```

### GET /api/support/sla

SLA system (acesso interno).

## Integração Frontend

```typescript
// detectar perfil do usuário logado
getProfile() {
  // staff = professor, secretaria, admin
  // parent = responsável
  return this.auth.user.type === 'staff' ? 'staff' : 'parent';
}

getOptions() {
  const profile = this.getProfile();
  return this.http.get(`/api/support/options/${profile}`);
}
```