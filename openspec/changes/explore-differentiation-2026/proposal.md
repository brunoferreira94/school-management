# Diferenciação 2026 — pesquisa de melhorias vs concorrentes

Autor: assistente (pesquisa web via agent-reach/Exa — ReclameAQUI, blogs de concorrentes, guias de buyer 2026)
Data: 2026-10-22
Status: draft (proposta para decisão do founder)

## Contexto do produto

ESCOLA+ é SaaS B2B de gestão escolar para escolas privadas BR com portal do responsável,
módulo financeiro, assinaturas (Asaas+Stripe), churn/RCD (health score, cancel-flow honesto,
expansion prompt), relatório técnico-BNCC e base openspec. Spec existente `product-differentiation`
já cobre micro-loops, "tela de hoje", design language e erros humanos.

## Dores do mercado encontradas (evidências)

1. **Suporte pós-aquisição degradado** (Sponte/Linx): erros básicos levam semanas p/ corrigir;
   "o financeiro está sumindo"; impossível cancelar contrato sem resposta; multa unilateral no
   atraso do cliente enquanto bugs ficam abertos (ReclameAQUI 2026, recomendações negativas).
2. **Conciliação recusada**: cliente pediu inclusão de bancos na conciliação e "se recusaram" (Sponte).
3. **Inadimplência**: régua de cobrança automática (lembrete D-3, aviso no vencimento, notificação
   D+2..5) + PIX automático/boleto registrado/cartão recorrente + link direto de pagamento é o
   pitch padrão de TOTVS/Didatiko/Educbank/Proesc; meta TOTVS "<5%".
4. **WhatsApp centralizado multiusuário**: F10 vende integração dedicada (histórico por setor,
   rastreabilidade, sem depender do celular de ninguém) — demanda explícita de escolas.
5. **AI com revisão humana** (guias de buyer 2026, EDU ERP checklist): resumo de leads/attendances,
   rascunho de plano de aula e de comunicação, sumário narrativo para o gestor — o critério de
   compra é "quem revisa/aprova o rascunho" e "dá pra verificar a fonte".

## 5 diferenciais propostos (priorizados)

| # | Diferencial | Por que ganhamos | Pronto no produto hoje (alavanca) | Esforço |
|---|---|---|---|---|
| 1 | **Régua de cobrança automática** (D-3 pix, vencimento, D+2; link de pagamento nos canais) | Ataca a dor #1 de pegada financeira da escola; ROI mensurável (inadimplência ↓) | módulo financeiro + notificações + Asaas pix/boleto/carnê + AccountSummary | M |
| 2 | **WhatsApp da escola com deep links** (mensagens prontas por evento, entrega na régua e nos avisos) | Comunicação escola-família é a expectativa padrão BR; F10 cobra caro por isso | communications + notifications; `wa.me/<ddd><fone>?text=<msg>` não precisa de API paga | M |
| 3 | **Rascunhos com revisão obrigatória** (AI-assisted, audit trail): mensagem p/ responsáveis em risco, comentário de boletim, resumo narrativo semanal do diretor na "tela de hoje" | Alinha com o buying checklist 2026 (draft+review+fonte); BNCC + report-builder já existem | ChurnHealth/inadimplência dão o "quem", report-builder/BNCC dão o "o quê" | M/LLM |
| 4 | **Transparência radical de confiabilidade**: changelog de correções com MTTR no painel, status de integridade público e cancelamento self-service de 1 clique | Sponte/Linx perdoam bug mas não mentira; confiança = churn ↓ (RCD já implementada) | health checks, audit log, cancel-flow honesto com reasonTag | S/M |
| 5 | **Portabilidade de dados LGPD 1-clique** no cancelamento (export completo em CSV/JSON) | Contra "não consigo cancelar nem levar meus dados"; gera recomendação boca a boca | cancel-flow finaliza a assinatura; export precisa ser construído | S |

## Recomendação

Combinar **#1 + #2** no mesmo release (mesmo gatilho: evento financeiro) — é o diferencial que a
competição não consegue copiar rápido (nós temos gateway próprio + notificações + conciliação).
**#3** como wave seguinte (depende de provedor LLM e política de dados). **#4** pode entrar
incrementalmente (changelog já é doc; exposição no painel é pequena). **#5** é quick-win de
confiança e já conversa com o cancel-flow existente.

## Fontes

- ReclameAQUI Sponte/Linx (suporte, conciliação, cancelamento, multas) — 2026
- TOTVS Universo 2026 ("cobrança inteligente <5%"), Didatiko, Educbank, Proesc, Lumied (réguas/pix)
- F10 (WhatsApp multiusuário), Toth/Galileu (comunicação escola-família)
- EDU ERP AI buyer checklist 2026/10, clast.io features 2026/06, ParentSquare buyer's guide 2026
