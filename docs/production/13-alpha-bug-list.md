# Visual Bug List

This is no longer an alpha/beta readiness board. It tracks current blockers that prevent design-source visual approval and implementation-roadmap signoff.

## Current Gate State

- Automated validation has no open failure from the last full run.
- Current doc-contract expectation is 571 GUT tests and 10908 asserts. Latest full validation gate is green with UI scenario automation coverage 508/628, production script mapping coverage 53/53, 3 active validation tools, and 60 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan passed.
- All 23 required screenshot files were present, screenshot sanity passed, and `artifacts/validation/latest/screenshot-contact-sheet.png` was generated.
- The visual/design result is not yet approved against the design source of truth or implementation roadmap.

## Priority Key

- P0: blocks running or validating the project.
- P1: blocks design-source visual approval.
- P2: visible polish risk after the baseline is approved.

## Current Issues

| ID | Priority | Area | Evidence | Problem | Target Slice | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| VIS-002 | P1 | Store shell first read | `main_scene.png`, `storefront_entry.png`, real-window owner review | The opening store must read as underfunded but functional, not empty, modern, corporate, or prototype-like. | Implementation Roadmap Phase 3 | Storefront, front window, sign, carpet, wall treatment, lights, stockroom doorway, and checkout anchors establish the era and business type before broader content. |
| VIS-003 | P1 | Required zones | contact sheet, walk-in review | The starting store must clearly communicate new releases, used games, platform sections, checkout, trade-in, demo, bargain, guides/media, and receiving support. | Implementation Roadmap Phases 4-5 | Required vertical-slice zones are identifiable from fixtures, products, layout, and signage without debug identity text. |
| VIS-004 | P1 | Roadmap scope | asset workbook, implementation docs, roadmap review | The 300-object workbook must feed phased implementation packets, not a loose-prop dump. | Implementation Roadmap Phases 1-6 | Work proceeds through packeted reusable phase slices that improve first read and the core setup loop before broad catalog/customer/decor work. |

## Resolved Routing Notes

| ID | Area | Resolution |
| --- | --- | --- |
| VIS-001 | Documentation routing | Design canon remains in `docs/design-source-of-truth/`; active agent execution starts in `docs/design-implementation/`; production and QA docs support status/evidence only. |

## Routing

Do not add broad catalog, customer, decoration, hidden narrative, later-era, or external alpha/beta package work while VIS-002 is open.
