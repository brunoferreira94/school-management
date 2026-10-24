## Why

O pipeline 2026-differentiators (9 changes) adicionou muita UI nova ( portal, diary, censo, timetabling, narrativa IA, autoatendimento, templates por segmento, busca global, relatórios) em poucas semanas de sessões paralelas, sempre guiada pelos mesmos padrões locais. Ninguém fez uma revisão transversal de qualidade de UI desde o início do funil. Riscos concretos: drift vis desig do design system (cores/tokens hard-coded), acessibilidade (WCAG AA) rompida por código novo, regressões visuais silenciosas (nada quebrado), e desalinhamento com a identidade existente do produto.

## What Changes

- Auditoria técnica completa da UI (Angular) com a skill **Impeccable** (5 dimensões: a11y, performance, theming, responsive, implementation integrity)
- Detector determinístico (62 regras anti-slop + quality) rodado sobre todo `school-management-ui/src`
- Verificação de "nada quebrado": build de produção, suíte karma 717 testes, rotas/componentes órfãos referenciando coisas inexistentes
- Relatório com findings por severidade (P0-P3), score 0-20, e plano de correção priorizado (mapeado para comandos impeccable)

## Impact

- Affected specs: nenhum spec funcional muda (change de auditoria; correções virarão changes próprias, se necessário)
- Affected code: somente leitura — a auditoria não edita código; correções ficam no backlog do relatório
