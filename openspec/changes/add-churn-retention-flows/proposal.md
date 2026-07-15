## Why

O churn é decidido em dois momentos que hoje o produto ignora: o **cancelamento** e a **inatividade silenciosa**. A tela de assinatura (`subscriptions.component`) é um stub estático e o cancelamento se resume a um `confirm("Tem certeza que deseja cancelar a assinatura?")` (ver `i18n-data.ts` `CANCEL_CONFIRM`). Isso desperdiça a última conversa com o cliente e trata retenção como formulário burocrático.

Baseado nos princípios de Revenue-Centric Design (Richard @richardrx), churn & retention:
- **"Design the cancel screen — it's your last conversation, not a form"**: mostrar perda concreta (loss aversion), oferecer alternativa (pausar) antes do adeus, e coletar o motivo real com pergunta aberta.
- **"Churn and payback are one problem"**: intervir cedo — detectar contas em risco por inatividade antes do cancelamento, não no cancel screen.
- **"Tell the existing base about upgrades before they want to leave"**: NRR acima de 110% depende de comunicar valor proativamente à base ativa.
- **"Anchor one-time-job products to a recurring life event"**: escola tem eventos recorrentes (início de bimestre, matrícula, fechamento de notas) que devem trazer o usuário de volta.
- **"Expansion is born of usage"**: upsell no momento do limite (ex.: atingiu o teto de alunos do plano), nunca por interrupção.

## What Changes

- **ADDED** capability `subscription-retention` com fluxo de cancelamento desenhado (win-back), detecção de risco de churn e triggers de re-engajamento.
- **ADDED** Cancel screen com três jogadas RCD: perda concreta ("Você perderá acesso a X alunos, Y turmas e Z meses de histórico"), alternativa antes do adeus ("Pausar 30 dias" / "1 mês grátis"), e coleta de motivo via pergunta aberta.
- **ADDED** Health score / risco de churn por conta baseado em sinais de uso (logins, ações-chave nos últimos 14/30 dias) exposto no dashboard do owner.
- **ADDED** Expansion prompt contextual no momento do limite do plano (ex.: 90% do teto de alunos) em vez de interrupção — "Expansion is born of usage".
- **ADDED** Re-engagement anchor: notificações vinculadas a eventos recorrentes do calendário escolar (início de bimestre, período de matrícula, fechamento de notas).
- **MODIFIED** self-service-portal: reduzir jargão e adicionar FAQ contextual in-product para cortar carga de suporte (support como problema de design, não de staffing).

## Impact

- Affected specs: `subscription-retention` (nova), `self-service-portal` (MODIFIED)
- Affected code: `school-management-ui` — `features/subscriptions/ui/subscriptions.component`, novo `cancel-flow` component, `services/subscription.service.ts`, dashboard do owner (health score widget), `notifications`/`communications` (re-engagement triggers)
- Affected code: `school-management-api` — endpoints de cancelamento/pausa de assinatura, cálculo de health score, motivos de cancelamento persistidos
- Métricas novas: NRR (alvo > 110%), taxa de save no cancel screen, % contas em risco reativadas
