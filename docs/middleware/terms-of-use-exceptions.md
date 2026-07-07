# Exceções do TermsOfUseEnforcementMiddleware

> Documentação estruturada de exceções, respostas HTTP e mecanismos de auditoria do middleware de aceitação de termos de uso.

## Visão Geral

O `TermsOfUseEnforcementMiddleware` é responsável por bloquear requisições autenticadas a endpoints `/api/*` até que o usuário aceite os termos de uso atuais. O middleware opera em modo **fail-closed** e **não lança exceções para casos de aceitação negada** — usa respostas HTTP específicas ao invés disso.

**Arquivo fonte:** `src/SchoolManagement/Middleware/TermsOfUseEnforcementMiddleware.cs`

---

## Exceções Lançadas

### 1. InvalidOperationException

| Campo | Valor |
|-------|-------|
| **Nome** | `InvalidOperationException` |
| **Tipo de Exceção** | `System.InvalidOperationException` |
| **Linha no Código** | Middleware: 99 / Controller: 144 |
| **Método** | `ResolveCurrentVersion()` |

#### Descrição do Erro
A exceção é lançada quando a configuração `Legal:TermsOfUseVersion` não está definida, não existe ou contém apenas espaços em branco.

#### Cenário de Ocorrência
- Falha de configuração em `appsettings.json` (chave `Legal:TermsOfUseVersion` ausente)
- Falha no provisionamento de variáveis de ambiente (variável `Legal__TermsOfUseVersion` não definida)
- Deploy em ambiente sem configuração mínima necessária

#### Payload da Exceção
```csharp
throw new InvalidOperationException("Configuration Legal:TermsOfUseVersion is required.");
```

#### Como Tratar

**Preventivo:**
- Verificar existência da chave em `appsettings.json`:
  ```json
  {
    "Legal": {
      "TermsOfUseVersion": "2026.1"
    }
  }
  ```
- Garantir que a variável de ambiente está definida em todos os ambientes:
  ```bash
  export Legal__TermsOfUseVersion="2026.1"
  ```

**Reactivo:**
- A exceção propaga pelo pipeline ASP.NET Core e resulta em um erro 500 (Internal Server Error) ou crasha a aplicação dependendo da configuração do `ExceptionHandler`.
- **NÃO** deve ser tratada por retry no cliente — é um erro de infraestrutura.

#### Referências para Logs/Auditoria
- **Logs de Infraestrutura:** A exceção aparece nos logs do ASP.NET Core como `Unhandled exception rendering component` ou `Application failed to start`.
- **Auditoria:** Não gera entrada em `TermsOfUseAcceptanceAudit` pois o fluxo não chega a esse ponto.
- **Alertas:** Configurar alerta no sistema de monitoramento (OpenTelemetry/Seq) para exceções `InvalidOperationException` contendo a mensagem "Configuration Legal:TermsOfUseVersion is required".

---

## Respostas HTTP (NÃO são exceções)

O middleware usa respostas HTTP estruturadas para fluxos de controle, não exceções.

### 2. 401 Unauthorized - Subject não identificado

| Campo | Valor |
|-------|-------|
| **Código HTTP** | `401 Unauthorized` |
| **Quando ocorre** | `subjectId` é `null`/vazio após `ResolveSubjectId()`

#### Payload de Erro
```json
{
  "message": "Unable to identify authenticated subject."
}
```

#### Quando ocorre
- Usuário não autenticado faz requisição a `/api/*` com o middleware aplicado (raro em prática)
- Token JWT existe mas não contém claims `sub`, `nameidentifier` ou `name`
- Configuração de autenticação inconsistente

#### Como tratar
- Cliente deve redirecionar para login/autenticação
- Não é um erro do Terms of Use — é erro de autenticação que precisa ser resolvido primeiro

#### Logs/Auditoria
- Aparece como log de warning em requisições não autenticadas
- Não gera auditoria pois não há identificação do usuário

