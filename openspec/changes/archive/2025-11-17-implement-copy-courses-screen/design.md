# Design — Implementar Tela para Cópia de Cursos

## Pontos chave

- Options: includeSchedules, includeAssessments, includeMaterials
- Endpoint: POST /api/courses/{id}/duplicate

## Notas

- Validar referências externas (professores, salas) que possam não existir no destino
