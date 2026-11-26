# Spec Delta — Capability `public-presence`

## ADDED Requirements

### Requirement: Public pricing page is fully localized and catalog-driven

The public `/pricing` page SHALL render all copy in Brazilian Portuguese and SHALL source prices,
cycles and limits from the plan catalog API. Placeholder strings SHALL NOT reach production.

#### Scenario: Anonymous visitor sees real prices

- **GIVEN** an anonymous visitor opens `/pricing` in production
- **WHEN** the page finishes loading
- **THEN** each plan card shows a real price (`R$ 0` for Free, `R$ 299,90` for Premium,
  `R$ 999,90` for Enterprise) and a Portuguese CTA
- **AND** the page title, badge and comparison table are in Portuguese

#### Scenario: Limits match the catalog

- **GIVEN** the catalog defines different student/staff/unit limits per plan
- **WHEN** the comparison table is rendered
- **THEN** each row shows the catalog value for that plan
- **AND** no limit is hardcoded in the component

#### Scenario: No English placeholders in the shipped bundle

- **GIVEN** the production JavaScript bundle for the public pricing page
- **WHEN** the i18n resources are extracted
- **THEN** no `PRICING.*` value is an English placeholder
- **AND** a regression test fails the build if a new placeholder is introduced