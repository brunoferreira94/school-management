# Tasks — Busca → ação contextual

## 1. Backend
- [x] 1.1 `GET /api/search/entities?q=`: busca alunos (nome/CPF) e turmas (nome, tenant-correct) com `actions[]` por tipo de entidade — aluno: Financeiro, 2ª via, Matrícula, Notas; turma: Comunicado, Notas, Diário
- [x] 1.2 Ações filtradas pelas permissões de quem busca (claims "permission" do JWT — ex.: professor sem `finance.manage` não recebe Financeiro/2ª via)
- [x] 1.3 Ação executada a partir da busca é registrada no analytics existente (`search-action:{id}` via TrackSearchAnalytics) e no histórico

## 2. Frontend
- [x] 2.1 Palette: resultados de entidades ("Resultados") com chips de ação contextual por resultado (busca debounced, ≥ 2 caracteres)
- [x] 2.2 Executar ação direto do resultado: navega com contexto (ex.: 2ª via → `/finance?student={cpf}&tab=faturas`), registra histórico + analytics e fecha a palette — **2ª via abre as faturas do aluno no financeiro; PDF instantâneo direto da palette aguarda link de cobrança do gateway (Asaas) — mesmo item pendente do change de WhatsApp**
- [ ] 2.3 Teclado: Tab alterna entre resultados e ações — **parcial: chips são botões reais (Tab nativo); setas continuam navegando os resultados estáticos**

## 3. Testes
- [x] 3.1 API: aluno devolve ações permitidas pelo papel (financeiro inclui 2ª via; professor sem financeiro não vê); turma com ações de comunicado/notas/diário; isolamento por tenant (6 testes)
- [x] 3.2 Unitário frontend: serviço consulta `/search/entities?q=`; executar ação navega com contexto e fecha a palette (specs da palette adaptados à nova pipeline: 20/20)
- [ ] 3.3 E2E: usuário busca aluno e gera 2ª via sem navegar para outra tela
