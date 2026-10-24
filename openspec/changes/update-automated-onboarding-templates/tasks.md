## 1. Backend
- [x] 1.1 `ISchoolTemplateProvider` + implementações por segmento: infantil, fundamental, medio, idiomas, tecnico (refatorar DefaultSchoolTemplate2026 para o provider) — `SegmentedSchoolTemplateProvider` delega ao `DefaultSchoolTemplate2026` quando não há segmento
- [x] 1.2 `GET /api/onboarding/segments`: segmentos disponíveis com preview da estrutura (disciplinas, anos, modelo de turmas)
- [x] 1.3 `POST /api/onboarding/seed-standard` aceita `segment` e usa o template correspondente — implementado como `POST /api/onboarding/seed-standard/{segment}` (rota separada; `seed-standard` sem rota permanece o padrão 2026); validação de segmento desconhecido → 400
- [x] 1.4 Extensão do `RegisterSchoolRequest` (self-service): segmento opcional no cadastro — persiste em `SetupProgress.SelectedSegment` (migration `AddSetupSegmentSelection`)

## 2. Frontend
- [x] 2.1 Wizard de onboarding: passo de escolha de segmento com preview da estrutura — chooser no welcome modal: grade de segmentos + "Padrão 2026" pre-selecionado, preview de modelo de turma/ciclos/disciplinas/ambientes antes de aplicar
- [x] 2.2 Formulário /cadastro: campo opcional de segmento (select) — enviado como `segment` no payload quando preenchido

## 3. Testes
- [x] 3.1 API: seed com segmento idiomas cria níveis A1-C1; infantil cria berçário-jardim; sem segmento mantém comportamento atual — `SchoolSegmentTemplatesTests` (6 testes: também medio, listing com preview completo, fundamental = padrão); API 688/0
- [x] 3.2 UI: chooser carrega segmentos, preview por segmento, POST por segmento e POST padrão preservado; cadastro envia/omite `segment` — 5 testes karma novos (UI 714/714); e2e Cypress `rcd-onboarding-flow` atualizado para passar pelo chooser (`apply-segment-template`)

### Pendências honestas
- E2E live do fluxo por segmento (escolher idiomas → estrutura criada no banco) ainda não rodado: ambiente staging indisponível (Render 402) e DB local não aplica migrations.
- Segmento persistido em `SetupProgress.SelectedSegment` não é exibido ainda no wizard como "sugestão" (GET progress não devolve o campo no frontend); o template é escolhido manualmente no chooser — automação da pré-seleção fica no backlog.

