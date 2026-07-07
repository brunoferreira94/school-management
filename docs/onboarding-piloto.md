# 🎯 Onboarding Guiado — Escola Piloto (Portal do Responsável)

> **Meta TTV (Time To First Value): < 10 minutos**
> O responsável deve conseguir ver dados reais do estudante (boletos, notas, frequência) em até 10 minutos após o primeiro acesso.

---

## 📋 Pré-requisitos

Antes de iniciar, garanta que:

- [ ] Ambiente da API está rodando (ver [DEPLOY.md](../DEPLOY.md))
- [ ] Seed data foi gerada (`FrontendDemoDataSeeder` executado na inicialização)
- [ ] PostgreSQL acessível e migrações aplicadas
- [ ] Frontend do portal implantado (ou acesso direto à API via Swagger/curl)
- [ ] Credenciais da escola piloto definidas

---

## 🚀 Fluxo Completo (Passo a Passo)

### Fase 1 — Preparação do Ambiente (Administrador)

> **Tempo estimado:** 5 min  
> **Quem executa:** Equipe técnica / Administrador da escola

#### 1.1 Verificar que a API está respondendo

```bash
curl -s -w "\nHTTP: %{http_code}" http://localhost:5083/api/portal/auth/validate-email?email=test@test.com
```

**Esperado:** HTTP 400 (indica que a API está rodando e aceitando requisições)

> ⚠️ O health check dedicado (`/healthz`) está em planejamento.

---

### Fase 2 — Cadastro do Responsável (Guardian)

> **Tempo estimado:** 2 min  
> **Quem executa:** Responsável financeiro (mãe/pai)

#### Opção A — Login com dados seed (teste rápido)

> ⚠️ Use os CPFs que existem no banco. Verifique com o administrador qual conjunto de dados foi seedado.

**Cenário 1 — Dados do `FrontendDemoDataSeeder` (banco limpo):**

| Responsável | CPF | Senha |
|---|---|---|
| **Maria Silva** | `91100000001` | `Senha123!` |
| **João Pereira** | `91100000002` | `Senha123!` |
| **Ana Rocha** | `91100000003` | `Senha123!` |

Os vínculos e dados financeiros/acadêmicos completos (boletos, notas, frequência) estão disponíveis.

**Cenário 2 — Banco com seed anterior (ex.: `DemoDataSeeder`):**

| Responsável | CPF | Senha |
|---|---|---|
| **Patrícia Pereira** | `92000000001` | `Senha123!` |
| **Rogério Nascimento** | `92000000002` | `Senha123!` |
| **Sandra Torres** | `92000000003` | `Senha123!` |

> Dados financeiros e acadêmicos podem ser parciais neste cenário. Para descobrir o CPF do estudante vinculado, consulte a tabela `StudentGuardians` no banco ou tente com `91000000001` (Alice Silva).

```bash
# Login (ajuste o CPF conforme o cenário)
curl -s -w "\nHTTP: %{http_code}" -X POST http://localhost:5083/api/portal/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"91100000001","password":"Senha123!"}'
```

**Esperado:** HTTP 200 com token JWT, `guardianName`, `dependentStudentCpfs`

#### Opção B — Cadastro novo (fluxo real)

> ⚠️ Requer Auth0 configurado e credenciais de e-mail

```bash
# 1. Registrar novo responsável
curl -s -X POST http://localhost:5083/api/portal/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "cpf": "12345678901",
    "name": "Novo Responsável",
    "email": "responsavel@email.com",
    "phone": "(11) 99999-1234",
    "password": "MinhaSenha123!"
  }' | jq .
```

**Esperado:** HTTP 201 com `guardianId`, `auth0Sub`, mensagem de verificação de e-mail

---

### Fase 3 — Dashboard Financeiro (💰 **Primeiro Valor**)

> **Tempo estimado:** 1 min  
> **TTV:** ⏱️ Marcar horário — este é o momento do primeiro valor!

Com o token obtido no login, acesse os dados financeiros:

```bash
# Extrair token (ajuste o CPF conforme necessário)
TOKEN=$(curl -s -X POST http://localhost:5083/api/portal/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"91100000001","password":"Senha123!"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# Dashboard financeiro
curl -s -w "\nHTTP: %{http_code}" http://localhost:5083/api/portal/financial/summary \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>/dev/null || curl -s http://localhost:5083/api/portal/financial/summary \
  -H "Authorization: Bearer $TOKEN"
```

**Esperado:** HTTP 200 com:
- Lista de parcelas/boletos do estudante
- Total pendente e total pago
- Status de cada parcela (Pago / Pendente / Vencido)
- URL para download do boleto (`/api/portal/financial/installments/{id}/boleto`)

**✅ PRIMEIRO VALOR ATINGIDO! — Marque o horário!**

---

### Fase 4 — Notas e Frequência (Acadêmico)

> **Tempo estimado:** 1 min