---

### 3. 428 Precondition Required - Aceitação pendente

| Campo | Valor |
|-------|-------|
| **Código HTTP** | `428 Precondition Required` |
| **Quando ocorre** | Usuário autenticado mas não aceitou os termos atuais |

#### Payload de Erro
```json
{
  "code": "terms_of_use_acceptance_required",
  "message": "Current terms of use acceptance is required.",
  "pendingAcceptance": true,
  "currentVersion": "2026.1"
}
```

#### Quando ocorre
- Usuário autenticado faz requisição a qualquer endpoint `/api/*` (exceto exclusões abaixo)
- `TermsOfUseAcceptances` não tem registro para o `subjectId`
- Registro existe mas `TermsVersion` diferente da versão atual

#### Como tratar

**Frontend:**
1. Detectar resposta 428
2. Chamar `GET /api/privacy/terms-of-use/status` para obter versão atual
3. Exibir modal de aceite com termos atualizados
4. Enviar aceite via `POST /api/privacy/terms-of-use/accept`
5. Repetir requisição original

**API Client:**
```typescript
// Exemplo de tratamento
if (response.status === 428) {
  const error = await response.json();
  // Redirecionar para tela de aceite
  router.navigate(['/terms-of-use'], { queryParams: { version: error.currentVersion } });
}
```

#### Logs/Auditoria
- Cada tentativa de acesso a endpoint protegido gera log de informação
- Após aceite bem-sucedido, `TermsOfUseAcceptanceAudit` é criado com:
  ```csharp
  new TermsOfUseAcceptanceAudit {
    SubjectId = "user:123",
    TermsVersion = "2026.1",
    Channel = "web",
    IpHash = "<sha256>",
    UserAgentHash = "<sha256>",
    IsReacceptByVersionChange = false,
    AcceptedAtUtc = DateTime.UtcNow
  }
  ```

---

## Caminhos IGNORADOS (não aplicam o middleware)

| Caminho | Motivo |
|---------|--------|
| `/api/auth/*` | Endpoints de autenticação — não podem exigir aceite prévio |
| `/api/privacy/terms-of-use/*` | Endpoint de aceite dos próprios termos |
| `/api/privacy/cookie-consent/*` | Consentimento de cookies — fluxo separado |
| `/api/subscriptions/webhooks` | Webhooks externos — não têm contexto de usuário |
| `/api/support/*` | Endpoints de suporte podem precisar de acesso pré-aceite |
| Requisições `OPTIONS` | CORS preflight não precisa de autenticação |

---

## Schema de Resposta do Endpoint de Status

### TermsOfUseStatusResponse

```json
{
  "accepted": true,
  "pendingAcceptance": false,
  "currentVersion": "2026.1",
  "acceptedVersion": "2026.1",
  "acceptedAtUtc": "2026-06-20T14:30:00Z"
}
```

#### Campos

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `accepted` | `boolean` | Se o usuário aceitou os termos atuais |
| `pendingAcceptance` | `boolean` | Se há aceite pendente |
| `currentVersion` | `string` | Versão atual dos termos de uso |
| `acceptedVersion` | `string \| null` | Versão aceita pelo usuário (se houver) |
| `acceptedAtUtc` | `datetime \| null` | Timestamp do aceite (ISO 8601) |

---

## Schema de Auditoria

### TermsOfUseAcceptanceAudit

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `Id` | `Guid` | Identificador único do registro |
| `SubjectId` | `string(200)` | Identificador do usuário (formato `user:{id}` ou `anon:{hash}`) |
| `TermsVersion` | `string(32)` | Versão aceita |
| `PreviousTermsVersion` | `string(32) \| null` | Versão anterior (se reaceite por mudança) |
| `Channel` | `string(20)` | Canal de aceite: `web`, `mobile`, etc. |
| `IpHash` | `string(64) \| null` | Hash SHA256 do IP (não raw IP por LGPD) |
| `UserAgentHash` | `string(64) \| null` | Hash SHA256 do User-Agent |
| `IsReacceptByVersionChange` | `boolean` | Se é reaceite após mudança de versão |
| `TenantId` | `Guid` | Tenant do contexto multi-tenancy |
| `AcceptedAtUtc` | `datetime` | Quando aceito |
| `CreatedAtUtc` | `datetime` | Criação do registro |

