# Tasks — Notificações por eventos pedagógicos

## 1. Backend
- [x] 1.1 Gatilhos pedagógicos: `AttendanceAbsenceThreshold` (limiar configurável, default 3 — dispara exatamente no cruzamento, uma vez), `GradeBelowAverage` (abaixo de 50% da nota máxima, configurável), `ReportCardPublished` — **entidade "ocorrência" não existe no domínio; quando existir, entra no mesmo publisher**
- [x] 1.2 Publicação nos pontos de escrita: `RecordAttendanceHandler` (frequência) e `UpsertGradeHandler` (nota) chamam o publisher após sucesso, sem quebrar o lançamento (try/catch)
- [x] 1.3 Anti-ruído: limite diário por destinatário (`Notifications:MaxPerRecipientPerDay`, default 5) + eventos excedentes entram em digest único do dia ("Resumo diário — N eventos"), sem repetição de itens
- [x] 1.4 Status de leitura por notificação: `DeliveryStatus` (sent/delivered/read/failed) via webhook WhatsApp; canal preferido respeita opt-in
- [x] 1.5 Publisher resolve os contatos do responsável principal (StudentGuardian→Guardian) e injeta no payload da regra

## 2. Frontend
- [x] 2.1 Catálogo de eventos pedagógicos no seletor de eventos (Falta Recorrente, Nota Abaixo da Média, Boletim Publicado)
- [ ] 2.2 Preview do digest para o responsável — **o digest já é gerado e entregue como notificação; preview dedicado na UI pendente**

## 3. Testes
- [x] 3.1 3 faltas cruzam o limiar e disparam UMA notificação (não uma por falta; 4ª falta não redispara; presença não dispara; contatos do responsável no payload) — 4 testes
- [x] 3.2 Excedendo o limite diário, o evento vira digest único com os eventos do dia, sem duplicatas — 3 testes
- [x] 3.3 Nota abaixo da média dispara com contexto (título, score); acima da média não dispara — 2 testes
- [ ] 3.4 E2E: professor registra ocorrência e o responsável recebe notificação com leitura registrada
