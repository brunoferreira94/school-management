## 1. Backend
- [ ] 1.1 Provedor WhatsApp Business API na abstração de canais de `CommunicationService` (igual ao padrão de e-mail/SMS existente)
- [ ] 1.2 Templates WhatsApp com variáveis (nome do aluno, valor, vencimento, link 2ª via PIX)
- [ ] 1.3 Registro de entrega/leitura do WhatsApp no delivery tracking existente
- [ ] 1.4 Consentimento de contato por responsável (opt-in por canal) + fallback para e-mail quando sem consentimento

## 2. Integrações
- [ ] 2.1 billing-cadence dispara lembretes via WhatsApp (canal preferido quando opt-in)
- [ ] 2.2 Ocorrências pedagógicas (falta recorrente) notificam via WhatsApp com registro de leitura

## 3. Frontend
- [ ] 3.1 Seletor de canal no envio segmentado existente (e-mail / SMS / WhatsApp)
- [ ] 3.2 Status de entrega por WhatsApp no histórico de comunicação
- [ ] 3.3 Opt-in de WhatsApp visível no cadastro do responsável (portal)

## 4. Testes
- [ ] 4.1 Unitário: provider WhatsApp respeita a mesma interface dos canais existentes
- [ ] 4.2 API: envio sem opt-in cai para fallback e registra motivo
- [ ] 4.3 E2E: coordenação envio comunicado WhatsApp segmentado por turma com rastreio
