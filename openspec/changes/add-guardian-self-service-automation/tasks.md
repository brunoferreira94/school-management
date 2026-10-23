## 1. Backend
- [ ] 1.1 `POST /api/portal/requests`: registra solicitação do responsável (tipo: segunda-via, declaracao-matricula, comprovante-quitacao, vencimento)
- [ ] 1.2 `GuardianRequestResolver`: resolve automaticamente com dados reais (gera 2ª via via gateway, declaração via report-builder, status da fatura)
- [ ] 1.3 `GET /api/portal/requests` (secretaria): lista apenas solicitações não resolvidas automaticamente + métricas de volume auto-resolvido
- [ ] 1.4 Rate limiting e histórico por responsável (trilha auditável)

## 2. Frontend (portal do responsável)
- [ ] 2.1 Ações de autoatendimento na home do portal: "2ª via", "Declaração de matrícula", "Comprovante de quitação"
- [ ] 2.2 Resposta instantânea com o documento real (download PDF) ou status da fatura — sem ticket
- [ ] 2.3 Fallback: solicitação vira ticket humano quando não resolvível, com posição na fila

## 3. Frontend (secretaria)
- [ ] 3.1 Painel "Solicitações": só exceções, com % resolvido automaticamente no período
- [ ] 3.2 Resolver manualmente com resposta registrada

## 4. Testes
- [ ] 4.1 API: 2ª via resolvida automaticamente com a fatura correta do aluno
- [ ] 4.2 API: solicitação não resolúvel aparece na fila da secretaria
- [ ] 4.3 E2E: responsável pede declaração e recebe PDF sem interação da secretaria
