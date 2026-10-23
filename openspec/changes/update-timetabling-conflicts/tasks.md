## 1. Backend
- [ ] 1.1 `GET /api/timetables/{id}/conflicts`: detecta conflitos (professor sobreposto, sala sobreposta, turma sobreposta) por grade
- [ ] 1.2 `GET /api/timetables/{id}/conflicts/{entryId}/suggestions`: slots alternativos livres que resolvem o conflito
- [ ] 1.3 `PUT /api/timetables/{id}/entries/{entryId}`: mover aula para o slot sugerido mantendo validação

## 2. Frontend
- [ ] 2.1 Badge de conflitos na visualização da grade (contador + destaque vermelho nos slots)
- [ ] 2.2 Painel de validação: lista de conflitos, cada um com sugestões de slot alternativo
- [ ] 2.3 Aplicar sugestão em 1 clique com feedback visual da grade atualizada

## 3. Testes
- [ ] 3.1 API: conflito de professor sobreposto é detectado; grade sem conflitos retorna lista vazia
- [ ] 3.2 API: sugestão devolve apenas slots realmente livres (professor + sala + turma)
- [ ] 3.3 E2E: coordenador aplica sugestão e o conflito desaparece da lista
