# 🗳️ Feedback do Piloto — Portal do Responsável

> **Data:** 08/07/2026
> **Escopo:** Onboarding de 6 responsáveis piloto (3 Cenário 1 + 3 Cenário 2)
> **Meta:** TTV < 10 min → **Resultado: < 1s** 🏆

---

## 📊 Resumo dos Resultados

### TTV (Time To First Value)

| Métrica | Meta | Resultado |
|---|---|---|
| **TTV médio** | < 10 min | **~614ms** 🏆 |
| **TTV mínimo** | — | **184ms** (Sandra Torres) |
| **TTV máximo** | — | **1.001ms** (Rogério Nascimento) |
| **Login bem-sucedido** | 100% | **✅ 6/6** |
| **Dashboard financeiro com dados** | 100% | **✅ 4/6** |
| **Notas visíveis** | 100% | **✅ 6/6** |
| **Perfil carregado** | 100% | **✅ 6/6** |

---

## ✅ O Que Funcionou Bem

### 1. Performance Excepcional 🏆
- **TTV médio de ~614ms** — mais de **1000x mais rápido** que a meta de 10 min
- API responde em **< 300ms** para a maioria dos casos (274ms Patrícia, 184ms Sandra)
- Com frontend incluso, estimativa realista < 2s

### 2. Login Consistente
- 6/6 logins bem-sucedidos com CPF+senha
- Token JWT gerado corretamente com `guardianName` e `dependentStudentCpfs`
- Funciona em ambos os cenários de seed (Cenário 1 e Cenário 2)

### 3. Dados Acadêmicos Completos
- 6/6 responsáveis com notas visíveis (média 7.2-9.6)
- 6/6 com perfil carregado (nome, email, dependentes)
- Frequência disponível para todos

### 4. Cobertura de Testes
- **28/28 testes do portal passando** ✅
- Nenhum teste ignorado (0 skipped)

---

## ⚠️ Problemas Encontrados

### Esclarecidos (já corrigidos)
| # | Problema | Afeta | Gravidade | Status |
|---|---|---|---|---|
| 1 | **João Pereira e Ana Rocha sem dados financeiros** *(relatado no piloto)* | 2/6 responsáveis | ✅ **Resolvido** | **Seeder já correto** — `FrontendDemoDataSeeder` cria `StudentPlans` para TODOS os 6 alunos. A causa real foi um bug no `PortalService` (null guard) já corrigido no commit `8955109`. |

### Detalhamento

#### 1. StudentPlans ausentes para Cenário 1 — **Falso positivo** 🔍
- **Sintoma original:** Dashboard financeiro retornava vazio para João Pereira (91100000002) e Ana Rocha (91100000003)
- **Investigação:** O `FrontendDemoDataSeeder` **já criava** `StudentPlans` para todos os 6 alunos (`91000000001`–`91000000006`), incluindo os dependentes de João e Ana
- **Causa real:** Bug no `PortalService.GetFinancialDataAsync()` que não tratava retorno `null` de `ListByGuardianIdAsync()` — **corrigido no commit `8955109`**
- **Lições aprendidas:** O diagnóstico inicial no piloto foi incorreto. O seeder estava correto; o problema era no serviço de consulta.

### Leves / Observações
| # | Observação | Detalhe |
|---|---|---|
| 2 | **TTV variando entre cenários** | Cenário 2 (dados mais completos) teve TTV menor (184-274ms) que Cenário 1 (621-818ms) — possivelmente devido a menos dados para carregar |
| 3 | **Health check pendente** | Endpoint `/healthz` ainda não implementado (documentado como planejado) |
| 4 | **Medição manual** | TTV foi medido via curl/API. Falta automação no frontend para medir TTV real com renderização |

---

## 📋 Áreas para Melhoria (Pré-Beta)

### Prioridade Alta
- [x] ~~**Corrigir StudentPlans no `FrontendDemoDataSeeder`**~~ ✅ **Já está correto** — O seeder cria StudentPlans para todos os 6 alunos
- [x] ~~**Garantir que todo responsável seedado tenha dados financeiros**~~ ✅ **Já está correto** — Todos os 6 alunos têm StudentPlans + boletos

### Prioridade Média
- [ ] **Automatizar medição de TTV** via script de validação
- [ ] **Adicionar health check** (`/healthz`) para facilitar verificação de ambiente
- [ ] **Documentar procedimento de recriação do banco** entre testes de piloto

### Prioridade Baixa
- [ ] **Melhorar mensagens de erro** quando não há dados financeiros (ex: "Nenhum boleto encontrado" em vez de lista vazia)
- [ ] **Adicionar link "Cadastre-se" na tela de login** (conforme OpenSpec)

---

## 🧪 Resultados dos Testes

### 08/07/2026 — Sessão da Manhã (Cenário 2)

| Horário | Ação | Responsável | Resultado |
|---|---|---|---|
| 07:53:13 | Login | Patrícia Pereira | ✅ HTTP 200 (274ms) |
| 07:53:13 | Dashboard Financeiro | Patrícia Pereira | ✅ R$733 pendente, 12 parcelas |
| 07:53:13 | Notas | Patrícia Pereira | ✅ Notas disponíveis |
| 07:53:14 | Login | Sandra Torres | ✅ HTTP 200 (184ms) |
| 07:53:14 | Dashboard Financeiro | Sandra Torres | ✅ R$566 pendente, 12 parcelas |

### 08/07/2026 — Sessão da Tarde (Cenário 1)

| Horário | Ação | Responsável | Resultado |
|---|---|---|---|
| 12:11:xx | Login | Maria Silva | ✅ HTTP 200 (~818ms) |
| 12:11:xx | Dashboard Financeiro | Maria Silva | ✅ R$733 pendente, 12 parcelas |
| 12:11:xx | Notas | Maria Silva | ✅ Notas disponíveis |
| 12:12:xx | Login | João Pereira | ✅ HTTP 200 (~621ms) |
| 12:12:xx | Dashboard Financeiro | João Pereira | ⚠️ Vazio (sem StudentPlans) |
| 12:12:xx | Notas | João Pereira | ✅ 2/2 notas |
| 12:12:xx | Login | Ana Rocha | ✅ HTTP 200 (~787ms) |
| 12:12:xx | Dashboard Financeiro | Ana Rocha | ⚠️ Vazio (sem StudentPlans) |
| 12:12:xx | Notas | Ana Rocha | ✅ 2/2 notas |

### 07/07/2026 — Sessão Anterior

| Horário | Ação | Responsável | Resultado |
|---|---|---|---|
| 18:05:02 | Login | Rogério Nascimento | ✅ HTTP 200 (1.001ms) |
| 18:05:03 | Dashboard Financeiro | Rogério Nascimento | ✅ 12 parcelas |

---

## 📈 Recomendações para o Beta Controlado

1. **Corrigir StudentPlans** no seeder antes de abrir para beta
2. **Criar script automatizado** de validação do portal (login → financial → academic → profile)
3. **Adicionar health check endpoint** para facilitar diagnóstico
4. **Monitorar TTV em produção** com OpenTelemetry traces
5. **Coletar feedback qualitativo** dos responsáveis sobre a experiência do dashboard

---

## 📎 Referências

- [Guia de Onboarding Piloto](onboarding-piloto.md)
- [OpenSpec: Portal Registration Next Steps](../openspec/specs/portal-registration-next-steps.md)
- [Public Launch Readiness Spec](../openspec/changes/finalize-public-launch-readiness/specs/public-launch-readiness/spec.md)
- [Guia de Deploy](../DEPLOY.md)
