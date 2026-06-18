# Visual Bug List

This is no longer an alpha/beta readiness board. It tracks current blockers that prevent design-source visual approval and implementation-roadmap signoff.

## Current Gate State

- Automated validation has no open failure from the last full run.
- Current doc-contract expectation is 586 GUT tests and 11859 asserts. Latest full validation gate is green with UI scenario automation coverage 512/632, production script mapping coverage 54/54, 3 active validation tools, and 62 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan passed.
- All 27 required screenshot files were present, screenshot sanity passed, and `artifacts/validation/latest/screenshot-contact-sheet.png` was generated.
- The owner blocked the current visual direction after review. The current scene is frozen as a mechanics prototype. Packet 09 now provides an isolated art-direction spike and review board for the next owner decision.
- External beta/tester packaging remains blocked.

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
| VIS-007 | P1 | Fixture/counter silhouettes | `lighting_materials_store.png`, `register_counter.png`, `stocked_aisle.png` | Fixture, counter, shelf, and prop silhouettes still read too much like primitive geometry. | Targeted revision packet | Store modules use designed panels, bevels, shelves, trims, cubbies, and stronger material breaks before beta. |
| VIS-008 | P1 | Mall approach depth | `main_scene.png`, `storefront_entry.png`, `lighting_materials_mall.png` | Mall approach and storefront facade are functional but still sparse, flat, and geometric. | Targeted revision packet | Mall route has believable floor, ceiling, railing/edge, neighboring storefront hints, facade depth, and trim. |
| VIS-009 | P1 | Review evidence format | `screenshot-contact-sheet.png` | The generated contact sheet is useful for regression but too small and mixed-purpose for owner-facing art approval. | Targeted revision packet | Visual review board or larger contact sheet groups the route into mall, storefront, interior, counter, product, and stockroom panels. |
| VIS-010 | P1 | Receiving/shelf prop language | `receiving_area.png`, `stocked_aisle.png` | Receiving and browsing still lean on labels and simple blocks instead of enough object silhouette. | Targeted revision packet | Receiving station, shelf modules, product rows, and label placement communicate function before text. |
| VIS-012 | P0 | Art-production method | owner review, `inspiration/`, `new_real_inspiration/`, `docs/design-implementation/15-art-direction-reset-and-spike-plan.md`, `artifacts/validation/latest/packet-09-art-spike-review-board.png` | The current method still produces primitive assembled geometry and should not be extended as the visual source. Packet 09 provides a candidate replacement method for owner review. | Owner art-spike review | Owner approves, requests revisions to, or blocks the Packet 09 art method before full-store rebuild. |

## Resolved Routing Notes

| ID | Area | Resolution |
| --- | --- | --- |
| VIS-001 | Documentation routing | Design canon remains in `docs/design-source-of-truth/`; active agent execution starts in `docs/design-implementation/`; production and QA docs support status/evidence only. |
| VIS-005 | Packet 06 signage reset | Store identity data now keeps `Games4U` as editable default, the entry sign reads as a real closed state instead of setup/debug text, the default shelf label is attached `Potpourri`, and fictional promo categories cover new, trade-in, coming-soon, and sale messaging. |
| VIS-006 | Packet 07 visual evidence reset | Validation now captures 27 screenshots including lighting/material store, warmer mall contrast, product closeup, and stockroom doorway review views; these remain review evidence, not automatic design approval. |
| VIS-011 | Packet 08 owner review package | `docs/production/14-owner-visual-review-package.md` now centralizes final screenshot notes, validation evidence, residual visual risks, and owner approve/revise/block options. |

## Routing

Do not add broad catalog, customer, decoration, hidden narrative, later-era, playable-store rebuild, or external alpha/beta package work while VIS-012 is awaiting owner decision.