---

## Fluxo de Execução do Middleware

```
┌─────────────────────────────────────────────────────────────┐
│                    Request chega ao middleware               │
└─────────────────────────────┬───────────────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ ShouldEnforce() → false?                                   │
│ - Método OPTIONS?                                          │
│ - Não autenticado?                                       │
│ - Path fora de /api?                                     │
│ - Path em exceções (/api/auth, /api/privacy/*, ...)?       │
└─────────────────────────────┬───────────────────────────────┘
                              │ Sim
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ await _next(context)                                       │
│                        (request prossegue)                  │
└─────────────────────────────┬───────────────────────────────┘
                              │ Não
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ ResolveSubjectId() → null/whitespace?                       │
└─────────────────────────────┬───────────────────────────────┘
                              │ Sim
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ 401 Unauthorized                                           │
│ { "message": "Unable to identify authenticated subject." }    │
└─────────────────────────────┬───────────────────────────────┘
                              │ Não
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ ResolveCurrentVersion() → null/whitespace?                   │
└─────────────────────────────┬───────────────────────────────┘
                              │ Sim
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ InvalidOperationException                                │
│ "Configuration Legal:TermsOfUseVersion is required."       │
└─────────────────────────────┬───────────────────────────────┘
                              │ Não
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ Verificar TermsOfUseAcceptances                            │
│ subjectId + tenantId + versão atual                        │
└─────────────────────────────┬───────────────────────────────┘
                              │ Já aceitou
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ await _next(context)                                       │
│                        (request prossegue)                  │
└─────────────────────────────┬───────────────────────────────┘
                              │ Não aceitou
                              ▼
┌─────────────────────────────────────────────────────────────┐
│ 428 Precondition Required                                  │
│ { "code": "terms_of_use_acceptance_required", ... }        │
└─────────────────────────────────────────────────────────────┘
```

---

## Checklist de Verificação

- [ ] `Legal:TermsOfUseVersion` definido em `appsettings.json`
- [ ] Variável de ambiente `Legal__TermsOfUseVersion` definida em produção
- [ ] Endpoint `/api/privacy/terms-of-use/status` responde corretamente
- [ ] Endpoint `/api/privacy/terms-of-use/accept` persiste aceite
- [ ] Auditoria em `TermsOfUseAcceptanceAudits` é criada após aceite
- [ ] Resposta 428 inclui `currentVersion` válido
- [ ] Caminhos excluídos estão funcionando (auth, webhooks, etc.)

---

## Vieses de Versão de Termos

Quando `Legal:TermsOfUseVersion` muda (ex: "2026.1" → "2027.1"):

1. Usuários existentes mantêm registro com versão antiga
2. Próxima requisição detecta versão diferente
3. Retorna 428 com `pendingAcceptance: true`
4. Após novo aceite, `IsReacceptByVersionChange = true` em auditoria
5. `PreviousTermsVersion` contém a versão antiga

---

## Referências Cruzadas

- **Implementação do Middleware:** `src/SchoolManagement/Middleware/TermsOfUseEnforcementMiddleware.cs`
- **Controller de Terms:** `src/SchoolManagement/Controllers/Privacy/TermsOfUseController.cs`
- **Entidade de Auditoria:** `src/SchoolManagement.Domain/TermsOfUseAcceptanceAudit.cs`
- **Testes de Integração:** `tests/SchoolManagement.Tests/Integration/PrivacyIntegrationTests.cs`
- **Documentação LGPD:** `../lgpd-data-endpoints.md`