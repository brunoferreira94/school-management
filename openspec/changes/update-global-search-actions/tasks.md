## 1. Backend
- [ ] 1.1 Estender o payload de resultados do global search com `actions[]` por tipo de entidade (aluno → financeiro/2ª via/matricula; turma → comunicado/notas)
- [ ] 1.2 Ações filtradas pelas permissões do usuário que busca (reusar PermissionHandler)
- [ ] 1.3 Registrar ação executada a partir da busca (telemetria de uso para priorizar)

## 2. Frontend
- [ ] 2.1 Na palette de busca, cada resultado mostra os botões de ação contextuais (Teclado: Tab alterna entre resultados e ações)
- [ ] 2.2 Executar ação direto do resultado (ex.: 2ª via abre o PDF; financeiro navega com contexto do aluno)

## 3. Testes
- [ ] 3.1 API: busca de aluno devolve ações permitidas para o papel do usuário; ações sem permissão não aparecem
- [ ] 3.2 E2E: usuário busca aluno e gera 2ªvia sem navegar para outra tela
