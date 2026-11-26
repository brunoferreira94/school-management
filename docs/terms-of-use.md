# Termos de Uso — Escola+ (versão 2026.2)

> **Status**: rascunho técnico estruturado, pendente de revisão jurídica externa (as cláusulas
> marcadas com **[A CONFIRMAR]** — identificação societária e foro — dependem dessa validação).
> **Fonte de verdade exibida ao usuário**: `school-management-ui/src/app/features/legal/termos/termos.component.html`.
> **Versão vigente no backend**: `Legal:TermsOfUseVersion` (`appsettings.*.json`) — `2026.2` em
> base/Development/Staging/Production; `2026.1` apenas no ambiente de teste (`appsettings.Testing.json`,
> autoconsistente com o seeder de aceites). Qualquer alteração desta página exige bump de versão
> (`2026.3`, …) para disparar reaceite, com publicação simultânea dos dois artefatos.
> **Vigência**: 25/11/2026. **Aceite auditado por**: `TermsOfUseAcceptance(+Audit)` — versão,
> data/hora UTC, canal, IP pseudonimizado (HMAC com salt), user-agent.

---

## 1. Das partes e da aceitação

Estes Termos de Uso regulam o acesso e a utilização da plataforma Escola+ ("Plataforma"),
software como serviço (SaaS) de gestão escolar operado por
**[RAZÃO SOCIAL E CNPJ — A CONFIRMAR PELO JURÍDICO]** ("Operadora"), por usuários vinculados a
instituições de ensino contratantes ("Instituição"), inclusive por responsáveis legais de alunos
no portal da família.

Ao criar conta, acessar ou utilizar a Plataforma, o usuário declara ter lido e concordado com
estes Termos e com a Política de Privacidade, incorporada por referência. O aceite é registrado
com a versão aceita, data e hora (UTC), canal de origem, endereço IP pseudonimizado (hash com
salt, nos termos do art. 4º da LGPD) e identificação do navegador, formando prova auditável da
adesão e de reaceites futuros.

## 2. Definições

**Plataforma**: sistema de gestão escolar disponibilizado na web e, quando vier a existir, em
aplicativo. **Instituição**: a pessoa jurídica de ensino contratante, responsável pelas contas
que autoriza e pelos dados que insere. **Usuário**: pessoa autorizada pela Instituição (direção,
coordenação, corpo docente ou administrativo) ou responsável legal que acessa o portal da
família. **Titular**: pessoa natural a quem se referem os dados pessoais tratados na Plataforma.
**LGPD**: Lei nº 13.709/2018.

## 3. Licença e uso do serviço

A Operadora concede ao Usuário licença não exclusiva, intransferível e revogável para utilizar a
Plataforma exclusivamente na operação da Instituição, condicionada a contas criadas ou
autorizadas por ela e às permissões definidas por papel. É vedado sublicenciar, revender ou
disponibilizar a Plataforma a terceiros alheios à Instituição, bem como utilizá-la para
finalidade diversa da gestão escolar.

## 4. Credenciais e conduta do Usuário

O Usuário responde pela confidencialidade de suas credenciais e por todos os atos praticados com
sua conta, e deve comunicar imediatamente à Instituição e à Operadora qualquer suspeita de
comprometimento. Compete à Instituição administrar suas contas e revogar acessos de pessoas
desligadas.

São proibidos: o uso ilícito ou ofensivo da Plataforma; tentativa de acesso a dados de outras
instituições (tenants); engenharia reversa; coleta automatizada em massa de dados (scraping) sem
autorização expressa; e qualquer interferência na segurança, integridade ou disponibilidade do
serviço.

## 5. Papéis na LGPD: controlador e operador

**(a) Dados acadêmicos e cadastrais de alunos, responsáveis e colaboradores** inseridos pela
Instituição: a Instituição é a **controladora** e define as finalidades e as bases legais do
tratamento (arts. 7º e 11 da LGPD); a Operadora atua como **operadora** de dados (art. 5º, VII, e
art. 39), tratando-os exclusivamente sob as instruções documentadas da Instituição, com registros
do tratamento, medidas de segurança e assistência no atendimento a titulares e à ANPD.

**(b) Dados de conta e de uso do serviço** — cadastro de acesso, aceite destes Termos,
consentimento de cookies, logs técnicos e analytics do portal: a Operadora é a **controladora**,
tratando-os conforme a Política de Privacidade.

Os direitos do titular (art. 18 da LGPD) são exercidos pelos canais descritos na Política de
Privacidade — endpoints autenticados da própria Plataforma e o Encarregado de Proteção de Dados
(DPO), **dpo@escolamais.com.br** —, com resposta em até 15 (quinze) dias.

## 6. Menores de idade (art. 14 da LGPD)

A Plataforma trata, em regra, dados de estudantes, frequentemente menores de idade. O tratamento
que dependa de consentimento — em especial o que exceda obrigações legais e regulatórias — exige
consentimento específico e destacado de, no mínimo, um responsável legal, registrado com prova de
como foi obtido (versão do termo de consentimento, data e hora, canal e identificação do
responsável).

Enquanto o consentimento parental não estiver registrado, as funcionalidades que dele dependem
permanecem bloqueadas. O consentimento pode ser revogado a qualquer momento, com efeito imediato,
resguardados o interesse superior da criança e as obrigações legais de guarda dos registros
escolares.

## 7. Cookies e ferramentas de análise

Cookies estritamente necessários à operação são utilizados independentemente de consentimento.
Cookies de análise e instrumentos análogos dependem de consentimento prévio, livre, informado e
inequívoco, revogável a qualquer momento nas preferências de cookies do portal.

