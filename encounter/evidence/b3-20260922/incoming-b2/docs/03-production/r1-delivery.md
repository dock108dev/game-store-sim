# R1 illustrated encounter — delivery record

Updated 2026-09-07 local / 2026-09-08 UTC. Status: **accepted within its bounded scope**. On 2026-09-08, after operating R1, the owner said **“ready to build on.”** This accepts the bounded R1 encounter and authorizes R2, a repeatable business day. It is not complete-game or release acceptance. Existing retail-v4 appearance feedback and motion-continuation permission stand; R1 acceptance is now recorded separately below.

## Bounded result

`encounter/` is an isolated Godot project. Receive two prepaid used copies of Curb Circuit 02 → set price → stock the retail-v4 shelf → open → one customer arrives, browses, exclusively selects one copy, carries it to checkout → sale → close/report → save/reload. Clickable stations and the shift desk route Rowan through the shop. WASD/arrows and floor clicks remain available. Shelf depletion happens on selection and ownership clears on sale. Closing before checkout returns reserved stock.

At $21.99: starting cash $550.00, revenue $21.99, cost of goods $8.00, gross margin $13.99, ending cash $571.99, one remaining prepaid copy. No purchase expense is double-counted. The shift stops here; reordering, subsequent days and price-sensitive demand are later slices.

## State assessment and transaction qualification

Reviewed `game/scripts/systems/engine_proof_state.gd` before integration. It stores float money, fixture slots, hand references and customer selections separately, has no exclusive reservation, and accepts sales without a phase guard. Its fixture movement and 12-item catalog belong to the historical first-person adapter. Reusing that state would retain unnecessary synchronization paths for this small overview.

Decision: replace the transaction layer in `encounter/state.gd`; reuse the existing retail-v4 imagery, rig/pivots and bounded directional pose implementation. Preserve the historical game and both standalone samples byte-for-byte. Physical-copy identity, integer cents, a single authoritative item location, exclusive customer ownership and explicit selected/queued/leaving phases drive R1. The carried compatibility field is cleared defensively by sale. Reports derive from the sales ledger; load validates ledger, cash, inventory and customer references before replacing live state. Atomic save uses a temporary file and rename. JSON numeric values normalize back to integer cents after validation.

| Defect | R1 disposition | Evidence |
| --- | --- | --- |
| D1 sale after close | Fixed in replacement state; non-open sale rejected, close releases selections | transaction checks, including closing with two reservations |
| D2 competing customers select same item | Fixed in replacement state; distinct physical copies reserved exclusively; third customer fails with no stock | competing a/b/c customer regression and release checks |
| D3 sold item still carried/referenced | Fixed in replacement state; hand, owner and customer item references cleared | injected historical hand conflict, duplicate-sale rejection, sold-state reload |
| D4 old forward movement | Historical, unchanged; adapter not reused | recovery evidence only |

The old prototype still contains its recorded defects; no claim is made that it was repaired. R1's replacement satisfies those invariants before UI integration.

## Technical verification

- 20 transaction checks pass: fresh state, receive-once, price bounds, stocking, open-once, competing reservations, selection versus queue, close/release, sold references, duplicate sale, exact report, atomic save, multiple checkpoint reloads, malformed-load preservation and reset.
- 18 encounter checks pass headless and in normal/Retina rendered runs: viewport mouse input, physical key input, price-field clearance, visible stock, complete customer route without footprint penetration, queue checkpoint reload, sale/report, report reload, four fixture viewpoints and release-to-stop.
- Separate native CUA clicks/keys completed receive → price → E stock → register open → queued sale → close → K save → confirmed reset → L reload. Live display measured 1280×720 logical / 2560×1440 framebuffer, 2× canvas and screen scale. Native walkthrough logs are retained separately from injected-input tests.
- `encounter/scripts/validate.py` reproduced fresh import plus state/input checks from a new temporary project and unique user namespace. It retains timestamped results and can reproduce rendered checks/capture. Saves/tests do not touch historical or owner review saves.
- Actual gameplay footage is a Godot viewport recording driven by the encounter's deterministic capture adapter, using the same state and scene. It is not owner-input footage. Native manual-tool input is documented separately. MP4 metadata, action trace and exact manifest are retained.
- Initial failures retained: JSON integer/float round-trip mismatch; initial headless mouse test used physical-window coordinates. Production load normalization and viewport-local input handling were repaired, then gates rerun. Early prop white backgrounds and pricing-row overlap were caught in live review and repaired before final rendered checks.

See [encounter evidence](../../encounter/evidence/) and [launch/reproduction instructions](../../encounter/README.md). The source manifest binds runtime scripts, assets, import settings and recipes; identity records the base commit, dirty branch and disposable qualification mapping. No commit, push or publication occurred.

## Visual assessment — agent, not owner

Inspected native overview and actual rendered normal/Retina pricing, stocked, queue, report, and shelf/counter viewpoints. Retail-v4 outfit, period shelf silhouette, context and scale are retained. The original layered shelf's decorative stock is hidden in a derivative master; two dynamic case sprites represent actual inventory. New props have transparent corners. Essential product, price, counts, cash and report text remain readable at logical scale. The customer visibly carries the selected case until sale. The shelf occludes actors behind it and actors in front cover the fixture. Paths go around both fixtures; the checkout approach stays beside the counter.

Remaining visual limitations: inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible sliding, mirrored lighting and enlargement artifacts. The customer reuses Rowan's art with warm tint and role label. No detailed cash handoff animation. World station labels can coincide with a freely walking actor; essential duplicate information stays in the clear shift desk. These do not block this bounded sequence in the inspected views. Broad motion/cast polish remains V2 and is not silently marked fixed.

## Production repeatability

Four new/derived editable Krita masters reopen and export byte-identical transparent PNGs: counter, case, shipment and empty shelf. Retained retail-v4 character masters and `rig.json` supply editable source and pivots. Native Krita build recipe, per-asset hashes, lossless import sidecars, alpha settings, display offsets and launch commands are in `encounter/`. Fontconfig/profile/fallback-swap/tile diagnostics are retained in the Krita logs; successful exports do not imply a warning-free Krita session. Sample preservation is independently hash-checked.

## Owner handoff and acceptance

Owner feedback after operating R1, 2026-09-08: **“ready to build on.”** Recorded as acceptance of the bounded R1 encounter and permission to proceed with R2. Existing animation limits remain. Automated checks and agent assessment remain separate from this owner decision; this is not complete-game or release acceptance.
