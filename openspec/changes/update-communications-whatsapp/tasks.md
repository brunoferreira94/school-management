# Tasks — WhatsApp como canal oficial

## 1. Backend
- [x] 1.1 Provedor WhatsApp na abstração de canais: `IWhatsAppProvider` + `WhatsAppNotificationChannelSender` (mesma interface de Email/Sms/Push); `FakeWhatsAppProvider` em dev, `WhatsAppCloudApiProvider` (Meta) ativa sozinha quando AccessToken/PhoneNumberId forem configurados
- [x] 1.2 Templates WhatsApp com variáveis — o engine de templates/placeholders já cobre qualquer canal; o modelo de lembrete com {{student_name}}, {{amount}}, {{due_date}} e link de 2ª via é registrado pela API de templates existente (sem seed dedicado)
- [x] 1.3 Rastreio de entrega/leitura: `Notification.ProviderMessageId` + `DeliveryStatus` (sent/delivered/read/failed) reconciliados pelo webhook `POST /api/webhooks/whatsapp`
- [x] 1.4 Consentimento por responsável: `Guardian.WhatsAppOptIn` + `GuardianChannelConsentService` — sem opt-in cai para e-mail e registra o motivo em `Notification.StatusNote`; com opt-in resolve o destinatário para o telefone
- [x] 1.5 Endpoint de opt-in: `PUT /api/guardians/{id}/whatsapp-opt-in`

## 2. Integrações
- [ ] 2.1 billing-cadence dispara lembretes via WhatsApp — **depende da implementação de `billing-cadence` (implement-2026-differentiators); o canal já está pronto para consumir**
- [x] 2.2 Falta recorrente notifica via WhatsApp com registro de status (evento pedagógico → regra com canal WhatsApp)

## 3. Frontend
- [x] 3.1 Seletor de canal inclui WhatsApp (regras de notificação + rótulos/ícones nas notificações)
- [x] 3.2 Status de entrega registrado no histórico (ProviderMessageId + DeliveryStatus via webhook) — **exibição do status de leitura por mensagem na UI fica com o mapping existente (Read/Sent/Pending)**
- [x] 3.3 Opt-in de WhatsApp visível no cadastro do responsável (checkbox no formulário, sem opt-in a caixa mostra aviso de fallback) — **edição self-service no portal do responsável pendente (usa o endpoint PUT por enquanto)**

## 4. Testes
- [x] 4.1 Unitário: sender WhatsApp respeita a interface dos canais e devolve ProviderMessageId (2 testes)
- [x] 4.2 API: envio sem opt-in cai para e-mail com motivo registrado; com opt-in envia WhatsApp para o telefone; destinatário desconhecido mantém o canal (3 testes)
- [ ] 4.3 E2E: coordenação envia comunicado WhatsApp segmentado por turma com rastreio
