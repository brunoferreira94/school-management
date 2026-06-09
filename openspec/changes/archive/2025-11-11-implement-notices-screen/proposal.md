# Implementar tela de Comunicados

Autor: _a definir_
Data: 2025-10-18
Status: completo

## Why

- Centralizar comunicados oficiais e permitir agendamento/publicação.

## What Changes

- Tela para gerenciar comunicados oficiais da escola (avisos públicos, circulares) com suporte a publicação em páginas públicas e envio interno para responsáveis/alunos.
- Backend: CRUD de comunicados, publicação, agendamento, visibilidade (public/internal).
- Frontend: editor WYSIWYG, listagem pública, filtros por público alvo.
- Integração com módulo de comunicações para envio push/email.

## Acceptance Criteria

- Comunicados podem ser agendados e publicados em data/hora definida.
- Público-alvo aplicado corretamente (turmas, cursos, toda escola).

## Next Steps

- Definir campos obrigatórios e política de arquivamento.

## Post-Implementation Documentation

- Ao finalizar, documentar no `README.md` os campos do comunicados, como agendar/publicar, público-alvo e exemplos de uso com screenshots e links para as rotas de API.
