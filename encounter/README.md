# Replay Junction — R4 customer wave

Owner R3 feedback **“build on.”** accepts the bounded pricing slice and authorizes R4. R4 owner acceptance remains pending. Existing animation limits remain.

## Play

Double-click **Launch Encounter.command**, or run:

```sh
'/Users/michaelfuscoletti/Desktop/game-sim/encounter/Launch Encounter.command'
```

Receive three prepaid copies → choose price → print labels → stock → open → watch three visitors browse → serve the numbered checkout queue → close admission → finish existing customers → finalize the day report.

At the report, optionally order 1–6 copies at $8 each within available cash, advance, receive once, price and stock. Unsold copies retain their prices. During prep, **Apply price to unsold stock** relabels both shelf and backroom copies. Printing labels affects backroom copies only. Editing the field alone changes no stock. Prices are $1.00–$99.99; below $8 creates a per-copy loss.

Click controls/stations; WASD/arrows walk; E performs the guided action; K saves; L reloads. **Close admission** cancels unarrived visitors, while existing visitors can still buy. **Finalize day report** appears only after the floor and queue clear; it locks sales. Closing does not forcibly dismiss valid queued buyers.

## Reproducible wave

Alex, Blair and Casey arrive at 0, 5 and 10 simulation seconds, subject to a clear doorway. Their day-1 budgets are $24.18, $17.59 and $30.78. With three copies available, $16.99 sells to all three, $21.99 produces two purchases and one price refusal, and $26.99 sells only to Casey. **Compare Pricing.command** starts separately saved low/reference/high wave demonstrations. These are three-person R4 comparisons; the historical R3 five-visitor comparison remains in the R3 delivery evidence.

Each visitor reserves a distinct free copy, locks its offer, and either buys or releases it. A visitor who finds no free copy records a stock miss rather than a price miss. The same visitor does not retry or reroll. Names and queue numbers identify the people you serve; only the settled queue head can pay. Budgets follow the existing five-entry daily cycle with fixed per-person offsets, without randomness or wall-clock inputs.

Daily reports show sales, price misses, stock misses, revenue, sold-copy cost, gross profit, unsold copies and cash. Gross profit excludes overhead. Orders reduce cash once; their cost enters profit only when copies sell. Daily counters reset on advance; physical copies, cash and cumulative ledgers persist.

## Save and reload

R4 uses `~/Library/Application Support/game-sim-r4-review-isolated/encounter.json`. R1–R3 saves remain untouched. Launch starts fresh; **Reload** restores your last explicit **Save** checkpoint. New practice shift confirms discarding unsaved progress and preserves the saved checkpoint.

Schema 4 stores identities, individual budgets, arrival states and clock, browse progress, customer positions, decisions, copy ownership, locked offers, queue order, phase and accounting. Reload resumes those saved states without generating another roster or repeating a recorded arrival/decision. Replaying from a deliberately earlier saved checkpoint naturally replays later unsaved events. Animation poses and the player's route are not persisted; active-shift reload places Rowan at the cashier station. No earlier-schema migration is attempted.

## Evidence and reproduction

```sh
cd '/Users/michaelfuscoletti/Desktop/game-sim/encounter'
python3 scripts/validate.py --render --capture
```

The runner imports a disposable copy with a unique save namespace. R4 state and scene suites carry forward applicable R1–R3 invariants and explicitly replace the obsolete single-visitor/immediate-close assumptions. Normal 1280×720 and Retina 2560×1440 operation are recorded separately. Scene tests use 3× simulation time; the gameplay movie runs at ordinary speed using the actual engine and an action adapter. It is agent-generated footage, not owner input.

See [R4 delivery](../docs/03-production/r4-delivery.md) and `evidence/r4/` for qualification, exact identity, preservation and handoff. Historical tests, samples and evidence are retained.

## Art workflow

Retail-v4 directional cutouts, context and pivots are copied unchanged into `art/`. Their editable masters and production recipe remain in `../samples/b-retail-v4/source/masters/` and `../samples/b-retail-v4/scripts/Rebuild Art.command`. Both standalone samples and the historical game are preserved.

New layered masters: `source/counter.kra`, `case.kra`, `shipment.kra`, and `retail-shelf-empty.kra`. The latter derives from the retained shelf master by hiding its decorative case layer; the physical cases are separate runtime sprites. Rebuild using `scripts/Rebuild Art.command`; `scripts/build_art.py` is the deterministic native Krita recipe. It saves and reopens every new master, exports PNG, and verifies identical bytes. Run in a disposable copy when retaining prior build logs is important.

PNG: sRGB, straight RGBA, lossless Godot import, linear filtering, mipmaps off, alpha-border correction on; committed-style `.import` sidecars are retained as uncommitted files. Source assets are authored at 4× logical size. Environment props display at .25; case display is .17 on shelf and .085 in hand. Shelf root (640,390), image offset (-125,-115); counter root (785,540), offset (-100,-110); shipment root (310,455), offset (-39,-62). Character feet and limb pivots are in `art/rig.json`, scaled to 110 logical pixels high. `actor.gd` adapts the existing directional rig/pose implementation to separate actors. The old authored-frame comparison remains only in the preserved samples.

Known limits: rigid/deforming legs, abrupt turns/stops, straight-arm reach, possible foot sliding, mirrored lighting and enlarged outline/hidden-surface artifacts. Three named visitors reuse Rowan's rig with restrained warm, cool and olive tints; independent character artwork remains deferred. Hands do not animate a detailed cash/register exchange. Shelf/case lettering is decorative; essential price/stock text is 18+ logical pixels and report text is 16 logical pixels (world labels 16–17). Krita emits retained Fontconfig/profile/swap/tile warnings; successful reopened exports establish the bounded production result, not warning-free Krita operation.
