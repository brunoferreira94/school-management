# Proposta: implementar capacidades faltantes do MVP escolar

Autor: _a definir_
Data: 2026-05-28
Status: draft

## Resumo

Criar um OpenSpec change que cobre todas as capacidades faltantes identificadas no documento de apresentação do produto. O objetivo é transformar o núcleo atual em um MVP completo e comercializável, agregando pagamentos, portal familiar, dashboards, funcionalidades pedagógicas avançadas, integrações e maturidade operacional.

## Motivação

O sistema já possui base técnica sólida e funcionalidades centrais de gestão acadêmica, financeira, comunicação e segurança. No entanto, ele ainda não entrega os componentes essenciais que permitem operação comercial, experiência de usuário final e monetização completa.

Sem essas capacidades, o produto permanece como protótipo funcional em ambiente controlado, com baixa prontidão para piloto e mercado.

## O que muda

- Implementação de integração com gateways de pagamento e conciliação financeira.
- Criação do portal de self-service para responsáveis e alunos, com experiência mobile/PWA.
- Construção de dashboards gerenciais e BI básico para equipes administrativas.
- Implementação de funcionalidades pedagógicas avançadas (avaliação por competências, gestão de atividades, relatórios pedagógicos).
- Disponibilização de APIs e integrações com sistemas externos e ecossistema escolar.
- Entrega de artefatos de maturidade de produto e operação: onboarding, documentação, suporte e modelo comercial.

## Escopo

### Incluído

- Backend e frontend para gateway de pagamentos e fluxo de conciliação.
- Portal familiar/autoatendimento com consultas de notas, frequência, boletos e comunicados.
- Dashboards de indicadores-chave: inadimplência, retenção, matrícula e presença.
- Funcionalidades pedagógicas básicas adicionais para avaliações e tarefas.
- APIs públicas e documentação para integrações externas.
- Estratégia de lançamento piloto, onboarding de cliente e materiais de suporte.

### Excluído

- Redação jurídica ou assinatura eletrônica completa de contratos.
- CRM completo de vendas e cobrança como produto independente.
- Soluções de inteligência artificial generativa.
- Integrações com ERP corporativo de terceiros fora do escopo básico de API.

## Critérios de aceite

- Existe um change completo em `openspec/changes/implement-missing-mvp-capabilities/` com proposal, tasks, design e specs.
- A especificação define requisitos testáveis para os 6 blocos de entrega.
- O backlog cobre backend, frontend, QA e documentação.
- O escopo é claro e permite dividir a implementação em entregas incrementais sem equívocos.

## Riscos

- Escopo amplo demais para uma única entrega sem priorização clara.
- Dependências de terceiros para pagamentos e integração com apps mobile.
- Regressões em segurança e LGPD ao expandir o portal familiar e canais externos.

## Mitigações

- Definir entregas incrementais por bloco funcional e priorizar pagamentos + portal familiar como primeiro passo.
- Usar contratos de API e testes de integração para isolar gateways externos.
- Reforçar auditoria, consentimento e controles de acesso em todos os fluxos que lidam com dados pessoais.