## 8. Conteúdos e dados fornecidos pelo Usuário

A Instituição declara que os dados e conteúdos que insere na Plataforma são verídicos, lícitos e
coletados com base legal válida, respondendo, na condição de controladora, pela regularidade do
tratamento que realiza. O Usuário concede à Operadora licença limitada — hospedagem, exibição,
backup, suporte e operação do serviço — pelo tempo necessário à prestação do serviço.

Os dados não são utilizados para treinar modelos de inteligência artificial de terceiros nem
cedidos para publicidade. Conteúdo de aluno não é encaminhado a serviço de IA externo sem
contrato de operador (DPA) e base legal documentada.

## 9. Disponibilidade, suporte e guarda de registros

A Operadora empregará esforços razoáveis para manter a Plataforma disponível de forma contínua,
podendo haver indisponibilidades por manutenção programada, fatores externos ou caso de força
maior. Suporte técnico: **suporte@escolamais.com.br**.

Os backups de infraestrutura não substituem a guarda documental própria da Instituição:
recomenda-se que ela mantenha, sob sua responsabilidade, as cópias e os registros que a
legislação educacional e fiscal lhe impõe.

## 10. Contratação, pagamentos e efeitos de inadimplência

O uso comercial da Plataforma é contratado pela Instituição em plano com ciclo mensal ou anual,
conforme o contrato de adesão exibido no ato da contratação — que integra estes Termos — e o
contrato principal e o acordo de tratamento de dados (DPA) da Instituição, cujas referências
ficam registradas para auditoria.

As cobranças são processadas por operadores de pagamento (ex.: Asaas, Stripe). O atraso pode
implicar suspensão do serviço ou restrições de uso até a regularização. Reajustes, cancelamento e
reembolsos seguem o plano contratado e a legislação aplicável.

## 11. Propriedade intelectual

Os softwares, marcas, interfaces e conteúdos próprios da Plataforma pertencem à Operadora e são
protegidos pela legislação de propriedade intelectual. Os dados e conteúdos inseridos pelos
Usuários pertencem à Instituição e aos respectivos titulares, na forma da cláusula 8. O uso da
marca "Escola+" sem autorização expressa é vedado.

## 12. Alterações destes Termos

Estes Termos são versionados. As alterações são publicadas nesta página e, quando relevantes,
comunicadas no próprio sistema. O uso continuado após a publicação implica ciência e aceitação;
quando for exigido novo aceite expresso, o sistema o solicitará no próximo acesso, permanecendo o
Usuário em modo restrito — com autenticação, encerramento de sessão e leitura dos documentos
legais — até aceitar a versão vigente. O registro de aceite de cada versão permanece na trilha de
auditoria para fins de comprovação.

## 13. Suspensão e encerramento

A Operadora poderá suspender ou encerrar o acesso por: inadimplência; violação grave destes
Termos; risco aos dados, à segurança ou a outros usuários; ou determinação legal ou autoridade
competente. A Instituição pode encerrar a contratação conforme o plano contratado.

Encerrado o contrato, os dados são tratados conforme a Política de Privacidade — com
exportação/portabilidade quando solicitada e anonimização ou exclusão dos dados cuja conservação
não seja exigida por obrigação legal.

## 14. Segurança da informação e incidentes

São adotadas medidas técnicas e organizacionais aptas a proteger os dados pessoais (arts. 46 e 47
da LGPD): criptografia em trânsito, controle de acesso por papel, isolamento de dados por
instituição (tenant), trilhas de auditoria, minimização de dados de acesso e rotinas automáticas
de retenção.

Em caso de incidente de segurança com risco relevante, os titulares afetados e a ANPD serão
notificados (art. 48 da LGPD). Quando os dados afetados forem tratados na condição de operadora,
a Instituição será comunicada para as providências que lhe competirem como controladora.

## 15. Limitação de responsabilidade

Nada nestes Termos limita responsabilidade por dolo ou por culpa grave, nem o que a lei vedar
excluir. Na condição de operadora, a Operadora responde por deixar de adotar as medidas de
segurança que lhe competem; a Instituição responde pela licitude e veracidade dos dados que coleta
e insere, pela gestão dos acessos que concede e pelas decisões pedagógicas e administrativas
tomadas com base na Plataforma. A Operadora não responde por conteúdos inseridos pelos Usuários
nem por eventos de força maior.

## 16. Legislação, foro e disposições finais

Aplicam-se as leis da República Federativa do Brasil, especialmente a LGPD, o Marco Civil da
Internet (Lei nº 12.965/2014), o ECA e a Lei de Diretrizes e Bases da Educação Nacional. Fica
eleito o foro do domicílio da Operadora, **[FORO — A CONFIRMAR PELO JURÍDICO; sugestão: comarca
de São Paulo/SP]**, com renúncia a qualquer outro, por mais privilegiado que seja.

A nulidade ou invalidade parcial de qualquer cláusula não compromete as demais. Este Termo, a
Política de Privacidade, o contrato de adesão e o contrato principal/DPA da Instituição formam,
em conjunto, as regras de uso da Plataforma. Dúvidas de uso: **suporte@escolamais.com.br**;
assuntos de dados pessoais: **dpo@escolamais.com.br**.

---

*O texto exibido ao usuário é idêntico a este (cláusulas 1–16). Ao alterá-lo, atualize os dois
artefatos no mesmo commit e faça bump da versão em `Legal:TermsOfUseVersion`.*
