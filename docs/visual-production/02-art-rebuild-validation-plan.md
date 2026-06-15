# Art Rebuild Validation Plan

## Purpose

This document defines how the art-language rebuild will be validated. Automated tests can prove that nodes exist, screenshots render, and interactions still work. They cannot prove the scene looks good. Owner screenshot review remains the approval gate.

## Active Question

Does the opening route read like a simple mid-00s independent game shop, or does it still read like a collection of cubes with labels?

The pass fails if the answer is still "cubes."

## Required Evidence

Every implementation slice should produce one of these evidence types:

- focused GUT test output for changed scene/test contracts
- full `scripts/validate_godot.sh` output for production-route integration
- updated `artifacts/validation/latest/screenshot-contact-sheet.png`
- direct screenshot review of the sandbox art benchmark
- manual 1280x720 real-window walk-in notes

## Screenshot Targets

Primary approval set:

- `main_scene.png`: storefront/concourse first read
- `storefront_entry.png`: walk-in threshold and interior hint
- `register_counter.png`: counter plus first fixture family
- `receiving_area.png`: receiving as staged workflow
- `backroom_summary.png`: staff-only architecture and backroom depth

Secondary regression set:

- `stocked_aisle.png`
- `carry_stack.png`
- `catalog_design_cues.png`
- `fixture_placed.png`
- `fixture_ghost.png`
- `fixture_invalid_ghost.png`
- `fixture_rotated_ghost.png`

## Sandbox Review

Before production integration, capture the sandbox benchmark:

- `game/scenes/world/art_benchmark/game_shop_art_benchmark.tscn`

Minimum sandbox views:

1. storefront facade from mall concourse
2. glass threshold and interior hint
3. register plus wall shelf/product kit

Pass criteria:

- no large explanatory labels
- storefront reads through architecture and material contrast
- register reads through silhouette and equipment grouping
- shelves/products read through shapes, rows, colors, and decals
- lighting creates a warm retail interior against a cooler concourse/backroom
- no random cube piles

Fail criteria:

- primary objects are still raw boxes
- the scene needs labels to explain itself
- flat gray planes dominate the frame
- detail is either absent or noisy
- the kit cannot be reused in `store_world.tscn`

## Production Review

After kit integration, run:

```text
scripts/validate_godot.sh
```

Then review:

```text
artifacts/validation/latest/screenshot-contact-sheet.png
```

Manual walk-in review:

1. Stop any running Godot debug instance.
2. Reload saved scene or reopen the project if the editor appears stale.
3. Launch the game in a normal 1280x720 window.
4. Start on the mall concourse.
5. Walk toward the storefront.
6. Enter through the door/threshold.
7. Stop at the register/first fixture read.
8. Look toward receiving and the backroom threshold.

Record:

- first object read from each view
- whether the shop reads before text
- any object that still looks like debug geometry
- any text that is carrying too much meaning
- any route or interaction obstruction

## Automated Tests To Add

Documentation/status:

- active phase is `art_language_rebuild_ready_for_implementation`
- active docs include the three art rebuild docs
- current state points to the new plan

Sandbox:

- art benchmark scene loads
- required kit roots exist
- sandbox camera anchors exist

Production scene:

- production scene instances approved kit modules
- storefront kit exists in opening route
- register kit exists in first interior route
- wall shelf/product kit exists in first interior route
- receiving kit exists in receiving screenshot route
- backroom threshold kit exists and has depth

Visual constraints:

- no oversized explanatory benchmark labels are visible
- old hard-benchmark visible cube nodes are hidden or removed from primary route
- visible day-one physical product count remains restrained
- future products remain catalog/planning only until unlocked/received

Interaction constraints:

- mall spawn to storefront route remains walkable
- threshold route remains walkable
- register remains interactable
- receiving box/items remain interactable
- backroom computer remains interactable
- fixture placement still works

## Acceptance Checklist

The rebuild is ready for owner signoff only when:

- full validation passes
- sandbox benchmark screenshots pass internal review
- production contact sheet exists
- five primary production screenshots pass the visual checklist
- real-window walk-in does not expose stale/cube-heavy angles
- docs/status/backlog/bug list identify the pass as ready for owner review
- no new mechanics regressions are open

## Owner Signoff Options

Approve:

- use the approved art kit as the baseline
- proceed to broader product/fixture visual-kit breadth
- start replacing the rest of the store with the same module language

Approve with corrections:

- list screenshot-specific corrections
- keep work inside the same art-kit route
- do not expand catalog/customer/decorations yet

Reject:

- identify whether the failure is shape language, materials, composition, lighting, or asset pipeline
- return to sandbox kit work
- do not keep adding CSG detail to the production scene

## Validation Cadence

Use this cadence:

- docs/status route change: focused docs GUT test
- sandbox scene creation: focused scene-load GUT test
- each kit integration: focused scene/interaction GUT tests
- production route replacement: full `scripts/validate_godot.sh`
- owner handoff: full `scripts/validate_godot.sh` plus contact sheet

## Known Limits

Automated screenshots verify nonblank output and composition coverage, not aesthetic quality. The final question is still human:

Does it look like a real simple game shop, or like a pile of cubes?
