# Design — Nudges de upgrade de plano

Data: 2026-11-27
Status: draft (copy e escopo aguardam aprovação do dono)

## 1. Princípio

Mostrar o **valor antes do bloqueio**. O nudge é visual e informativo: ele explica o que o plano
Premium entrega e usa **dados reais do tenant** para ancorar a decisão. Não há bloqueio de API
nem alteração de enforcement neste change.

## 2. Gatilhos aprovados para uso

| Gatilho | Como usar sem cair em dark pattern |
|---|---|
| **Progresso / efeito dotado** | "Você já tem **{alunos} alunos e {turmas} turmas** cadastrados. Tudo preservado." — usa `GET /subscriptions/usage` (dado real). |
| **Ancoragem** | "Free: até 50 alunos · Premium a partir de R$ 149 inclui 150 alunos e 1 unidade." — preço do catálogo, nunca inventado. |
| **Aversão à perda (segura)** | "Seus dados continuam salvos; o que muda é só o acesso à edição." — informa, não ameaça. |
| **Curiosidade + preview** | Mock desfocado da tela real + "Veja o que o Analytics avançado reúne em um só lugar." |
| **Concretude** | Badge textual "Premium" no menu, não só ícone de cadeado. |
| **Prazo real** | Somente se houver data verdadeira (ex.: fim do preço-piloto). Nunca contador genérico. |

**Proibido**: contador falso, "últimas vagas", "ofertas só hoje", "500 escolas confiam" sem dado,
culpa ("você está perdendo dinheiro"), esconder preço/cancelamento, nagging a cada clique.

## 3. Mapa: o quê e onde

### 3.1 Recursos do soft gate (4, conforme `FeatureGatingMiddleware`)

| Recurso | Rota/feature | Título do benefício | 3 bullets de valor (proposta) |
|---|---|---|---|
| Financeiro e cobranças | `financial_module` | "Mensalidades sem planilha" | Boletos/PIX integrados · conciliação automática · inadimplência visível |
| Portal do responsável | `guardian_portal` | "A família conectada à escola" | Boletos e notas online · avisos instantâneos · onboarding em minutos |
| Analytics avançado | `advanced_analytics` | "Decisões com dados, não com achismo" | Evasão por turma · desempenho por disciplina · tendências no tempo |
| API pública | `api_access` | "Integre sua escola a outros sistemas" | Endpoints documentados · autenticação por chave · sincronização offline |

> Os textos acima são proposta. O dono deve aprovar ou ajustar antes da implementação.

### 3.2 Pontos de contato

| # | Superfície | Estado visual | Comportamento |
|---|---|---|---|
| 1 | **Menu lateral** (`SidebarComponent`) | item atenuado + cadeado + badge "Premium" | clique abre modal de upgrade, sem navegar; rota direta continua funcionando (soft gate) |
| 2 | **Tela do recurso** | preview desfocada + título de benefício + 3 bullets + CTA | "Desbloquear com Premium" → `/checkout/:plan`; secundário "Falar com vendas" |
| 3 | **Modal de upgrade** (já existente) | copy específico por feature + linha de ancoragem com dados reais | reaproveita `SubscriptionUpgradeDialogComponent` (motivo `feature_not_in_plan`) |
| 4 | **Trial vencido (402)** | modal existente "Seu teste grátis terminou" | acrescentar linha de progresso real ("você já tem X alunos…") |
| 5 | **`/pricing`** (já entregue) | cards + simulador | sem mudança; é o destino do link "ver planos" |

### 3.3 Estados do modal

| Estado | Gatilho | Título | Corpo |
|---|---|---|---|
| `feature_not_in_plan` | clique em item travado | "Recurso indisponível no seu plano" | benefício + bullets + "Sua escola já tem {alunos} alunos cadastrados. Premium a partir de R$ 149/mês." |
| `trial_expired` | 402 da API | "Seu teste grátis terminou" | "Dados preservados. Para voltar a editar, escolha um plano — migração gratuita." + progresso real |
| (genérico) | 403/402 sem reason conhecido | "Sua assinatura expirou" | texto atual |

## 4. Regra de frequência

- Disparar **1 vez por feature** no primeiro clique/abertura.
- Após dismiss, guardar `sma_upgrade_nudge_<feature>` no `localStorage` com expiração de **7 dias**.
- Não reabrir automaticamente ao navegar; apenas em novo clique do usuário.
- Não disparar no login, na landing pública nem em `/pricing`.

## 5. Telemetria (nomes sugeridos)

| Evento | Quando | Props |
|---|---|---|
| `nudge_shown` | modal/preview exibido | `feature`, `plan`, `source` (menu/tela/402) |
| `nudge_dismissed` | usuário fecha | `feature`, `seconds_open` |
| `upgrade_clicked` | CTA "Desbloquear" | `feature`, `plan` |
| `checkout_started` | navegação para `/checkout` | `plan`, `cycle` |

Destino: backend de métricas existente (`IMetricsService`) ou, se inviável no front, evento no
console + contador no painel de analytics — **decisão aberta** (task 0.2).

## 6. Decisões abertas

1. Aprovar os 4 títulos/benefícios da tabela §3.1.
2. Onde registrar a telemetria (backend vs. analytics de frontend).
3. Incluir o prazo do preço-piloto no rodapé do modal? (só se a data for real)
4. Incluir contagem de alunos/turmas no modal — confirmação de que usar `GET /subscriptions/usage` é aceitável.

## 7. Sequência de implementação resumida

1. Copy + i18n (aprovado) → 2. leitura de features do plano no front → 3. menu com soft gate →
4. tela de preview travada → 5. modal específico + dados reais → 6. cooldown → 7. telemetria →
8. testes Karma/Cypress → 9. validação de bundle.

Detalhes em `tasks.md`. Nenhuma etapa altera enforcement ou cobrança.
