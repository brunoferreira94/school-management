# Checklist B2B — Conformidade LGPD e Contratos

## 6.1 Contrato Principal (Master Agreement)

- [ ] Modelo de contrato com cláusulas de prestação de serviços
- [ ] Definição de SLAs (disponibilidade 99.5%, uptime, suporte)
- [ ] Escopo de dados cobertos pelo contrato
- [ ] Valores e condições de pagamento
- [ ] Duração e renovação automática
- [ ] Rescisão e migração de dados na saída

## 6.2 Data Processing Agreement (DPA / Aditivo LGPD)

- [ ] Finalidade do tratamento de dados (gestão escolar)
- [ ] Base legal (Art. 7º, II e IX — obrigação legal + legítimo interesse)
- [ ] Tipos de dados pessoais tratados
- [ ] Categorias de titulares (alunos, responsáveis, professores, staff)
- [ ] Compartilhamento com subprocessadores (Stripe/Asaas)
- [ ] Prazo de retenção e anonimização (12 meses após rescisão)
- [ ] Medidas de segurança (criptografia, backup, acesso restrito)
- [ ] Notificação de incidentes de segurança (48h)
- [ ] Direitos dos titulares (acesso, correção, eliminação, portabilidade)
- [ ] Responsabilidades do controlador vs. o controlado

## 6.3 Validação de Conformidade

- [ ] Checklist assinado pelo cliente (escola) antes do onboarding
- [ ] Upload/attach do contrato no sistema (campo `ContractDocumentId` em Tenant)
- [ ] Upload/attach do DPA no sistema (campo `DpaDocumentId` em Tenant)
- [ ] Status `ContractSignedAt` e `DpaSignedAt` atualizados
- [ ] Bloqueio de operações sensíveis até assinatura concluída

## 6.4 Integração ao Sistema

### Backend
- `Tenant` deve ter campos:
  - `ContractDocumentId` (Guid nullable)
  - `ContractSignedAt` (DateTime nullable)
  - `DpaDocumentId` (Guid nullable)
  - `DpaSignedAt` (DateTime nullable)
- Endpoint `/api/tenants/{id}/legal-documents` para upload/verificação
- Middleware de compliance verifica documentos antes de operação ativa

### Frontend
- Componente `legal-documents` mostrando status de contrato/DPA
- Indicador visual "Conformidade LGPD: ✅ Completa" / "⏳ Pendente"
- Bloqueio de funcionalidades administrativas se docs pendentes