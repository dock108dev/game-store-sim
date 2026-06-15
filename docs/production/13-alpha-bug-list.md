# Visual Bug List

This is no longer an alpha/beta readiness board. It tracks only current blockers that prevent visual baseline approval.

## Current Gate State

- Automated validation has no open failure from the last full run.
- Latest full validation gate after the first art-kit implementation is green with 570 GUT tests, 10791 asserts, UI scenario automation coverage 508/628, production script mapping coverage 53/53, 3 active validation tools, and 60 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture, screenshot sanity, contact-sheet generation, and old-name scan passed after the integrated art-kit route.
- All 23 required screenshot files were present, screenshot sanity passed, and `artifacts/validation/latest/screenshot-contact-sheet.png` was generated.
- The visual result is still rejected as cube/label language.

## Priority Key

- P0: blocks running or validating the project.
- P1: blocks visual baseline approval.
- P2: visible polish risk after the baseline is approved.

## Current Issues

| ID | Priority | Area | Evidence | Problem | Target Slice | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| VIS-001 | P1 | Art language | contact sheet, real-window owner review | The old route read as raw cube geometry, labels, and scattered rectangular props. The new kit route is integrated but not yet owner-approved. | Art language rebuild Phase H | The sandbox and production route read as storefront/register/shelf/receiving/backroom through modules, materials, lighting, and product surfaces before labels. |
| VIS-002 | P1 | Storefront identity | `main_scene.png`, `storefront_entry.png` | Candidate storefront kit is integrated; owner review must confirm it reads as architecture rather than shaped boxes. | Storefront facade validation | Facade has sign housing, trim, glass, mullions, threshold, and mall context that read as a believable retail front. |
| VIS-003 | P1 | Register and fixtures | `register_counter.png`, `stocked_aisle.png` | Candidate register/shelf/product kits are integrated; owner review must confirm the first interior read is strong enough. | Register and shelf/product validation | Counter, POS, shelves, product rows, and day-one stock read from silhouette and material treatment. |
| VIS-004 | P1 | Receiving/backroom | `receiving_area.png`, `backroom_summary.png` | Candidate receiving/backroom kits are integrated; owner review must confirm they read as staged workflow and staff architecture. | Receiving and backroom threshold validation | Receiving reads as staged workflow; backroom reads as staff architecture with depth and material transition. |

## Routing

Do not add broad catalog, customer, decoration, or beta-package work while VIS-001 is open.
