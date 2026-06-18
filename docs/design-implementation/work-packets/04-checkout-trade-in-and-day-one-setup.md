# Work Packet: Checkout Trade-In And Day-One Setup

Status: Not started
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/06-checkout-and-trade-in-counter-slice.md`
Dependencies: `docs/design-implementation/04-starting-store-layout-spec.md`, `docs/design-implementation/08-required-zones-slice.md`, `docs/design-implementation/09-density-and-clutter-rules.md`, `docs/design-implementation/work-packets/02-store-shell-mall-entrance-stockroom.md`, `docs/design-implementation/work-packets/03-fixtures-and-placement-systems.md`
Expected commit scope: checkout/trade-in counter visuals, queue support, receiving setup tasks, and day-one preparation loop

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/06-checkout-and-trade-in-counter-slice.md`
6. `docs/design-implementation/08-required-zones-slice.md`
7. `docs/design-implementation/09-density-and-clutter-rules.md`

## Context

- Current problem: checkout/trade-in must read as a real small-store counter, not a black block with floating labels, and day one needs a purposeful setup loop before opening.
- Target player-facing result: the player enters an empty-promising store, receives starter stock/setup boxes, places key items, and sees a clean checkout/trade-in station ready for first customers.
- Existing systems that must keep working: register sales, trade-ins, pricing, receiving, pickup/carry, stocking, queue/customer flow, save/load.
- Visual/design docs that define success: checkout slice, required zones, density/setup rules.
- Known prior failures to avoid: trade-in work separated from checkout, overcomplicated register props, behind-counter clutter, future inventory staged early, no visual setup goal.

## In Scope

- Checkout counter/cash wrap visual cleanup.
- Register, scanner, cash drawer, bags, and simple counter equipment.
- Trade-in inspection surface at checkout.
- Behind-counter hold/intake storage for trade-in or reserved items.
- One-line queue support and route clearance.
- Day-one receiving/setup tasks with starter boxes/items.
- Large console box stacking rules where needed.
- Basic demo station anchor if checkout layout needs to preserve the front-opposite relationship.

## Out Of Scope

- Second register or employee counter upgrades.
- Full customer/employee visual breadth.
- Advanced trade-in UI redesign.
- Future inventory catalog.
- Full console display expansion.
- Backroom computer feature expansion beyond preserving existing workflows.

## Do Not Do

- Do not move trade-ins away from checkout.
- Do not overbuild the counter into a big-box retail service desk.
- Do not fill behind-counter space with random clutter.
- Do not stage future locked products in setup boxes.
- Do not make day-one setup depend on hidden instructions only.
- Do not block one-line queue or customer route.
- Do not break register, trade-in, or pricing mechanics.

## Implementation Plan

1. Inspect current register, trade-in, customer queue, and receiving systems.
2. Inspect current counter scene/assets and route constraints.
3. Build/replace checkout counter visual modules using packet 01 materials.
4. Integrate register/scanner/cash drawer/bags and trade-in surface.
5. Place behind-counter intake/hold storage without cluttering sightlines.
6. Add day-one receiving/setup tasks using existing receiving and stocking systems.
7. Preserve save/load and current register/trade-in flows.
8. Capture checkout, trade-in, setup, and queue screenshots.
9. Run focused tests and full validation.
10. Commit and push.

## Likely Files

Scenes:
- active store scene
- register/counter scenes
- receiving/setup item scenes
- queue markers

Scripts:
- register scripts
- trade-in scripts
- receiving scripts
- setup/tutorial/first-use scripts if present
- customer queue scripts

Assets:
- counter modules
- register/scanner/cash drawer/bag props
- setup boxes
- labels/signs for setup only where needed

Data:
- starting inventory/setup data
- receiving/order data
- queue metadata

Tests:
- register sales tests
- trade-in tests
- receiving/setup tests
- save/load tests if setup state changes

Docs:
- `docs/design-implementation/06-checkout-and-trade-in-counter-slice.md`
- `docs/design-implementation/08-required-zones-slice.md`
- `docs/production/13-alpha-bug-list.md` if blockers change

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots for counter read, trade-in read, setup task read, and route safety.
- Run focused register/trade-in/receiving tests.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- checkout counter from customer side
- checkout counter from employee side if useful
- trade-in inspection surface
- behind-counter intake/hold area
- day-one receiving/setup boxes
- queue route from sales floor

## Tests To Add Or Update

- Register/trade-in tests if object paths or station relationships change.
- Setup task tests if a new setup state is introduced.
- Receiving tests if starter stock source changes.
- Save/load tests if setup completion persists.

## Tests To Run

- focused register tests
- focused trade-in tests
- focused receiving/setup tests
- `scripts/validate_godot.sh`

## Documentation Updates

- Update checkout slice if final counter/station positions differ.
- Update current state if day-one setup becomes the next reviewable gameplay loop.
- Log trade-in and setup assumptions.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| Checkout and trade-in remain one station. | Owner wanted shared register/trade-in function with clean counter setup. | No | Expand only with later employee/second-register upgrade. |

## Stop Conditions

- Register/trade-in mechanics require core redesign.
- Queue route cannot be preserved.
- Setup loop cannot use existing receiving/stocking systems.
- Counter still reads as a primitive block.
- Validation exposes a blocker.

## Continue Conditions

- Checkout/trade-in station works and reads cleanly.
- Day-one setup creates purposeful pre-open tasks.
- Products/fixtures can plug into the setup loop.
- No owner decision is needed for next product/signage packets.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Setup task summary
- Known residual issues
- Owner/lead decisions needed
