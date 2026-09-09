# R2 — repeatable business day

2026-09-08 local / 2026-09-09 UTC. **Accepted within scope.** Owner feedback on R2: **“build on.”** This accepts the bounded repeatable business day and authorizes R3 — meaningful pricing consequences. Existing animation limitations remain; this is not complete-game or release acceptance.

## Owner decision and scope

After operating R1 the owner said **“ready to build on.”** Recorded as acceptance of the bounded R1 encounter and permission to build R2. This is not complete-game or release acceptance. Prior animation limitations remain; R1's historical evidence and pre-R2 source archive are retained.

R2 connects closing/report → order within cash → advance day → receive paid shipment → price/stock → open/sell/close/report again. Existing Curb Circuit 02, fixtures, illustrated retail-v4 art and one visitor per day remain. One optional order of 1–6 copies per closed day keeps replenishment small. At the R2 boundary demand did not react to price; R3 is now authorized.

## Business state

`state.gd` schema 2 adds a day number, cumulative purchase ledger and sale day stamps. Payment occurs at order confirmation only; pending purchases become backroom copies only when explicitly received on the following day. Each received copy uses the order day plus copy ordinal as its unique identity. An order's received marker, one-order-per-day guard and expected-day confirmation token prevent duplicated receipts, payments and transitions.

Unsold copies and their individual prices survive advancement. Pricing updates backroom stock only. Daily customers/reservations reset on advancement after close has released ownership. Sales retain the R1 phase, queue, exclusive-copy and sold-reference guards. Daily reports filter the cumulative sale ledger by day. Available cash remains cumulative.

Revenue is today's completed sales; inventory cost is the $8 acquisition cost of each copy sold today; gross profit is revenue minus that cost before overhead. Unsold copies are not expensed. Cash is $550 plus cumulative sales minus paid orders. The two original copies are prepaid. The README and report tooltip define this explicitly.

At the default automated two-copy replenishment: day 1 cash $571.99 → pay $16 → $555.99 → receive with no charge → second sale → day 2 cash $577.98. Each day reports $21.99 revenue, $8 inventory cost, $13.99 profit. Two unsold copies remain; cumulative revenue is $43.98 and gross profit $27.98.

Atomic save/load validates ledgers, cash, physical identities and customer ownership before replacing live data. JSON money/day values normalize to integers. R2 uses a new isolated review namespace; R1 saves remain untouched and are not silently migrated. Animation/routes resume from coherent checkpoints rather than exact poses.

## Automated evidence

Final reproduction: [validation-20260909T001034779799Z](../../encounter/evidence/validation-20260909T001034779799Z/).

- 20 R1 transaction checks pass, including D1–D3, duplicate sale and malformed-load preservation.
- 28 R2 checks pass: invalid quantities, wrong/stale day, insufficient funds reached by legitimate purchases across days, exactly-once charge/receipt/advance, distinct copies, daily reset, cumulative state and boundary reloads.
- 27 encounter checks pass headless and in normal/Retina rendered runs: two shifts through visible controls/dialogs, queue reload, second-day pricing/carryover, customer routes and collision checks, repeated day confirmation, fixture viewpoints, physical movement and release.
- Fresh-import disposable project/save namespace; runtime source hashes match the working candidate. Prior failed or interrupted runs are retained. Dialog sizing and report overlap were repaired before the final pass; no checks were suppressed.
- [Actual gameplay movie](../../encounter/evidence/validation-20260909T001034779799Z/r2-gameplay.mp4): 1280×720, 30 fps, 31.97 seconds. Deterministic capture through the actual scene/state, not owner input. Order and advance are dispatched directly by the recording adapter; visible dialog controls are separately tested and captured. [Action trace](../../encounter/evidence/validation-20260909T001034779799Z/gameplay-trace.json).

## Native operation — agent

[Native record](../../encounter/evidence/r2/native-review.md), [engine log](../../encounter/evidence/r2/native-playthrough.log), and [final disposable save](../../encounter/evidence/r2/native-final-save.json) retain a second two-day variant. Native input rejected quantity zero, previewed three copies at $24, placed the order, saved/reloaded, advanced, received once, typed $24.99 labels, stocked four mixed-price copies, opened/sold/closed and reloaded the report. Final cash $569.98; three unsold copies. Native screenshots were inspected in the task; normal/Retina artifact captures are in the final automated evidence directory. CUA window-selection glitches were resolved by raising the same running window; they did not require a state reset.

## Visual and production assessment — agent

Inspected normal/Retina order preview, day confirmation, mixed-price stocked shelf and second report. The live total, quantity, cost, cash, day and main buttons remain readable. No report row lies under the next-day button. Four case frontage positions cover the native three-copy replenishment plus carried inventory; larger totals remain authoritative in the shelf count. This is not a full-shop capacity model.

No art files changed: retained editable Krita masters, exports, pivots and actor rig remain. Additional frontage uses the existing case sprite. [Preservation comparison](../../encounter/evidence/r2/preservation-result.json) checks 292 historical game/sample/art/source files unchanged. Existing world artwork contains decorative price/carton lettering; the shift desk is authoritative for transaction quantities/prices.

Inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts and reused/tinted customer rig remain. No detailed cash handoff animation. Full-shop expansion, large catalogs/casts and broad animation polish are deferred.

## Handoff and identity

Launch and reproduction: [encounter README](../../encounter/README.md). Exact uncommitted identity, source archive, preservation and native-operation evidence are under `encounter/evidence/r2/`. Live checkout is `main` at `837bd4a8d33ec01fe48dec83bd16fedb9dfaaff1`; prior documents named an older branch and current authority was corrected without switching branches. No commit, push or publication. Owner R2 feedback is **“build on.”** Automated and agent findings remain separate from that bounded owner acceptance.
