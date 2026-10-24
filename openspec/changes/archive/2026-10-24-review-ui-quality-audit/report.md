# UI Quality Audit — Relatório Final (Impeccable)

**Data:** 2026-10-24 · **Escopo:** `school-management-ui/src` completo · **Skill:** impeccable v0.1.16 (engine detect 62 regras) · **Modo:** audit (código, sem edição)

## Audit Health Score

| # | Dimensão | Score | Key Finding |
|---|-----------|-------|-------------|
| 1 | Accessibility | 2/4 | `prefers-reduced-motion` quase ausente (2 usos no app todo); aria-label parcial; `:focus-visible` global ausente (0, só `:focus` 9) |
| 2 | Performance | 3/4 | Build prod otimizado (lazy chunks), zero `will-change`; 6 `<img>` sem `loading="lazy"` |
| 3 | Theming | 2/4 | Tokens M3 reais e tinted (bom!), porém **330 hex hard-coded** em `features/**` (drift) |
| 4 | Responsive Design | 3/4 | Tailwind + Material, sem fixed-width críticos detectados; touch targets não auditados em runtime |
| 5 | Implementation Integrity | 3/4 | Detector: 0 errors / 18 warnings; nenhum template órfão; 121 components lazy standalone não referenciados por selector (normal em rotas lazy) |
| **Total** | | **13/20** | **Acceptable (10-13) — trabalho significado necessário, sem bloqueio de launch** |

## Detector determinístico (18 findings, verificados em contexto)

### Falsos positivos (2)
- **broken-image** `features/auth/ui/profile.component.html` — `@if (user.picture)` + `[src]="user.picture"`: binding condicional, não é src vazio. **Descartado.**
- **broken-image** `shared/empty-state/empty-state.component.html:20` — `[src]="illustration"` (@Input, emoji ou path). **Descartado.**

### Achados reais
- **side-tab (10×)** — `border-left: 3px solid` como accent bar em: `portal-dashboard.component.scss` (stat-cards ×5), `global-search.component.scss:176`, `timetable-validation-panel.component.scss:56`, `timetabling.component.scss:435`, `today-screen.component.scss:92`, `stat-card.component.scss:15`. **Classificação: P3 — padrão consistente e intencional do design system (accent bar), não drift. Registrar como decisão; trocar só se o design evoluir.**
- **bounce-easing (6×)** — `cubic-bezier(0.34, 1.56, 0.64, 1)` (overshoot/elastic) em `activation-celebration.component.scss:45,74,176,180`. **P3 — contexto é celebração de onboarding (momento de alegria), overshoot defensável; fluxo principal não usa bounce.**

## Achados da auditoria manual (por severidade)

- **[P0] Build de produção quebrado** — `TS2341: 'loadSegments' is private` (template usava método private). **CORRIGIDO neste change** (commit ui `9506df9`): `private` → `protected`; build prod ✅ + karma 717/717 ✅. Karma não pegava porque o build de teste é menos estrito que AOT de produção.
- **[P1] Motion a11y**: só 2 usos de `prefers-reduced-motion` no app. Usuários vestibulares não têm alternativa global. → `/impeccable animate` (adicionar media query global que reduz animações).
- **[P1] Theming drift**: 330 hex em features (top: advanced-finance 30, cancel-flow 28, timetable-validation-panel 19, skills-assessment 18, auth-status 16, censo 15, notification-bell 14, today-screen 13) + 35 `rgba(0,0,0,…)`. Novas features (censo, today, timetabling) são as piores — piora manutenção e impede dark mode futuro. → `/impeccable document` (gerar DESIGN.md dos tokens) + migrar por feature.
- **[P2] Contraste marginal**: `--color-text-soft` (#6b7480) sobre `--color-bg-app` (#f7f9fb) = **4.49:1** (AA exige 4.5:1). Escuro 1 tom resolve. Restante dos pares testados: 4.74–16.23:1 ✅.
- **[P2] Foco visível**: 0 `:focus-visible` em `styles.css` global (só `:focus` ×9); borda de foco inconsistente via teclado. → `/impeccable harden`.
- **[P2] Imagens sem lazy** (6): empty-state, auth-status, profile, portal-login/register/dashboard (logo/avatar). → `/impeccable optimize`.
- **[P3] aria-label parcial**: 39 usos concentrados em ~10 features; botões só-ícone em features sem nenhum. Amostra verificada não achou botão só-ícone crítico sem label nas features auditadas com aria, mas cobertura é desigual. → `/impeccable harden`.

## Achados positivos
- Design system token **real e coeso** (M3 tinted, não gray puro): `--color-*`, `--space-*`, `--radius-*`, `--font-size-*` bem usado no legado.
- Zero `will-change` (nem em excesso, nem faltando em animações caras).
- Zero erros do detector de AI-slop (sem gradientes roxos, sem side-tab borders em cards aninhados, sem glow).
- Templates ↔ selectors: **nenhuma referência órfã** (152 declarados, 31 usados, todos válidos; 121 standalone lazy via rotas).
- Suíte karma 717/717 e build de produção verde ao final.

## Ações recomendadas (backlog priorizado — trabalho futuro, não desta change)
1. **[P1] `/impeccable animate`** — media query global `prefers-reduced-motion` + revisar overshoots.
2. **[P1] `/impeccable document`** — DESIGN.md com tokens; depois migrar hex → token por feature (começando pelas 8 piores).
3. ~~**[P2] `/impeccable harden`** — `:focus-visible` global, aria-label nos icon buttons das features sem cobertura.~~ **PARCIAL 2026-10-24**: `:focus-visible` global adicionado (ui `a681ff7`); aria-labels seguem abertos.
4. ~~**[P2] `/impeccable optimize`** — `loading="lazy"` + width/height nas 6 imagens.~~ **RESOLVIDO 2026-10-24** (ui `a681ff7`): lazy nas 3 imagens externas/decorativas; logos de header ficam **eager por decisão** (são LCP/above-the-fold).
5. ~~**[P2] Ajuste de token** — escurecer `--color-text-soft` ~1 tom (ex.: #64707c) para passar 4.5:1.~~ **RESOLVIDO 2026-10-24** (ui `a681ff7`): token agora `#646d79` — 4.97:1 sobre bg-app, 5.24:1 sobre surface, 4.51:1 sobre subtle.
6. **[P3]** side-tab/bounce: registrar como decisão de design ou revisar em `/impeccable polish` futuro.

> Re-executar `/impeccable audit` após os fixes para medir a evolução do score.
