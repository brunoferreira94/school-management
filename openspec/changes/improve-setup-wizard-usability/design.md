# Design — improve-setup-wizard-usability

## Context

A nota do Obsidian `School Management - Features Criativas.md` lista melhorias de Setup Wizard para reduzir erro manual e acelerar o onboarding de novas escolas. O frontend atual já possui `SetupWizardComponent`, modelos de request/response e serviço dedicado, mas o fluxo é predominantemente manual e não expõe importação em lote, capacidade de turmas ou ajuda contextual.

## Goals / Non-Goals

### Goals

- Reduzir erros de digitação e campos ambíguos durante a configuração inicial.
- Permitir cadastro rápido de cursos e turmas por importação em lote.
- Manter o Setup Wizard como fluxo principal de onboarding.
- Criar requisitos validáveis antes da implementação.

### Non-Goals

- Substituir o Setup Wizard por uma tela separada de importação.
- Implementar importação de alunos, responsáveis ou funcionários nesta change.
- Implementar Mobile/PWA, notificações push, chatbot ou calendário.

## Decisions

### Decision: Usar `automated-onboarding` como spec-alvo

O Setup Wizard atual mapeia melhor para a capability existente `automated-onboarding`, que já descreve onboarding guiado e importação em lote. Evita criar uma capability duplicada antes de confirmar se o produto terá uma spec permanente de setup wizard.

### Decision: CSV primeiro, Excel como extensão opcional

O CSV é o formato mais simples para template, preview e relatório de erros. A proposta exige CSV; suporte a Excel pode ser adicionado depois se houver biblioteca adequada e benefício claro para o usuário.

### Decision: Validação em duas camadas

Validações de CPF/CNPJ, capacidade de turmas e formato de importação devem existir no frontend para feedback imediato e no backend para garantir integridade antes de persistir.

### Decision: Capacidade padrão de 10 a 40 alunos

A nota sugere validação de capacidade mínima de turmas entre 10 e 40 alunos. Esse intervalo será usado como regra inicial, com possibilidade de configuração futura por tenant.

## Risks / Trade-offs

- **Risco:** O backend atual pode não aceitar novos campos de documento/capacidade.  
  **Mitigação:** confirmar contrato antes da implementação e, se necessário, estender o payload de forma compatível.

- **Risco:** Importação parcial pode gerar inconsistência.  
  **Mitigação:** tratar o lote como transação ou aplicar rollback em falhas críticas.

- **Risco:** Excel adiciona dependência e complexidade.  
  **Mitigação:** manter Excel fora do escopo inicial e revisar depois com evidência de demanda.

## Migration Plan

- Não alterar comportamento existente do Setup Wizard sem aprovação.
- Manter campos atuais obrigatórios e adicionar validações/importação como melhoria incremental.
- Se novos campos forem necessários, expor endpoint compatível e migrar frontend gradualmente.

## Open Questions

- O campo de CPF/CNPJ da unidade escolar já existe no backend ou precisa ser adicionado?
- A capacidade de turmas deve validar apenas turmas novas ou também turmas existentes em telas futuras?
- O importador deve aceitar UTF-8 BOM e separador `;` comum em planilhas brasileiras?
