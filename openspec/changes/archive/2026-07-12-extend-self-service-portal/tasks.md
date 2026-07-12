# Tasks — extend-self-service-portal

## Status: ✅ COMPLETED

All backend endpoints, frontend components, quality gates, and integration tests are implemented and passing.

## 1. Pagamento de boletos

- [x] 1.1 Criar endpoint backend para gerar PIX/checkout via gateway de pagamento existente (owner: backend).
- [x] 1.2 Criar endpoint para consultar status de pagamento em tempo real (owner: backend).
- [x] 1.3 Criar componente frontend de pagamento com QR code PIX e opção cartão (owner: frontend).
- [x] 1.4 Atualizar componente financeiro para exibir botão de pagamento por boleto (owner: frontend).
- [x] 1.5 Adicionar testes para fluxo de pagamento e status (owner: qa).

## 2. Download de documentos

- [x] 2.1 Criar endpoint backend para gerar/recuperar PDF de boletim, certificado e declaração (owner: backend).
- [x] 2.2 Criar componente frontend de listagem de documentos disponíveis para download (owner: frontend).
- [x] 2.3 Integrar download de documentos na seção acadêmica do portal (owner: frontend).
- [x] 2.4 Adicionar testes para geração e download de PDF (owner: qa).

## 3. Horário do aluno

- [x] 3.1 Criar endpoint backend para retornar timetable do student CPF via AcademicContext (owner: backend).
- [x] 3.2 Criar componente frontend de grade semanal com highlights do dia atual (owner: frontend).
- [x] 3.3 Integrar horário na seção acadêmica do portal (owner: frontend).
- [x] 3.4 Adicionar testes para consulta de timetable (owner: qa).

## 4. Comunicação com escola

- [x] 4.1 Criar modelo de dados para mensagens: sender, recipient, content, readAt, createdAt (owner: backend).
- [x] 4.2 Criar endpoints backend para listar conversas, enviar mensagem e marcar como lida (owner: backend).
- [x] 4.3 Criar componente frontend de chat/mensagens com histórico e envio (owner: frontend).
- [x] 4.4 Adicionar rota de mensagens no portal routes (owner: frontend).
- [x] 4.5 Adicionar testes para envio e leitura de mensagens (owner: qa).

## 5. Notificações do aluno

- [x] 5.1 Criar endpoint backend para listar notificações por student CPF com status read/unread (owner: backend).
- [x] 5.2 Criar endpoint para marcar notificação como lida (owner: backend).
- [x] 5.3 Criar componente frontend de inbox de notificações com contadores (owner: frontend).
- [x] 5.4 Integrar notificações no dashboard do portal (owner: frontend).
- [x] 5.5 Adicionar testes para notificações (owner: qa).

## 6. Quality Gates

- [x] 6.1 Validar build frontend.
- [x] 6.2 Validar testes frontend (548/548 passaram).
- [x] 6.3 Validar openspec validate extend-self-service-portal --strict.
