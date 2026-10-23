## 1. Backend
- [ ] 1.1 `ISchoolTemplateProvider` + implementações por segmento: infantil, fundamental, medio, idiomas, tecnico (refatorar DefaultSchoolTemplate2026 para o provider)
- [ ] 1.2 `GET /api/onboarding/segments`: segmentos disponíveis com preview da estrutura (disciplinas, anos, modelo de turmas)
- [ ] 1.3 `POST /api/onboarding/seed-standard` aceita `segment` e usa o template correspondente
- [ ] 1.4 Extensão do `RegisterSchoolRequest` (self-service): segmento opcional no cadastro

## 2. Frontend
- [ ] 2.1 Wizard de onboarding: passo de escolha de segmento com preview da estrutura
- [ ] 2.2 Formulário /cadastro: campo opcional de segmento (select)

## 3. Testes
- [ ] 3.1 API: seed com segmento idiomas cria níveis A1-C1; infantil cria berçário-jardim; sem segmento mantém comportamento atual
- [ ] 3.2 E2E: escola de infantil escolhe segmento no wizard e recebe estrutura típica em 1 clique
