## Why

A JACAD identifica "automação da comunicação operacional" como futuro, mas nenhum concorrente entrega integrado ao cadastro/financeiro: solicitações repetitivas (segunda via, declarações, dúvidas de vencimento) ainda caem na secretaria. A pesquisa mostra que a secretaria deve tratar só exceções. Nosso `self-service-portal` + portal de cobrança já são a base.

## What Changes

- Delta no spec `self-service-portal`: fila de solicitações dos pais resolvida automaticamente com dados reais do aluno
- Solicitações suportadas: 2ª via de fatura, declaração de matrícula, comprovante de quitação, consulta de vencimento
- Respostas automáticas usam os dados do cadastro/financeiro (não respostas genéricas); o que não for resolúvel vira ticket humano
- Painel da secretaria mostra só as exceções + volume resolvido automaticamente (para provar o ganho)

## Impact

- Affected specs: self-service-portal (ADDED requirements)
- Affected code: `PortalService`, novo `GuardianRequestController`, documentos (declarações) reusando report-builder
