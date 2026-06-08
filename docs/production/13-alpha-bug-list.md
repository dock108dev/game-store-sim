# Alpha Bug List

This is the Stop 13.1 alpha triage board. It is built from the latest passing `scripts/validate_godot.sh` run, screenshot artifacts in `artifacts/validation/latest/screenshots/`, the current manual validation checklist, and known release-wrapper limits.

Current gate state:

- Automated validation has no open failures.
- Latest full gate passes with 514 GUT tests, UI scenario automation coverage 476/594, production script mapping coverage 51/51, 3 active validation tools, and 33 catalog products.
- Desktop pack smoke passes through `scripts/verify_desktop_export.sh --pack-smoke`.
- Manual controller/window/playtest validation still needs a human pass.

## Priority Key

- P0: blocks running or validating the alpha package.
- P1: blocks alpha-quality player readability or core-loop confidence.
- P2: visible polish or process risk that should be fixed before external playtest if time permits.
- P3: known follow-up that can remain documented for post-alpha work.

## Triage Board

| ID | Priority | Area | Evidence | Problem | Target Slice | Acceptance |
| --- | --- | --- | --- | --- | --- | --- |
| AH-001 | P1 | Store visual read | `main_scene.png`, `customer_queue.png`, `fixture_placed.png` | The store still reads as a graybox from normal angles: large blank planes, low material variation, flat ceiling/floor, and sparse merchandising density. | Stop 13.4 content pass | Main scene and customer-queue screenshots read as a small specialty game shop without relying on docs to explain the space. |
| AH-002 | P1 | Signage and hierarchy | `main_scene.png`, `customer_queue.png`, `fixture_placed.png`, `receiving_area.png` | Several signs are cropped, occluded, or weakly framed from player angles, including register/backroom/display/fixture signage. | Stop 13.4 content pass | Key signs are readable, fictional, and framed without clipping from screenshot viewpoints. |
| AH-003 | P1 | Customer readability | `customer_queue.png`, `suspicious_customer.png`, `trade_in_offer.png` | Customer roles are still carried mostly by floating labels, colors, and large props; bodies remain placeholder-like and props can visually collide with heads/torso. | Stop 13.4 content pass | Buyer, trade-in, preorder, service, and suspicious customers read by silhouette/prop placement before prompt text. |
| AH-004 | P1 | Queue and register composition | `customer_queue.png`, `register_counter.png`, `preorder_deposit.png`, `service_request.png` | Register-side roles crowd the same visual lane, with overlapping labels/props and weak separation between buyer queue and special customers. | Stop 13.3 regression tests, Stop 13.4 content pass | Customer queue, special-customer arc, and register prompt remain readable with no label pileup in the screenshot set. |
| AH-005 | P1 | Fixture placement | `fixture_placed.png`, `fixture_ghost.png`, `fixture_rotated_ghost.png` | Placed storage rack can dominate the camera as a tall slab and obscure store/backroom signage, making the confirmed placement read less intentional than the ghost preview. | Stop 13.3 regression tests | Placed fixture screenshot shows a grounded, readable rack with clear orientation and no camera-blocking slab presentation. |
| AH-006 | P1 | Backroom computer density | `backroom_summary.png`, `release_calendar.png`, `release_allocation.png`, `launch_day.png` | The backroom computer is functionally complete but visually dense; the bottom controls and storage placement area can sit below the visible frame, and tabbed report screens look too similar in screenshots. | Stop 13.4 content pass | Dashboard, release, launch, and report screenshots show distinct section hierarchy and visible primary controls at 1280x720. |
| AH-007 | P2 | Modal focus | `trade_in_offer.png` | The trade-in modal is readable, but background bodies/props intrude strongly on the right edge, weakening modal focus. | Stop 13.4 content pass | Modal screenshots keep background context dim and noncompeting while preserving player orientation. |
| AH-008 | P2 | Screenshot coverage quality | `release_calendar.png`, `release_allocation.png`, `launch_day.png`, `fixture_invalid_ghost.png` | Some automated screenshots prove nonblank rendering but are not composition-specific enough to catch all release/launch/invalid-placement readability issues. | Stop 13.3 regression tests | Screenshot scenarios frame their named subject clearly enough that human review can distinguish the intended state. |
| AH-009 | P2 | Release packaging | `scripts/verify_desktop_export.sh`, `game/export_presets.cfg`, `15-alpha-playtest-package.md` | Pack smoke is automated, but binary app export and start-save-quit-relaunch-continue still depend on local Godot export templates/signing and remain manual. | Stop 13.6 external playtest package | Done: playtest package instructions produce the pack-smoke artifact, list local binary-template/signing blockers, and include rollback guidance. |
| AH-010 | P2 | Manual validation debt | `07-current-manual-playtest.md`, `15-alpha-playtest-package.md` | The internal checklist is current but very large; external playtest uses a shorter script that exercises the alpha path without burying testers in internal validation details. | Stop 13.6 external playtest package | Done: external playtest script covers fresh start, receiving, pricing, stocking, sale, trade-in, service/preorder, backroom, save/load, and feedback in one readable runbook. |
| AH-011 | P2 | Economy/balance confidence | `07-current-manual-playtest.md`, StoreSession coverage | Automated balance targets are now centralized and covered, but multi-day human feel still needs playtest confirmation before external release. | Stop 13.5 balance pass | Automated balance profile passes; manual multi-day playtest notes show cash pressure, buyer tolerance, services, supplier ordering, launches, and upgrades are understandable and not trivially broken. |

## Not Currently Blocked

- No P0 automated validation failures are open.
- Core retail loop tests pass, including pickup, pricing, stocking, checkout, trade-ins, preorders, services, ordering, fixture placement, save/load codec, settings, pause/menu, hidden-thread optionality, screenshots, and export pack smoke.
- The next implementation should fix P1 readability/composition issues before treating the build as external-playtest ready.

## Slice Routing

- Stop 13.2 performance pass: done in `14-alpha-performance-baseline.md`; rerun after content-heavy changes before tightening thresholds.
- Stop 13.3 test expansion: done; regression coverage now protects rotated fixture placement bounds/history, visible buyer queue spacing against special register customers, screenshot scenario coverage for AH-001 through AH-006 and AH-008, and future bug fixes that change core loop behavior.
- Stop 13.4A scene-readability content pass: done; addresses the first visual/UI composition layer for AH-001 through AH-007 with wall detail, sign framing, customer spacing, rack profile cues, placed-fixture screenshot framing, and backroom first-view controls.
- Stop 13.4B content/copy pass: done; continues AH-001, AH-002, AH-003, AH-006, and AH-007 with customer text, dialogue context, supplier orders, release planning, report copy, register return-scope copy, and backroom action-label polish.
- Stop 13.5 balance pass: done; addresses AH-011 with centralized alpha balance targets, tuned economy values, automated coverage, and manual multi-day balance checks.
- Stop 13.6 external playtest package: done; addresses AH-009 and AH-010 with `15-alpha-playtest-package.md`, build artifact guidance, known issues, playtest script, feedback form, rollback plan, validation scenario entries, and manual package checks.
- Stop 13.7 alpha validation sync: done; records the current full-gate, desktop pack smoke, scenario matrix, manual checklist, bug-list routing, backlog state, and playtest-package handoff before human external playtest.
