# Tasks — Autoatendimento do responsável

## 1. Backend
- [x] 1.1 `POST /api/portal/requests` (`GuardianRequestController`, escopo `PortalUser` + rate limit por guardian `PortalRequests` 10/min): tipos `segunda-via`, `declaracao-matricula`, `comprovante-quitacao`, `vencimento`, `outros`
- [x] 1.2 `GuardianSelfServiceResolver`: resolve com dados reais — 2ª via gera boleto PDF da parcela em aberto (valor/vencimento/linha digitável), declaração reusa school unit/turma/ano letivo ativo do cadastro (via renderer próprio + `IPdfGenerationService`), comprovante lista parcelas quitadas, vencimento responde texto com o próximo prazo; não resolvível → ticket humano com posição na fila
- [x] 1.3 `GET /api/portal/requests` (secretaria, `students.read`): apenas tickets Open + métricas (auto-resolvidas, total, % no período 30d); `POST {id}/resolve` (`students.write`) registra resposta com auditoria de quem resolveu
- [x] 1.4 Rate limiting por guardian + histórico `GET mine` (trilha: `HandledBy`, `HandledResponse`, `ResolvedAtUtc`; migration `AddGuardianRequests`)

## 2. Frontend (portal do responsável)
- [x] 2.1 Ações de autoatendimento na home do dashboard: "2ª via de fatura", "Declaração de matrícula", "Comprovante de quitação", "Consultar vencimento"
- [x] 2.2 Resposta instantânea com o documento real (download PDF do documento gerado com dados do cadastro) ou status/mensagem textual do financeiro — sem ticket
- [x] 2.3 Fallback: solicitação não resolvível vira ticket humano com posição na fila visível ao responsável (feedback inline + toast) e histórico "Minhas solicitações"

## 3. Frontend (secretaria)
- [x] 3.1 Painel `/solicitacoes`: apenas exceções (tickets em aberto) + card "% resolvido automaticamente no período" (auto-resolvidas / total, 30 dias)
- [x] 3.2 Resolver manualmente com resposta registrada (painel inline por ticket; toast + reload)

## 4. Testes
- [x] 4.1 API: 2ª via resolvida automaticamente com a fatura correta do aluno (valor/vencimento/status no PDF e na resposta) — 12 testes de resolver + fila + métricas
- [x] 4.2 API: solicit. não resolúvel (sem turma, sem quitação, aluno não vinculado, tipo livre) vira ticket e a fila da secretaria vê só os open, com isolamento por tenant
- [x] 4.3 E2E `guardian-self-service.cy.ts` (2026-10-25, mock-based): responsável pede declaração de matrícula → resolvido na hora (Auto) com PDF baixável; pedido não resolvível → ticket com posição na fila e sem PDF. **Fix real incluído**: `portalGuard` e `portal-dashboard` não respeitavam `devAuth` (só Auth0 SDK) — o portal nunca carregava em dev/e2e
