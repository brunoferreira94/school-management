## Why

O self-service portal já oferece autenticação, dados financeiros, acadêmicos e perfil. Mas faltam funcionalidades que reduzem chamados ao suporte: pagamento direto de boletos, download de documentos oficiais, visualização de horários, comunicação com a escola e notificações por aluno.

## What Changes

- **Pagamento de boletos**: integrar checkout/PIX via gateway de pagamento para pagamento direto no portal com status em tempo real.
- **Download de documentos**: permitir download de boletins, certificados e declarações em PDF gerados pelo backend.
- **Horário do aluno**: exibir grade de horários/timetable do aluno com aulas do dia e semana.
- **Comunicação com escola**: canal de mensagens entre responsável/aluno e coordenação da escola.
- **Notificações do aluno**: caixa de entrada de notificações por student CPF com leitura/não lida.

## Impact

- Specs afetadas: `self-service-portal` (MODIFIED)
- Código afetado: portal frontend (novos componentes), backend (novos endpoints), gateway de pagamento (integração existente)
- Dependências: gateway de pagamento já configurado (Asaas/mock), timetable dados no AcademicContext

## Fora de escopo

- Videochamadas ou suporte ao vivo
- Integração com apps mobile nativos
- Marketplace de serviços adicionais
