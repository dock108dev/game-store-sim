# Work Packet: Store Shell Mall Entrance Stockroom

Status: Not started
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/03-store-shell-and-mall-entrance-slice.md`
Dependencies: `docs/design-implementation/04-starting-store-layout-spec.md`, `docs/design-implementation/09-density-and-clutter-rules.md`, `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`, `docs/design-implementation/work-packets/01-visual-module-foundation.md`
Expected commit scope: mall approach, storefront, sales floor shell, real stockroom, receiving position, and first-read route

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/03-store-shell-and-mall-entrance-slice.md`
6. `docs/design-implementation/04-starting-store-layout-spec.md`
7. `docs/design-implementation/09-density-and-clutter-rules.md`
8. `docs/design-implementation/11-lighting-materials-and-color-palette-spec.md`

## Context

- Current problem: the store needs to stop reading as a boxy room with a back half-wall and start reading as a mall storefront leading into a real shop.
- Target player-facing result: player starts at a modest mall approach, faces `Games4U`, walks through an open storefront, sees an empty-promising store, and understands that the stockroom is a real separate work area.
- Existing systems that must keep working: player spawn, movement, collision, interaction reach, receiving, stocking, register/trade-ins, backroom computer, screenshot capture.
- Visual/design docs that define success: mall entrance slice, starting layout, density, lighting/materials.
- Known prior failures to avoid: exterior reads as blank hallway, store reads as cube box, stockroom reads as exposed back shelf, receiving visible from sales floor, labels floating everywhere.

## In Scope

- Build or replace the opening mall concourse approach.
- Build the storefront shell, open door/threshold, glass/front-window read, sign housing, and first sightline.
- Build a clean starting sales-floor shell with real walls/floor/ceiling treatment.
- Build a real stockroom doorway or door with employee-only read.
- Place receiving deep enough in the stockroom that it is not visible from the sales floor.
- Add stockroom planning desk anchor with computer/calendar support if it does not create mechanics risk.
- Tune shell lighting/materials enough for fixture packets to work.
- Preserve route widths and interaction reach.

## Out Of Scope

- Final fixture/product stocking.
- Full poster/product cover art pass.
- Customers or employee visuals.
- Decoration breadth.
- Hidden narrative objects.
- Final lighting polish beyond what the shell needs.

## Do Not Do

- Do not use a wall line or half-wall as the final stockroom separation.
- Do not make receiving visible from the sales floor.
- Do not close or block the starting entrance.
- Do not make the storefront depend on debug labels to read.
- Do not hard-lock store name or palette.
- Do not shrink routes so core movement or customer paths break.
- Do not stage future inventory in the stockroom or sales floor.
- Do not revert unrelated changes.

## Implementation Plan

1. Inspect current `graybox_store` or active store scene structure and player spawn.
2. Identify modular shell pieces from packet 01.
3. Lay out mall approach, storefront, entrance threshold, sales floor, and stockroom separation.
4. Preserve or reconnect existing systems: receiving, register, stocking, backroom computer, save/load.
5. Place temporary anchors for checkout/demo/fixtures without filling them yet.
6. Add screenshot targets if current automated screenshots miss the new route.
7. Update docs/tests/status as needed.
8. Capture final game-window screenshots.
9. Run focused tests and full validation.
10. Commit and push.

## Likely Files

Scenes:
- `game/scenes/**/*.tscn`
- active store/main scene
- player spawn or screenshot target scenes

Scripts:
- store scene controllers
- screenshot/camera target scripts
- interaction/receiving hooks if paths move

Assets:
- shell modules
- glass/sign materials
- wall/floor/ceiling materials

Data:
- screenshot target manifests
- route/zone metadata if present

Tests:
- scene load tests
- screenshot target tests
- route/interaction contract tests

Docs:
- `docs/design-implementation/03-store-shell-and-mall-entrance-slice.md`
- `docs/design-implementation/04-starting-store-layout-spec.md`
- `docs/production/13-alpha-bug-list.md` if blockers change

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots with notes on mall approach, storefront, sales floor, stockroom door, receiving visibility.
- Run focused scene/load/interaction tests.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- mall approach facing the storefront
- storefront threshold before entering
- first interior view after entering
- sales floor looking toward stockroom doorway
- stockroom receiving area from inside stockroom
- 1280x720 game-window walk-in angle

## Tests To Add Or Update

- Update screenshot target expectations if camera names or paths change.
- Add scene-load or path/reachability tests where existing patterns support it.
- Update docs status contract only if active docs/status metadata changes.

## Tests To Run

- focused scene/load tests
- focused interaction/receiving tests if object paths move
- `scripts/validate_godot.sh`

## Documentation Updates

- Update current state if the first implementation phase materially changes the next task.
- Update visual bug list if VIS-002 is resolved or replaced by a more specific blocker.
- Log route/layout decisions in this packet.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Store footprint may change if needed to satisfy the first read. | Owner explicitly allowed store/world redesign if it improves the visual target. | No | Record final footprint in docs if changed. |

## Stop Conditions

- The shell still reads as a cube/prototype after integration.
- Stockroom cannot be made real without breaking mechanics.
- Required layout decision would invalidate fixture/checkout/product packets.
- Movement, receiving, register, or stocking cannot be preserved.
- Validation exposes a blocker.

## Continue Conditions

- Store reads from the mall approach.
- Sales floor and stockroom are distinct.
- Receiving is hidden from sales floor.
- Checkout/demo/fixture anchors can fit without route conflict.
- Next packet can place fixtures without redesigning the shell.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Final shell/layout notes
- Known residual issues
- Owner/lead decisions needed
