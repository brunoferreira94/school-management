## Context

A UI é Angular 22 (standalone + signals, `localStorage` já usado para preferências como idioma e timeout de inatividade) e a API é ASP.NET Core com CQRS via LiteBus. A PWA já tem Service Worker com cache do app shell e página `/offline`, mas cache de shell não protege dado digitado. O público usa o sistema em escolas com internet instável (tablet do professor, secretaria com link compartilhado), e algumas telas produzem textos longos (comunicados em `contenteditable`, layout de relatório, observações de diário).

O backend não tem hoje deduplicação de escrita: um `POST` reenviado cria registro duplicado. Isso é o principal risco técnico de qualquer reenvio automático.

## Goals / Non-Goals

- **Goals:** zero perda de conteúdo digitado em quedas de conexão; recuperação óbvia e com um clique; reenvio sem duplicar dados; isolamento por tenant/usuário; nenhum bloqueio de UI quando o armazenamento local falha.
- **Non-Goals:** offline-first amplo; Background Sync; upload retomável de anexos; merge automático de edições concorrentes; novos modelos de domínio.

## Decisions

- **Decision: IndexedDB, não `localStorage`.** Rascunhos de comunicados e layouts de relatório passam de 100 KB, e `localStorage` é síncrono (trava a thread) e limitado a ~5 MB por origem. IndexedDB é assíncrono e tem cota maior. `localStorage` continua apenas para preferências leves. Alternativa considerada: `localStorage` — rejeitada por tamanho e bloqueio da UI.
- **Decision: um serviço `DraftStore` com uma store única (`sm-drafts`, versão 1) e índices por `tenantId`, `userId`, `formKey`, `updatedAt`.** IndexedDB puro, sem dependência nova, embrulhado numa API pequena (`save`, `load`, `discard`, `list`, `sweep`).
- **Decision: contrato `DraftableForm`, declarado por formulário, em vez de interceptar `FormGroup` globalmente.** Cada tela informa `formKey`, `draftScope` (ex.: `student:{id}` ou `new`), `serialize()` e `restore(draft)`. Interceptação global de formulários foi considerada e rejeitada: nem todo formulário merece rascunho (filtros, busca, login), e o payload precisa ser enxuto e explícito.
- **Decision: autosave por *debounce* de 2 s após a última alteração + *flush* em `visibilitychange`/`pagehide`.** Um intervalo fixo salvaria lixo e um autosave a cada tecla degradaria a digitação. `pagehide` cobre o fechamento de aba, que `beforeunload` não garante.
- **Decision: chave do rascunho inclui tenant + usuário: `v1:{tenantId}:{userId}:{formKey}:{scope}`.** Impede que um rascunho de uma escola (ou de outro usuário no mesmo computador compartilhado) reapareça na sessão seguinte.
- **Decision: fila de submissão persistida no mesmo IndexedDB, com `Idempotency-Key` gerada no cliente e enviada em cabeçalho.** O backend registra a chave (tabela de idempotência por tenant, TTL de 24 h) e devolve a resposta original em reenvio. Alternativa considerada: deduplicar por conteúdo/hash — rejeitada, dois comunicados iguais legítimos são possíveis.
- **Decision: reenvio apenas em primeiro plano, disparado por `online` e por foco na aba, com feedback no banner.** Background Sync não é suportado de forma consistente (Safari) e esconderia do usuário um envio sensível (ex.: comunicado para 600 responsáveis).
- **Decision: conflito resolvido por escolha explícita do usuário.** Guardamos `baseVersion` (ETag/`rowVersion` da entidade quando existe). Se o servidor retornar 409/412, abrimos comparação "manter meu rascunho" (reenviar com a versão atual, marcando revisão) ou "descartar meu rascunho". Nunca last-write-wins silencioso.
- **Decision: anexos fora do rascunho.** Guardamos somente nome/tipo/tamanho e um aviso de que o arquivo precisa ser selecionado novamente. Guardar `File`/base64 no IndexedDB estouraria a cota e criaria cópia de dado sensível fora de política de retenção.
- **Decision: TTL de 7 dias + varredura na inicialização e no login.** Sete dias cobre uma queda na sexta e retomada na segunda; mais que isso vira acúmulo de dado pessoal no navegador. `session-autologout` encerra sessão mas **não** apaga rascunho — apagar ali destruiria justamente o trabalho que queremos salvar; o rascunho é apagado no logout manual explícito ou no sucesso do envio.

## Risks / Trade-offs

- **Risco:** IndexedDB com dado pessoal de aluno no navegador (LGPD) → mitigar com TTL curto, escopo por usuário, exclusão no logout manual, nenhum anexo e nenhuma sincronização entre dispositivos; documentar no aviso de privacidade que o rascunho fica no dispositivo.
- **Risco:** reenvio duplicar comunicado/notas → mitigar com `Idempotency-Key` + teste de reenvio concorrente; sem a chave implementada no backend, a feature fica limitada a restaurar rascunho e reenviar manualmente.
- **Risco:** rascunho "fantasma" restaurando conteúdo antigo sobre uma tela já corrigida → mitigar com `baseVersion`, aviso com data/hora e botão de descartar sempre visível.
- **Trade-off:** sem Background Sync, o envio só sai com a aba aberta; aceitável porque o usuário vê o estado ("1 envio pendente") em vez de acreditar que já foi.
- **Risco:** modo privado/navegador sem IndexedDB ou cota cheia → mitigar com detecção na inicialização, aviso único e funcionamento normal sem rascunho.

## Migration Plan

1. Criar `DraftStore` + `DraftableForm` + banner/indicador, atrás de flag (`offlineDrafts`), sem tocar em formulários ainda.
2. Instrumentar 2 telas piloto: comunicado (texto longo) e cadastro de aluno (muitos campos). Medir eventos de rascunho e falsos positivos de recuperação.
3. Adicionar `Idempotency-Key` nos endpoints de escrita dessas telas e validar reenvio.
4. Estender às demais telas cobertas (relatório, notas, diário, horários, portal) e ao diálogo de conflito.
5. Ligar por padrão; manter a flag para rollback por tenant.
6. Rollback: desligar a flag interrompe captura/reenvio; rascunhos existentes expiram pelo TTL sem afetar dados do servidor.

## Open Questions

- Quais telas entram no primeiro release além de comunicado e cadastro de aluno? (proposta: relatório, notas, diário, horários, portal)
- O backend já expõe `rowVersion`/ETag nas entidades cobertas? Se não, o conflito usa `updatedAt` como aproximação.
- Rascunho de notas deve valer por aluno ou por turma inteira (uma linha por aluno vs. lote da turma)? A decisão muda o tamanho e o escopo do rascunho.
- TTL de 7 dias é aceitável para o jurídico, ou o dado deve expirar ao fim do dia?
