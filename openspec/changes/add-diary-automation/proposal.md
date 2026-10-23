## Why

Professores brasileiros perdem 11h/semana com burocracia (Nova Escola/Itaú 2023): diário 3h, planos de aula 2,5h, relatórios para coordenação 2h. Nenhum concorrente posiciona o ganho docente como produto — todos focam no financeiro. O diário digital existe em todo lugar, mas nenhum sistema faz do diário a fonte única que gera relatórios de coordenação, comentários de boletim e planos de aula BNCC automaticamente.

## What Changes

- Nova capability `diary-automation`: diário de classe como fonte única de verdade
- "Relatório semanal para coordenação" gerado em 1 clique a partir dos dados do diário (elimina a duplicação de relatórios)
- Rascunho IA de comentário de boletim por aluno citando notas/frequência reais (conecta ao padrão `ai-drafts`: revisão humana obrigatória + trilha de auditoria)
- Sugestão de plano de aula com BNCC pré-mapeada por disciplina/ano, editável

## Impact

- Affected specs: diary-automation (novo), reusa padrões de ai-drafts
- Affected code: novos endpoints de diário semanal, integração com LessonPlan/Assignments/Grades existentes, `report-builder` para exportação
