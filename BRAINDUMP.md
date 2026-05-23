# BRAINDUMP: Getting Shelf Life Out Of Beta

Date: 2026-05-23

This is a reset note for how to tackle the project from here. The problem is
not that the repo lacks code. The problem is that we keep improving isolated
surfaces without forcing them to become a player-visible loop.

The current north star should be:

```text
Every build task must prove code-to-screen progress.
```

That means a change is not "done" because a system changed, a test passed, or a
prop appeared. It is done when we can point to:

1. The screen object the player sees.
2. The prompt or affordance the player uses.
3. The script that owns the input.
4. The durable state mutation.
5. The visible feedback.
6. The next enabled action.
7. The test or capture proving the same beat.

The current detailed audit lives at:

- `docs/audits/beta-code-to-screen-readiness.md`

Use that as the baseline, not another vague "visual pass" request.

## Current Diagnosis

The latest runtime log reached:

```text
AUDIT: PASS day1_playable_ready store_id=retro_games
```

That is meaningful. Boot, scene routing, active store, player spawn, camera,
input focus, a stockable shelf, backroom inventory, and an active objective are
now wired enough for entry.

But entry readiness is not gameplay readiness.

The beta still reads as a walkable checklist because the player-facing spine is
unclear. The repo currently contains all of these at once:

- a first-person store space
- a scripted opening checklist
- modal customer decision cards
- inventory effect code
- production-ish customer, queue, checkout, reporting, and day-summary systems
- HUD surfaces and audit systems

Those are not bad pieces. They are just not yet one obvious game grammar.

## Core Decision

Choose the primary spine:

```text
Retail sim loop first.
Narrative decision cards second.
```

That means the main game should be:

```text
stock shelf -> customer need -> register decision -> visible consequence
-> update shelf/cash/reputation -> close day / reorder / improve store
```

Decision cards can still exist, but they should support physical retail play.
They should not be the whole game while the 3D store is just a waiting room.

Why this direction:

- The repo already has a first-person store, interactables, shelf slots,
  inventory, queue, checkout, and HUD counter systems.
- The user's frustration is specifically "code to screen." A retail loop makes
  code-to-screen validation natural because every system has an object in the
  room.
- A pure narrative-decision game would require a different presentation layer:
  stronger writing, portraits, scenes, pacing, and consequence visualization.
  That is a valid game, but it is not what the current 3D store is best set up
  to become quickly.

## Stop Doing

Stop treating these as progress:

- Adding more decorative props without changing the playable loop.
- Adding checklist items that complete on one key press and only update text.
- Writing systems that mutate state but do not produce a visible room change.
- Fixing screenshots one camera angle at a time without a route/capture plan.
- Calling a test pass "gameplay ready" when the test never drove the player
  from one screen beat to the next.

## What Is Already Useful

Keep and build on these pieces:

- `docs/audits/beta-code-to-screen-readiness.md`
  - Defines the current code-to-screen audit model.
- `docs/architecture/ownership.md`
  - Defines ownership boundaries: scene routing, store readiness, input focus,
    camera authority, GameState, HUD surfaces, EventBus, AuditLog.
- `docs/testing.md`
  - Defines the main validation path and CI expectations.
- `game/autoload/day1_readiness_audit.gd`
  - Entry readiness audit. Good for "can the store be played at all?"
- `game/autoload/store_director.gd`
  - Store lifecycle owner. Should be the readiness source, not individual
    gameplay scripts.
- `game/scripts/beta/beta_day_one_controller.gd`
  - Current Day 1 beta spine owner.
- `game/scripts/beta/beta_day1_customer_interactable.gd`
  - Customer prompt/input bridge.
- `game/scripts/beta/beta_backroom_pickup_interactable.gd`
  - Backroom prompt/input bridge.
- `game/scripts/beta/beta_restock_interactable.gd`
  - Shelf stock prompt/input bridge.
- `game/content/beta/days/day_01.json`
  - Day 1 structure.
- `game/content/beta/events/customer_events.json`
  - Customer decision content.
- `tests/gut/test_beta_preopening_training.gd`
  - Opening training progression coverage.
- `tests/gut/test_beta_day_one_critical_path.gd`
  - Day 1 physical route, target alignment, gating, and critical-path tests.
- `tests/gut/test_day1_readiness_audit.gd`
  - Store entry readiness invariants.
- `tests/unit/test_store_director.gd`
  - StoreDirector lifecycle coverage.

## The Next Real Milestone

Build and prove one complete Day 1 vertical loop:

```text
New Game
-> manager
-> register
-> back room
-> stock shelf
-> customer choice
-> result acknowledgement
-> visible customer exit
-> shelf/register/HUD stats change
-> close day
-> summary values match what happened
```

This should be one pass through the actual game. Not a unit test only. Not a
manual screenshot only. Both:

- one automated critical-path test
- one manual capture checklist

The capture checklist should be saved as an audit artifact or referenced in a
follow-up doc. If a future change cannot survive this route, it is not moving
the beta forward.

## Milestone 1: Prove The Existing Loop

Goal: do not add new gameplay yet. Prove what exists end-to-end.

Tasks:

1. Extend `tests/gut/test_beta_day_one_critical_path.gd` or add a focused
   companion test that drives:
   - preopening complete
   - first customer interaction
   - decision card choice
   - result acknowledgement
   - customer objective complete
   - backroom pickup
   - shelf stock
   - close day request
   - summary payload values
