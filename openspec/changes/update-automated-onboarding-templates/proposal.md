## Why

"Template library" já existe no spec `automated-onboarding`, mas o `DefaultSchoolTemplate2026` é único — uma escola de educação infantil recebe a mesma estrutura de um curso de idiomas. A segmentação por perfil é critério #1 de escolha de sistema segundo os comparativos 2026 ("avalie se atende seu segmento"). Templates por segmento transformam o onboarding em ato de identificação.

## What Changes

- Delta no spec `automated-onboarding`: templates de seed por segmento (educação infantil, fundamental, médio, idiomas, técnico)
- Escolha do segmento no wizard, com preview da estrutura que será criada
- Estrutura por segmento: disciplinas típicas, ciclos/anos, modelo de turma (berçário/jardim vs. 1º-9º vs. níveis A1-C1)

## Impact

- Affected specs: automated-onboarding (ADDED requirements)
- Affected code: `DefaultSchoolTemplate2026` → `SchoolTemplateProvider` (multi-segmento), wizard de onboarding
