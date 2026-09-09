# R4 — a small customer wave

2026-09-08 local / 2026-09-09 UTC. Implementation complete; qualification in progress. **R4 owner acceptance remains pending.**

## Owner authority and scope

Owner R3 feedback: **“build on.”** This is bounded acceptance of R3 meaningful pricing consequences and authorization for R4. R1/R2 acceptance remains. It does not accept R4, the complete game, animation quality or a release.

Retain Curb Circuit 02, current fixtures, pricing, paid replenishment, retail-v4 artwork and the editable Krita masters. R4 uses three visitors and three prepaid starter copies. No new catalog, shop expansion, reputation, promotions, employees or broad animation reconstruction. No commit, push or publication.

## Current phase contract

| Phase | Admission and transactions | Next boundary |
| --- | --- | --- |
| Prep | Receive, print labels, reprice unsold stock and stock copies. No sales or arrivals. Empty shelves may open once received stock is handled. | Open creates the fixed three-person roster once. |
| Open | Admit visitors at their due time when the entrance is clear. Existing visitors browse, exclusively reserve, decide and queue. Only the settled queue head may pay. | Close admission cancels only visitors who have not entered. |
| Closing | No new arrivals. Already admitted customers finish browsing, decisions, queuing and valid sales. Refusals and departures release reservations. | Finalize becomes available only after the queue and floor are clear. |
| Report | All sales, arrivals, reservations and queue writes are rejected. Daily totals are finalized. One paid replenishment order is allowed. | Advance once to next-day prep; retain physical stock, cash and cumulative ledgers. |

The old R1 D1 test's immediate-close prohibition is deliberately replaced by two explicit checks: valid sales during closing and rejected sales after report finalization. D2 exclusive reservation and D3 sold-reference clearing remain.

## Visitors, reservations and persistence

`visitor-1` Alex, `visitor-2` Blair and `visitor-3` Casey are stable identities scoped by day. Arrival times are 0, 5 and 10 simulation seconds after opening, delayed only if the entrance is occupied. Each gets a fixed willingness from the existing five-day schedule, offset by 0, 2 and 4 entries. Day 1 budgets are $24.18, $17.59 and $30.78. At $16.99 all three buy; at $21.99 Alex and Casey buy while Blair declines; at $26.99 only Casey buys. Availability can prevent a price decision. This is bounded authored demand, not a calibrated commercial forecast.

At a distinct browse position, a visitor reserves the oldest free physical copy after 1.5 seconds and decides after 4 seconds. Selection locks copy identity, offer and individual budget. Price refusal returns that copy; unavailable stock records a separate outcome with no offered copy. Decision replay cannot append duplicate records. FIFO order is stored explicitly. Checkout accepts only the first queued visitor after reaching the front position, checks ownership and the locked offer, clears references and records exactly one sale per copy/customer/day.

Schema 4 persists the entire roster, due times, arrival state, simulation clock, browse elapsed time, world position, offers, decisions, queue order, phase and ledgers. Save/Reload is an explicit checkpoint operation; reloading restores the saved point, including movement progress, rather than creating a fresh wave. Launch starts fresh and Reload restores the selected saved checkpoint. Animation poses and the player's walking route are not saved. R1–R3 namespaces remain untouched; no migration is attempted.

Warm, cool and muted olive runtime tints plus names distinguish the reused rig. No image or art source changed. Separate browse positions, spaced queue positions and occupied navigation cells separate customers. The queue pauses its advance while a departing customer leaves. The cashier's restored position is at the counter during an active shift, clear of waiting visitors. Player-controlled walking may still visually approach actors; this is not a broad crowd/physics reconstruction.

## Verification and evidence

Pending final qualification pointers. The executable R4 state and scene suites replace the obsolete single-visitor adapters in the validation runner. Historical R1–R3 tests and evidence remain preserved. R4 checks explicitly carry forward physical inventory/ownership, price bounds and inclusive budgets, locked offers, duplicate decisions/sales, malformed load rejection, paid orders, cash limits, unique receiving, daily reset and next-day persistence.

Failures are retained. The first scene run exposed a blocked departing buyer behind a horizontal queue. Waiting positions and departure sequencing were repaired. A report text spacing failure was repaired. Rendered early-close validation was changed to wait for the actual arrival event rather than assume it occurred after one frame. No functional check was suppressed.

## Limits and owner handoff

Inherited rigid/deforming legs, abrupt turns/stops, straight reach, possible foot sliding, mirrored lighting, enlargement artifacts, reused/tinted rig and no detailed cash handoff remain. Browsing uses the existing reach and pause. Floor routing and spaced waiting are bounded for three visitors. Decorative lettering on the carton, shelf and case is not authoritative; the shift desk is. No new artwork was needed, so all Krita sources and exports are retained byte-for-byte.

Owner should operate the running shift and provide their own assessment. Automated checks, agent visual assessment and gameplay recording do not confer owner acceptance.
