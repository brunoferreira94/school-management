## 1. Backend
- [ ] 1.1 Novo tipo de bloco `ai-narrative` no modelo de templates do report-builder
- [ ] 1.2 `AiDraftService` gera narrativa a partir dos dados dos outros blocos do relatório (mesma base), citando os números
- [ ] 1.3 Estado "review required" no bloco: exportação bloqueada enquanto narrativa não aprovada; trilha de auditoria de quem aprovou
- [ ] 1.4 Template padrão "Resumo executivo mensal" (matrículas, inadimplência, frequência, evasão) com bloco de narrativa

## 2. Frontend
- [ ] 2.2 Bloco de narrativa no editor WYSIWYG: badge "pendente de revisão", editar antes de aprovar
- [ ] 2.3 No preview, narrativa mostra os números citados destacados (hover → fonte do dado)

## 3. Testes
- [ ] 3.1 API: exportação com bloco de narrativa não aprovado é bloqueada
- [ ] 3.2 Unitário: narrativa gerada cita somente dados presentes nos blocos do próprio relatório
- [ ] 3.3 E2E: diretor gera resumo mensal, revisa narrativa, aprova e exporta PDF