2. Add assertions that the screen-facing effects happened:
   - customer proxy hidden/exiting or exit state set
   - shelf visible item count changed
   - `EventBus.item_sold` and `EventBus.customer_purchased` emitted for sale
   - `beta_shelf_count_changed` emitted with the expected value
   - right panel stats changed
   - summary contains sales, rent, profit, inventory remaining, customers helped
3. Run a manual playthrough and record the exact route:
   - screenshot before customer
   - screenshot decision card
   - screenshot after result
   - screenshot stocked shelf / stat change
   - screenshot summary

Acceptance:

```text
The test proves the state route.
The capture proves the screen route.
The two routes describe the same player experience.
```

## Milestone 2: Make The Register A Real Screen Beat

Current issue: the register check is wired but thin. It grants access and shows
a toast, but the room does not change enough.

Build:

- Add a small register screen state under the checkout counter.
- During opening training, the register should visibly change from inactive to
  ready.
- During a customer sale, it should show the transaction amount or simple
  receipt state.
- After sale/no-sale, it should visibly clear or settle.

Likely files:

- `game/scenes/stores/retro_games.tscn`
- `game/scripts/beta/beta_day_one_controller.gd`
- possible new beta visual helper under `game/scripts/beta/`
- `tests/gut/test_beta_day_one_critical_path.gd`

Acceptance:

```text
Register check changes a visible register object, not only the checklist.
Customer choice changes the register again.
The critical-path test asserts the register state node changed.
```

## Milestone 3: Turn Stocking From Instant Text Into Physical Feedback

Current issue: stocking is better now because visible shelf items render, but
the action is still instant.

Do not build a full inventory UI yet. Build a small physical loop:

```text
pick up box -> carry marker visible -> shelf highlight -> stock -> shelf items appear
```

Build:

- Carry box or hand/reticle indicator while `BetaRunState.carrying_stock`.
- Shelf highlight while carrying stock.
- Shelf items visibly appear in a count matching the emitted shelf count.
- Empty overlay returns only when count is zero.

Likely files:

- `game/scripts/beta/beta_day_one_controller.gd`
- `game/scenes/stores/retro_games.tscn`
- `game/scripts/beta/beta_restock_interactable.gd`
- `tests/gut/test_beta_restock_shelf_visual_spec.gd`
- `tests/gut/test_beta_day_one_completion_metrics.gd`

Acceptance:

```text
The player can tell what they are carrying and where it goes without reading
the right panel.
```

## Milestone 4: Make The Customer Decision Spatial

Current issue: the customer event has content and effects, but the store may
still feel like a modal wrapper.

Build one spatial version of the Day 1 customer:

- Customer has a visible item/receipt at the counter.
- Decision card choices map to visible outcomes:
  - clean exchange: one item leaves shelf/register, one item moves to backroom
  - bundle: game plus controller leaves shelf/register
  - refuse: no sale, customer exits upset, stats reflect no sale
- The result panel should be a short acknowledgement, not the only source of
  consequence.

Likely files:

- `game/content/beta/events/customer_events.json`
- `game/scripts/beta/beta_customer_inventory_effects.gd`
- `game/scripts/beta/beta_day_one_controller.gd`
- `game/scripts/beta/beta_day1_customer_interactable.gd`
- `tests/gut/test_beta_day_one_critical_path.gd`

Acceptance:

```text
After each choice, the room and HUD make the outcome legible before opening
the summary.
```

## Milestone 5: Repeat The Loop Once

Only after the single loop is proven, add a second customer or repeatable day
event. This is the point where the beta starts feeling like a game instead of
a tutorial.

Build:

```text
Customer 1 -> sale/no-sale -> shelf count changes
Customer 2 -> reacts to remaining stock -> sale/no-sale
Close day -> summary compares both outcomes
```

Likely files:

- `game/content/beta/days/day_01.json`
- `game/content/beta/events/customer_events.json`
- `game/scripts/beta/beta_day_one_controller.gd`
- queue/customer systems only if needed

Acceptance:

```text
The second customer is affected by the result of the first customer.
```

That is the first moment this becomes a system instead of a scripted demo.

## Audit Rules For Future Work

Every future task should include this section in its PR/notes:

```text
Code-to-screen proof:
- Screen object:
- Input affordance:
- Code owner:
- State mutation:
- Screen feedback:
- Next beat:
- Test/capture:
```

If a task cannot fill those fields, it is probably not the right next task.

## Validation Commands

Focused code-to-screen gate:

```bash
godot --path . --headless --script res://addons/gut/gut_cmdln.gd -- \
  -gconfig= \
  -gtest=res://tests/gut/test_beta_preopening_training.gd \
  -gtest=res://tests/gut/test_beta_day_one_critical_path.gd \
  -gtest=res://tests/gut/test_day1_readiness_audit.gd \
  -gtest=res://tests/unit/test_store_director.gd \
  -gpre_run_script=res://tests/gut_pre_run.gd \
  -gexit
```

Full project gate:

```bash
bash tests/run_tests.sh
```

Hygiene:

```bash
gdlint <changed .gd files>
git diff --check
```

Known note: Godot/GUT can print renderer RID/orphan warnings after a green
summary in this repo. Treat the final GUT summary and exit code as the primary
signal unless a new `push_error()` or assertion failure appears.

## Working Rule

Do not ask "what can we tweak next?"

Ask:

```text
What exact player action becomes more playable, more visible, or more
consequential after this change?
```

If the answer is unclear, the task is probably polish, not progress.

