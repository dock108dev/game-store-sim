# Alpha Bug List

This is the Stop 13.1 alpha triage board. It is built from the latest passing `scripts/validate_godot.sh` run, screenshot artifacts in `artifacts/validation/latest/screenshots/`, the current manual validation checklist, and known release-wrapper limits.

Current gate state:

- Automated validation has no open failures.
- Latest full gate passes with 492 GUT tests, UI scenario automation coverage 455/564, production script mapping coverage 50/50, 2 active validation tools, and 33 catalog products.
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
| AH-009 | P2 | Release packaging | `scripts/verify_desktop_export.sh`, `game/export_presets.cfg` | Pack smoke is automated, but binary app export and start-save-quit-relaunch-continue still depend on local Godot export templates/signing and remain manual. | Stop 13.6 external playtest package | Playtest package instructions either produce a runnable app or explicitly list the local template/signing blocker with rollback path. |
| AH-010 | P2 | Manual validation debt | `07-current-manual-playtest.md` | The checklist is current but very large; external playtest needs a shorter script that exercises the alpha path without burying testers in internal validation details. | Stop 13.6 external playtest package | External playtest script covers fresh start, receiving, pricing, stocking, sale, trade-in, service/preorder, backroom, save/load, and feedback in one readable runbook. |
| AH-011 | P2 | Economy/balance confidence | `07-current-manual-playtest.md`, StoreSession coverage | Automated tests protect accounting behavior, but multi-day prices, margins, rent/bills, delivery timing, launch allocation, and upgrade costs have not had a dedicated balance pass. | Stop 13.5 balance pass | Multi-day playtest notes show cash pressure, buyer tolerance, services, supplier ordering, launches, and upgrades are understandable and not trivially broken. |

## Not Currently Blocked

- No P0 automated validation failures are open.
- Core retail loop tests pass, including pickup, pricing, stocking, checkout, trade-ins, preorders, services, ordering, fixture placement, save/load codec, settings, pause/menu, hidden-thread optionality, screenshots, and export pack smoke.
- The next implementation should fix P1 readability/composition issues before treating the build as external-playtest ready.

## Slice Routing

- Stop 13.2 performance pass: profile scene load, screenshot capture, exported pack startup, UI panel open/close, and customer pathing before adding more art/content weight.
- Stop 13.3 test expansion: add regression coverage for fixture placement framing, queue/register composition, screenshot subject framing, and any bug fix that changes core loop behavior.
- Stop 13.4 content pass: address AH-001, AH-002, AH-003, AH-004, AH-006, and AH-007 with production-quality scene/content/UI composition.
- Stop 13.5 balance pass: address AH-011 with multi-day economy tuning and documented balance targets.
- Stop 13.6 external playtest package: address AH-009 and AH-010 with build packaging, known issues, playtest script, feedback form, and rollback plan.
