## 1. Setup
- [x] 1.1 Instalar skill impeccable em `.opencode/skills/impeccable` (provider opencode)
- [x] 1.2 Carregar contexto (`impeccable context`) e playbook `audit`

## 2. Verificação "nada quebrado"
- [x] 2.1 Build de produção do frontend sem erros (`ng build`)
- [x] 2.2 Suíte completa karma verde (717/717)
- [x] 2.3 Varredura de referências órfãs: template ↔ selector, rotas que apontam para componentes inexistentes, assets 404 (poster/vídeo do onboarding verificados)

## 3. Detector determinístico (Impeccable engine)
- [x] 3.1 `impeccable detect --json` sobre `school-management-ui/src` completo
- [x] 3.2 Triagem de falsos positivos (ex.: heurística de fonte interpretando `Material Icons`/`system` como overused-font)
- [x] 3.3 Findings verificados em contexto (arquivo+linha), separados por regra

## 4. Auditoria de código por dimensão (amostragem guiada pelo detector)
- [x] 4.1 A11y: contraste, aria-labels em botões só-ícone, foco/teclado, heading hierarchy, forms
- [x] 4.2 Theming: cores hard-coded vs `--color-*` tokens (dark mode não é requisito atual — registrar como decisão)
- [x] 4.3 Responsive: larguras fixas, touch targets < 44px, overflow horizontal
- [x] 4.4 Performance: animações de propriedade de layout, will-change, imagens sem lazy
- [x] 4.5 Drift do design system: padrões divergentes entre features novas e legado

## 5. Relatório
- [x] 5.1 Score por dimensão (0-4) + total /20 + band
- [x] 5.2 Findings por severidade P0-P3 com local, impacto e comando impeccable sugerido
- [x] 5.3 Achados positivos + padrões sistêmicos
- [x] 5.4 Backlog de correção priorizado (a correção vira trabalho próprio; não edita código nesta change)

## Verificação
- [x] Suíte karma continua verde ao fim (nada alterado em código)
- [x] Saída do detector `--json` arquivada em `report/` desta change
