# Proposal: Integrate Inventory / Patrimônio Screen

Change-id: integrate-inventory-screen

Authors: Bruno (maintainer)

Status: implemented

Created: 2025-10-18
Completed: 2025-10-22

## Why

- Consolidar a gestão de patrimônio em um único módulo administrável.
- Melhorar rastreabilidade de ativos, anexos e relatórios para auditoria.

## What Changes

- Adicionar uma tela de Inventário (Patrimônio) com CRUD completo, anexos e relatórios básicos.
- Expor APIs e componentes frontend para registrar aquisições, acompanhar localização/estado e anexar documentos.

## Goals

- CRUD UI for Assets, attachments, filters and pagination.
- Permissions: MANAGE_ASSETS / VIEW_ASSETS.

## API

- GET /api/assets
- GET /api/assets/{id}
- POST /api/assets
- PUT /api/assets/{id}
- DELETE /api/assets/{id}

Attachments (reuse existing pattern):

- GET/POST/DELETE /api/assets/{id}/attachments

## Implementation Summary

- Backend: `Asset` domain, `AssetAttachment` entity, repository, use-cases (Create/Get/List/Update/Delete), API controllers (`AssetsController`, `AssetAttachmentsController`) with tenant scoping and permissions (`assets.read`, `assets.write`).
- Persistence: EF Core migrations added (see `SchoolManagement.Infrastructure/Migrations/20251020133231_AddAssetAttachmentsTable.cs`) and EF-generated script placed in `release_notes/migrations/AddAssetAttachmentsTable-efcore.sql`.
- Tests: unit and integration tests added for use cases and attachment flows (integration tests use in-memory SQLite and `TestingAuthenticationHandler`).
- Frontend: UI task scaffolding and design notes (component + service) prepared in proposal and tasks; frontend unit tests planned (see proposal tasks).

PR: <https://github.com/brunoferreira94/school-management-api/pull/new/feat/integrate-inventory-screen>

Notes: Most tasks from this proposal have been implemented on branch `feat/integrate-inventory-screen`. Remaining items are optional UI polish and additional e2e frontend tests.

## UI

- List (/assets), Detail/Edit (/assets/:id), Form with WYSIWYG notes and attachments.

See tasks and design files in the same folder for implementation details.

Related: docs/ROADMAP.md (Phase 4)

## Tests

- Frontend unit tests: service (`AssetService`) tests using `HttpClientTestingModule`; component tests for `assets.component` and `asset-form.component` using TestBed and mocked services.
- Attachment flows: tests for `uploadAttachmentWithProgress` usage and UI progress handling.
- Accessibility: keyboard navigation tests for editor shortcuts and tabbable controls.
- Integration tests (optional): end-to-end scenario for create -> upload attachment -> view asset (can be added later as e2e tests).
