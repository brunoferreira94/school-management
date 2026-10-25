# Tasks — Notificações por eventos pedagógicos

## 1. Backend
- [x] 1.1 Gatilhos pedagógicos: `AttendanceAbsenceThreshold` (limiar configurável, default 3 — dispara exatamente no cruzamento, uma vez), `GradeBelowAverage` (abaixo de 50% da nota máxima, configurável), `ReportCardPublished` — **entidade "ocorrência" não existe no domínio; quando existir, entra no mesmo publisher**
- [x] 1.2 Publicação nos pontos de escrita: `RecordAttendanceHandler` (frequência) e `UpsertGradeHandler` (nota) chamam o publisher após sucesso, sem quebrar o lançamento (try/catch)
- [x] 1.3 Anti-ruído: limite diário por destinatário (`Notifications:MaxPerRecipientPerDay`, default 5) + eventos excedentes entram em digest único do dia ("Resumo diário — N eventos"), sem repetição de itens
- [x] 1.4 Status de leitura por notificação: `DeliveryStatus` (sent/delivered/read/failed) via webhook WhatsApp; canal preferido respeita opt-in
- [x] 1.5 Publisher resolve os contatos do responsável principal (StudentGuardian→Guardian) e injeta no payload da regra

## 2. Frontend
- [x] 2.1 Catálogo de eventos pedagógicos no seletor de eventos (Falta Recorrente, Nota Abaixo da Média, Boletim Publicado)
- [x] 2.2 Preview do digest para o responsável (2026-10-25): no portal, notificações "Resumo diário" ganham preview dedicado — "Ver resumo do dia (N eventos)" expande os itens consolidados em lista legível (antes o corpo multi-linha colapsava); rota /portal/notifications antes inacessível (input required nunca bindado + sem link) agora resolve o CPF pelo perfil e está no nav do dashboard; E2E `portal-digest-preview.cy.ts` (navegação client-side completa pelo dashboard depende da sessão Auth0 real — comportamento de produção)

## 3. Testes
- [x] 3.1 3 faltas cruzam o limiar e disparam UMA notificação (não uma por falta; 4ª falta não redispara; presença não dispara; contatos do responsável no payload) — 4 testes
- [x] 3.2 Excedendo o limite diário, o evento vira digest único com os eventos do dia, sem duplicatas — 3 testes
- [x] 3.3 Nota abaixo da média dispara com contexto (título, score); acima da média não dispara — 2 testes
- [x] 3.4 E2E `notifications-pedagogical.cy.ts` (2026-10-25, cypress): o evento pedagógico (Falta Recorrente — publisher coberto pelos testes xUnit 3.1–3.3) chega ao responsável no sininho do layout; abrir + clicar registra a leitura (PATCH confirmado) e o badge zera; "Marcar todas como lidas" dispara o mark-all-read. **Fixes reais incluídos**: o `notification-bell` era um componente órfão (nunca montado — agora está no topbar) e tinha CD morto em async (badge/estado não renderizavam sem outra interação)
