# Política de Privacidade (LGPD)

> **Rascunho interno** — sujeito a revisão jurídica antes de uso comercial (fix-lgpd-compliance-gaps 5.1). Não publicar versão final sem aprovação do jurídico.

## 1. Controladora, encarregado e contato

- **Controladora:** a escola contratante (B2B) é a controladora dos dados de alunos, responsáveis e colaboradores; a plataforma atua como **operadora** de dados (art. 5º, VII).
- **Encarregado de Proteção de Dados (DPO):** `dpo@escolamais.com.br`.
- **Canal de exercício de direitos:** API de direitos do titular (autenticados) abaixo + e-mail ao DPO. Resposta em até **15 (quinze) dias úteis**.

## 2. Dados coletados

- **Identificação:** nome, CPF, data de nascimento, e-mail e teleone do aluno e dos responsáveis legais;
- **Dado sensível:** cor/raça (Censo/INEP — art. 11, II "a"), gênero e nome da mãe (fornecidos pela escola para obrigações oficiais);
- **Dados acadêmicos:** matrículas, turmas, frequência, avaliações e notas;
- **Dados de acesso:** usuário, aceite de termos, consentimento de cookies, IP pseudonimizado (HMAC com salt, art. 4º) e user-agent;
- **Não coletamos dados de saúde, filiação ou religião sem base legal específica.**

## 3. Finalidades e bases legais

| Finalidade | Base legal (art. 7º) |
|---|---|
| Prestação do serviço de gestão escolar (matrículas, notas, comunicação, cobrança) | Execução de contrato (V) |
| Registros escolares e dados oficiais (Censo/INEP, cor/raça, nome da mãe) | Cumprimento de obrigação legal ou regulatória (II) e art. 11, II "a" |
| Segurança da plataforma, prevenção a fraudes, trilhas de auditoria | Legítimo interesse (IX) |
| Prova de consentimentos e aceites de termos | Cumprimento de obrigação legal (8 §2º) |
| Analytics do portal e cookies opcionais | Consentimento (I) — revogável a qualquer momento |

## 4. Prazos de retenção

| Categoria | Prazo |
|---|---|
| Registros acadêmicos (matrículas, notas, frequência) | Retidos sob pseudônimo após anonimização do titular (obrigação legal de guarda) |
| Consentimentos de cookies e aceites de termos | 5 anos após o último aceite (prova do consentamento) |
| Log de auditoria técnica de acesso | 90 dias |
| Histórico de busca do portal | 30 dias |
| Dados de conta inativa | Anonimização irreversível após 365 dias de inatividade |

## 5. Compartilhamento

Os dados são processados por nossos subfornecedores/infraestrutura (AWS, Supabase, Asaas, Auth0) sob instruções firmadas e NDA, limitados ao necessário para a prestação do serviço. Eventos de analytics (com consentimento) podem tráfegar para GA4/PostHog. **Não comercializamos dados.**

## 6. Direitos do titular (art. 18)

- **Acesso / portabilidade:** `GET /api/privacy/data-subject/me/export` (JSON);
- **Retificação:** `PUT /api/privacy/data-subject/me/correction`;
- **Exclusão / anonimização:** `DELETE /api/privacy/data-subject/me` (anonimização irreversível — registros acadêmicos permanecem sem identificadores diretos, sob pseudônimo);
- **Revogação de consentimento:** preferências de cookies no portal (perfil → "Gerenciar preferências de cookies").

## 7. Segurança

- HTTPS em produção; auditoria de chamadas mutáveis (`AuditLoggingMiddleware`);
- IP de acesso e rate-limit hash com salt via HMAC (art. 4º — minimização);
- Job diário de retenção remove/anonimiza categorias vencidas;
- Volcamento de headers e logs de teste restritos a ambiente de desenvolvimento/teste.

## 8. Menores

O acesso à plataforma como titular passa por login de responsável legal. Consentimento específico para tratamento de dados de menores é dado pelo responsável legal com prova de como foi obtido.
