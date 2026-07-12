# Melhorar usabilidade e importação em lote do Setup Wizard

Autor: _Bruno Ferreira_  
Data: 2026-06-18  
Status: draft  
Origem: nota do Obsidian `School Management - Features Criativas.md`, seção `Sugestões Técnicas — Setup Wizard`.

## Why

A nota do Obsidian aponta lacunas práticas no assistente de configuração inicial: validação inline de CPF/CNPJ, importação em lote de turmas e cursos, tooltips explicativos, validação de capacidade mínima de turmas e template de exemplo para download. Essas melhorias reduzem erro manual no onboarding de novas escolas e aceleram a configuração inicial.

## What Changes

- Adicionar validação inline de CPF/CNPJ para dados da unidade escolar, preservando campos existentes e adicionando campo/documento apenas se necessário.
- Adicionar importação em lote de cursos e turmas via CSV, com validação por linha, preview antes de confirmar e relatório de erros.
- Adicionar tooltips explicativos nos campos de código de sala, curso, turma, capacidade e importação.
- Validar capacidade de turmas no intervalo operacional esperado de 10 a 40 alunos.
- Disponibilizar template de exemplo para download, compatível com o formato aceito pelo importador.

## Impact

- Specs afetadas: `automated-onboarding`.
- Código provavelmente afetado: `school-management-ui/src/app/features/setup/**`, modelos de Setup Wizard, serviço de setup e endpoint backend correspondente.
- Esta proposta não inicia implementação; a execução fica condicionada à aprovação do change.

## Fora de escopo

- Implementação das demais sugestões da nota: UX de tabelas, segurança de sessão e Mobile/PWA.
- Integração com calendário, chatbot, notificações push ou reconhecimento de voz.
- Alterações de pricing, autenticação ou arquitetura global.

## Critérios de aceite da mudança

- Existe pacote OpenSpec completo em `openspec/changes/improve-setup-wizard-usability/`.
- O delta de spec adiciona requisitos testáveis com cenários para validação, importação, tooltips, capacidade e template.
- O `tasks.md` cobre análise, implementação frontend/backend, validação e testes.
- O change passa em `openspec validate improve-setup-wizard-usability --strict`.
