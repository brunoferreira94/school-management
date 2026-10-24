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
- ~~E2E live do fluxo por segmento~~ **RESOLVIDA** (2026-10-24): DB local religado (`wt-api-postgres-1` na 5433 + migrations aplicadas) e fluxo completo validado via curl contra a API local — deploy de staging segue bloqueado (Render 402). No caminho, dois bugs reais foram encontrados e corrigidos: (1) `_staffRepository.Add`/`_schoolUnitRepository.Add` sem `await` em `register-school` (concorrência de DbContext — FK/duplicate errors intermitentes no cadastro); (2) tenant self-service nascia **sem ano letivo ativo**, quebrando o seed — `register-school` agora provisiona "Ano Letivo {ano}" ativo e default. Registro E2E: tenant `a9160840-…` → 5 segmentos → `seed-standard/idiomas` → 2 salas (Classrooms), 4 disciplinas (Conversação/Gramática/Compreensão Auditiva/Escrita Criativa), 3 turmas (Inglês A1/B1, Espanhol A1), progresso `selectedSegment=idiomas` ✅ (nota de operação: sem o header `X-Tenant-Id` o seed cai no tenant default — é o contrato atual do cliente).
- ~~Segmento persistido em `SetupProgress.SelectedSegment` não é exibido no wizard~~ **RESOLVIDA** (2026-10-24): `GET /api/onboarding/progress` e `POST /api/onboarding/progress` retornam `selectedSegment`; o chooser pré-seleciona o segmento salvo no cadastro quando ele existe na lista (teste karma de pré-seleção).

