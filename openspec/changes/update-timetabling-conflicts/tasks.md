# Tasks — Detecção de conflitos na grade + sugestão de slot

## 1. Backend
- [x] 1.1 `GET /api/timetables/{id}/conflicts`: detecta conflitos (professor sobreposto, sala sobreposta — case-insensitive — e turma dupla) em slots que se cruzam, escopado ao mesmo ano letivo (mesmo ano ⇒ mesmo tenant)
- [x] 1.2 `GET /api/timetables/{id}/conflicts/{entryId}/suggestions`: slots alternativos livres da malha real da escola (dias × horários já usados no ano letivo), ordenados por proximidade (mesmo dia primeiro)
- [x] 1.3 `PUT /api/timetables/{id}/entries/{entryId}`: move a aula para o slot sugerido; destino validado — nunca cria novo conflito (400 caso contrário)

## 2. Frontend
- [x] 2.1 Painel de validação na tela de horários: badge com contagem de conflitos + "Sem conflitos" quando limpo
- [x] 2.2 Lista de conflitos navegável (tipo traduzido — Professor/Sala/Turma —, slot PT-BR, descrição com a turma conflitante), cada um com sugestões de slot
- [x] 2.3 Aplicar sugestão em 1 clique: aula movida, conflitos recarregam e a grade é re-renderizada (evento entryMoved → reloadTimetable)

## 3. Testes
- [x] 3.1 API: professor sobreposto detectado; sala sobreposta detectada (case-insensitive); grade sem recurso compartilhado retorna lista vazia; conflito de outro ano letivo é ignorado (7 testes)
- [x] 3.2 API: sugestões devolvem apenas slots realmente livres (professor + sala + turma); mover para slot sugerido resolve o conflito; mover para slot conflitante é bloqueado
- [x] 3.3 Unitário frontend: badge, conflitos traduzidos, sugestões carregadas, aplicar em 1 clique com reload + emissão do evento (5 testes)
- [ ] 3.4 E2E: coordenador aplica sugestão e o conflito desaparece da lista
