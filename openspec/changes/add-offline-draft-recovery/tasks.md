# Tasks — Rascunho local e recuperação após queda de conexão

## 1. Fundação (UI)

- [ ] 1.1 Criar `DraftStore` em IndexedDB (`sm-drafts` v1) com índices por tenant/usuário/formKey/updatedAt e operações `save`, `load`, `list`, `discard`, `sweep`. (owner: frontend)
- [ ] 1.2 Implementar versionamento de schema do rascunho e descarte de registros de versão desconhecida. (owner: frontend)
- [ ] 1.3 Implementar detecção de disponibilidade (`indexedDB` bloqueado, cota cheia) com fallback silencioso para operação sem rascunho. (owner: frontend)
- [ ] 1.4 Definir contrato `DraftableForm` (`formKey`, `draftScope`, `serialize`, `restore`, `baseVersion`) e a diretiva/helper de autosave com debounce de 2 s + flush em `visibilitychange`/`pagehide`. (owner: frontend)
- [ ] 1.5 Criar serviço de conectividade (eventos `online`/`offline` + foco da aba) exposto como signal. (owner: frontend)
- [ ] 1.6 Reaproveitar o wrapper de `localStorage` já usado por `services/session-inactivity.service.ts` para preferências leves, mantendo rascunhos no IndexedDB. (owner: frontend)

## 2. Interface de recuperação e estado

- [ ] 2.1 Criar banner de recuperação com data/hora e ações restaurar/descartar, acessível via teclado. (owner: frontend)
- [ ] 2.2 Criar indicador de estado: "salvo no servidor" vs "salvo neste dispositivo, aguardando envio" vs "sem conexão". (owner: frontend)
- [ ] 2.3 Criar diálogo de conflito com comparação e as ações "manter meu rascunho" / "descartar meu rascunho". (owner: frontend)
- [ ] 2.4 Adicionar guarda de navegação para formulários com alterações não enviadas, mantendo o rascunho local na saída. (owner: frontend)
- [ ] 2.5 Aviso único quando o rascunho automático estiver indisponível (cota/bloqueio). (owner: frontend)

## 3. Fila de submissão e idempotência

- [ ] 3.1 Persistir a submissão pendente no mesmo armazenamento, com chave de idempotência gerada no cliente. (owner: frontend)
- [ ] 3.2 Implementar reenvio em primeiro plano no evento de reconexão/foco, com retry exponencial limitado e desistência em 4xx. (owner: frontend)
- [ ] 3.3 Implementar suporte a `Idempotency-Key` nos endpoints de escrita dos fluxos cobertos (armazenamento de chave por tenant, TTL 24 h, resposta original em repetição). (owner: backend)
- [ ] 3.4 Garantir que 409/412 do servidor acionem o diálogo de conflito em vez de sobrescrever. (owner: frontend/backend)
- [ ] 3.5 Limpar a submissão pendente após confirmação do servidor. (owner: frontend)

## 4. Instrumentação das telas cobertas

- [ ] 4.1 Comunicado/documento (editor `contenteditable` + anexos como referência). (owner: frontend)
- [ ] 4.2 Cadastro de aluno (`features/students/ui/students.component.*`, caminho conforme spec arquivada `add-table-search-filters` — confirmar no submodule). (owner: frontend)
- [ ] 4.3 Cadastro de responsável. (owner: frontend)
- [ ] 4.4 Editor de template de relatório. (owner: frontend)
- [ ] 4.5 Lançamento de notas. (owner: frontend)
- [ ] 4.6 Registro de diário/observação. (owner: frontend)
- [ ] 4.7 Formulário de horário. (owner: frontend)
- [ ] 4.8 Cadastro do portal de matrícula (`components/portal/portal-register.component.ts` + `services/portal.service.ts`, conforme `specs/portal-registration-next-steps.md` — confirmar no submodule). (owner: frontend)

## 5. Privacidade e ciclo de vida

- [ ] 5.1 Aplicar TTL de 7 dias com varredura na inicialização e no login. (owner: frontend)
- [ ] 5.2 Limpar rascunhos no logout manual, preservando-os no logout automático por inatividade. (owner: frontend)
- [ ] 5.3 Garantir escopo por tenant/usuário em todas as leituras e remoções, com teste de troca de escola. (owner: frontend/qa)
- [ ] 5.4 Excluir anexos, credenciais e tokens do payload do rascunho. (owner: frontend/security)
- [ ] 5.5 Atualizar o aviso de privacidade informando que o rascunho fica no dispositivo e expira em 7 dias. (owner: product/legal)

## 6. Telemetria e feature flag

- [ ] 6.1 Emitir eventos `draft_saved`, `draft_restored`, `draft_discarded`, `draft_expired`, `submission_queued`, `submission_replayed`, `submission_conflict`. (owner: frontend/observability)
- [ ] 6.2 Publicar a feature atrás de flag `offlineDrafts`, com desligamento por tenant para rollback. (owner: frontend)

## 7. Testes e validação

- [ ] 7.1 Unit tests do `DraftStore`: TTL, isolamento por usuário/tenant, schema desconhecido, cota cheia. (owner: qa/frontend)
- [ ] 7.2 Unit tests do autosave: debounce, flush em `pagehide`, guarda de navegação. (owner: qa/frontend)
- [ ] 7.3 Testes de integração de idempotência: reenvio com a mesma chave cria um único registro; reenvio após resposta perdida devolve o resultado original. (owner: qa/backend)
- [ ] 7.4 E2E com perda de conexão simulada: digitar → derrubar rede → recarregar → restaurar rascunho → reconectar → envio concluído. (owner: qa/frontend)
- [ ] 7.5 E2E de conflito: edição concorrente em dois usuários resulta em diálogo, nunca em sobrescrita silenciosa. (owner: qa/frontend)
- [ ] 7.6 Executar `npx -y @fission-ai/openspec validate add-offline-draft-recovery --strict` e anexar evidência. (owner: product)
