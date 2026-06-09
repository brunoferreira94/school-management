# Design — Estratégia de Monetização

## Opções consideradas

- SaaS mensal/annual por escola
- Freemium com módulos premium (financeiro, analytics)
- Pay-per-use para integrações de pagamento

## Recomendação atualizada

O repositório já define a API de assinaturas com os planos `Free`, `Premium` e `Enterprise` em `school-management-api/docs/api/subscriptions.md`.

### Planos canônicos

| Plano      |                  Público-alvo | Limite de alunos | Preço mensal | Preço anual | Features principais                                                                                                 |
| ---------- | ----------------------------: | ---------------: | -----------: | ----------: | ------------------------------------------------------------------------------------------------------------------- |
| Free       |              Escolas pequenas |    Até 50 alunos |         R$ 0 |        R$ 0 | Onboarding básico, gestão de alunos, turmas, avaliações, frequência, 1 unidade, 100 MB, portal admin básico         |
| Premium    | Escolas médias em crescimento |   Até 500 alunos |    R$ 299,90 | R$ 2.999,00 | Portal do responsável, notificações avançadas, dashboards operacionais, módulo financeiro, API, suporte prioritário |
| Enterprise |     Grandes redes / contratos |        Ilimitado |    R$ 999,90 | R$ 9.999,00 | Tudo do Premium + ilimitado, SLA, onboarding dedicado, integrações personalizadas, custom branding                  |

## Observações de mercado

- A pesquisa de mercado indica que o preço de entrada para um plano completo competitivo no Brasil está entre R$ 250–350/mês para até 500 alunos, alinhando-se com o `Premium` do backend.
- Um plano gratuito de entrada é importante para reduzir atrito de adoção e permitir demonstração do portal.
- O plano `Enterprise` deve ser posicionado como contrato negociado, com limite `-1` (ilimitado) no backend e faturamento customizado.

## Funcionalidades obrigatórias por plano

- **Free**: habilitar prova de conceito rápida; foco em configuração inicial e uso administrativo básico.
- **Premium**: incluir Portal do Responsável, notificações, financeiro e analytics básicos como elementos de valor principais.
- **Enterprise**: oferecer SLA, onboarding dedicado e integrações corporativas como justificativa para preço maior.

## Estratégia de lançamento

- Use `Free` para capturar escolas pequenas e gerar tráfego inicial.
- Use `Premium` como oferta principal de venda para escolas médias.
- Use `Enterprise` para redes e contratos com negociação direta.

## Add-ons e roadmap

- No MVP inicial, não fragmentar o produto com muitos add-ons. Mantenha analytics e financeiro no `Premium`.
- Após estabilizar billing, introduza add-ons para conciliação financeira, integração gateway local e suporte SLA avançado.

## Próximo passo

- Ajustar o pricing page público e o catálogo de planos para refletir `Free`, `Premium` e `Enterprise` como o modelo canônico.
- Priorizar a entrega do Portal do Responsável no plano `Premium` para justificar o preço de R$ 299,90/mês.
