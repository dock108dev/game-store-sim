# Visual Bug List

This is no longer an alpha/beta readiness board. It tracks current blockers that prevent design-source visual approval.

## Current Gate State

- Automated validation has no open failure from the last full run.
- Latest full validation gate is green with 570 GUT tests, 10795 asserts, UI scenario automation coverage 508/628, production script mapping coverage 53/53, 3 active validation tools, and 60 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan passed.
- All 23 required screenshot files were present, screenshot sanity passed, and `artifacts/validation/latest/screenshot-contact-sheet.png` was generated.
- The visual/design result is not yet approved against the new design source of truth.

## Priority Key

- P0: blocks running or validating the project.
- P1: blocks design-source visual approval.
- P2: visible polish risk after the baseline is approved.

## Current Issues

| ID | Priority | Area | Evidence | Problem | Target Slice | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| VIS-001 | P1 | Source-of-truth alignment | owner briefs, workbook, docs review | Active docs previously routed work toward an art-kit gate instead of the full 2002-2004 independent game-store design reset. | Design source Phase 0 | Active docs, status, QA, and tests all point to `docs/design-source-of-truth/` as the authority. |
| VIS-002 | P1 | Store shell first read | `main_scene.png`, `storefront_entry.png`, real-window owner review | The opening store must read as underfunded but functional, not empty, modern, corporate, or prototype-like. | Asset roadmap Phase 1 | Storefront, front window, sign, carpet, slatwall, lights, and cash wrap wall establish the era and business type before broader content. |
| VIS-003 | P1 | Required zones | contact sheet, walk-in review | The starting store must clearly communicate new releases, used games, platform sections, checkout, trade-in, demo, bargain, guides/media, and receiving support. | Asset roadmap Phases 2-5 | Required vertical-slice zones are identifiable from fixtures, products, layout, and signage without debug identity text. |
| VIS-004 | P1 | Asset roadmap scope | asset workbook, roadmap review | The 300-object workbook needs phased implementation, not a loose-prop dump. | Asset roadmap Phases 1-7 | Work proceeds in reusable phase slices, starting with MVP/Must objects that improve first read and core loop. |

## Routing

Do not add broad catalog, customer, decoration, hidden narrative, later-era, or external alpha/beta package work while VIS-001 and VIS-002 are open.