```bash
# Notas do estudante (substituir pelo CPF do estudante vinculado)
curl -s -w "\nHTTP: %{http_code}" http://localhost:5083/api/portal/academic/91000000001/grades \
  -H "Authorization: Bearer $TOKEN"
```

**Esperado:** HTTP 200 com lista de notas do estudante (ex.: 7.8, 8.4)

---

### Fase 5 — Perfil e Dados Pessoais

> **Tempo estimado:** 1 min

```bash
# Dados do perfil
curl -s -w "\nHTTP: %{http_code}" http://localhost:5083/api/portal/profile \
  -H "Authorization: Bearer $TOKEN"
```

**Esperado:** HTTP 200 com nome, e-mail, telefone e solicitações de alteração pendentes

---

## 📊 Medição de TTV (Time To First Value)

### Planilha de Registro

Copie esta tabela para registrar o TTV de cada responsável piloto:

| Responsável | CPF | Início (Fase 2) | Fim (Fase 3) | TTV (min) | Observações |
|---|---|---|---|---|---|
| Maria Silva | 91100000001 | `__:__` | `__:__` | `__ min` | |
| João Pereira | 91100000002 | `__:__` | `__:__` | `__ min` | |
| Ana Rocha | 91100000003 | `__:__` | `__:__` | `__ min` | |

### Critérios de Aceite

| Critério | Meta | Resultado |
|---|---|---|
| **TTV médio** | < 10 min | `__ min` |
| **Login bem-sucedido** | 100% | `__ / __` |
| **Dashboard financeiro com dados** | 100% | `__ / __` |
| **Notas visíveis** | 100% | `__ / __` |
| **Perfil carregado** | 100% | `__ / __` |

---

## 🧪 Validação Técnica (Opcional)

Para validar que todos os endpoints estão saudáveis:

```bash
#!/bin/bash
# Script de validação rápida

API="http://localhost:5083"
CPF="91100000001"
PASS="Senha123!"
STUDENT_CPF="91000000001"

echo "=== 1. Login ==="
TOKEN=$(curl -s -X POST "$API/api/portal/auth/login" \
  -H 'Content-Type: application/json' \
  -d "{\"cpf\":\"$CPF\",\"password\":\"$PASS\"}" | jq -r '.token')
echo "Token: ${TOKEN:0:20}..."

echo -e "\n=== 2. Financial Summary ==="
curl -s "$API/api/portal/financial/summary" \
  -H "Authorization: Bearer $TOKEN" | jq '{total_pending, total_paid, pending_count, paid_count}'

echo -e "\n=== 3. Academic Grades ==="
curl -s "$API/api/portal/academic/$STUDENT_CPF/grades" \
  -H "Authorization: Bearer $TOKEN" | jq '. | length as $len | "\($len) grades found"'

echo -e "\n=== 4. Profile ==="
curl -s "$API/api/portal/profile" \
  -H "Authorization: Bearer $TOKEN" | jq '{name, email, phone}'
```

---

## 🐛 Troubleshooting Comum

| Problema | Causa Provável | Solução |
|---|---|---|
| **HTTP 401 — Credenciais inválidas** | CPF ou senha incorretos | Verificar CPF (apenas números) e senha (`Senha123!`) |
| **HTTP 429 — Too Many Requests** | Rate limiting | Aguardar 30s e tentar novamente |
| **HTTP 500 — Erro interno** | Problema de banco | Verificar logs da API |
| **HTTP 403 — Forbidden** | Sem permissão para o estudante | Verificar vínculo responsável↔aluno |
| **Token expirado** | Token JWT > 1h | Fazer novo login |
| **Seed data não encontrada** | FrontendDemoDataSeeder não executou | Verificar logs de startup ou reiniciar API |

---

## ✅ Checklist de Saída do Piloto

Antes de liberar a escola piloto para o beta controlado:

- [ ] **TTV** < 10 minutos registrado para pelo menos 3 responsáveis
- [ ] Login com CPF+senha funciona consistentemente
- [ ] Dashboard financeiro exibe boletos corretos
- [ ] Notas e frequência carregam sem erros
- [ ] Perfil do responsável é exibido corretamente
- [ ] **28 testes do portal** passam (25 passed ✅, 3 skipped ℹ️) (`dotnet test --filter Portal`)
- [ ] Evidências registradas (vídeo/screenshots do fluxo completo)
- [ ] Feedback do piloto coletado e documentado

---

## 📎 Referências

- [Plano de Lançamento do Produto](PLANO_LANCAMENTO_PRODUTO.md)
- [Guia Rápido de Lançamento](LANCAMENTO_GUIA_RAPIDO.md)
- [Portal Responsável — OpenSpec Tasks](../openspec/changes/validate-responsible-portal-end-to-end/tasks.md)
- [Public Launch Readiness Spec](../openspec/changes/finalize-public-launch-readiness/specs/public-launch-readiness/spec.md)
- [Guia de Deploy](../DEPLOY.md)
- [Exemplos de Importação (CSV)](../school-management-api/examples/)
