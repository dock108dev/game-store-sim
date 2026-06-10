# Tech Stack And Architecture

## Current Stack

Engine: Godot 4.6.3 stable target.

Validation currently runs successfully with `/Applications/Godot.app` at `4.6.2.stable.official.71f334935`. Keep the target on 4.6.3, but do not churn project metadata solely to chase the target version.

Primary language: GDScript.

Primary platform: desktop keyboard/mouse.

Current input model: center-reticle targeting with left click as the primary interaction. The `interact` input action remains as a compatibility path, but prompts and manual validation should describe click-first play.

## Current Project Shape

```text
game/
  project.godot
  scenes/
    world/
    player/
    ui/
    customers/
    props/
  scripts/
    interaction/
    inventory/
    economy/
    customers/
    store_layout/
    save/
    systems/
    suppliers/
    releases/
    ui/
    narrative/
  data/
    products/
    fixtures/
    suppliers/
    releases/
  tests/
    gut/
    tools/
    validation/
```

## Current Runtime Surface

Implemented and validated:

- First-person player controller.
- Click-first interaction raycast, prompt, and reticle.
- Product-backed item instances.
- Receiving-box pickup, bounded carry stack, held-item pricing, and shelf stocking.
- Used-game pricing with apply-to-matching.
- Buyer customer manager, product selection, price tolerance, movement, and register queue.
- Register sale, trade-in, preorder deposit, and service flows.
- Transaction ledger and store-session accounting.
- Backroom computer summary, daily report, recent activity, inventory, reorder suggestions, demand, market drift, supplier ordering, release calendar, allocation commitments, launch outcomes, and fixture controls.
- Fixture order, ghost preview, valid/invalid material state, movement, rotation, snap, and placement confirmation.
- Supplier order delivery into receiving.
- New-release calendar, preorder deposit, allocation, launch fulfillment, and reputation consequence.
- Hidden-thread infrastructure: event log, suspicious supplier note, mismatched serial item, optional suspicious customer, and evidence storage.
- Codec-level save/load smoke tests.
- Named screenshot validation and scenario coverage gates.

## Architecture Principles

Data first:

- Products, fixtures, supplier lots, releases, and future customer archetypes should be authored as data.
- Code should interpret reusable systems, not hard-code each content case.

Interaction first:

- World objects expose prompts and action methods through the interaction contract.
- Prompt text should describe the current click-first action.
- Workstation panels should be opened from world objects and close cleanly back into first-person mouse capture.

Simulation in layers:

- Inventory state lives on item instances and is summarized through store session queries.
- Economy policy calculates demand, price tolerance, market drift, revenue, cost, and profit.
- Customer systems decide goals and movement, then hand transactions to register/session systems.
- Store layout owns fixture placement, shelf slots, ghost previews, and path/spacing validation.
- Narrative systems observe suspicious triggers without owning the normal retail loop.

Backroom owns management:

- Ordering, inventory summaries, reports, fixture placement, release planning, and future management tools belong on the backroom computer.
- The register stays focused on sales, returns, trade-ins, preorders, and services.
- Pricing belongs to held-item/item inspection workflows, not a standalone pricing terminal.

## Validation Architecture

The mandatory local gate is:

```text
scripts/validate_godot.sh
```

The gate runs whitespace checks, Godot load/smoke checks, GUT, validation coverage policy, product catalog checks, persistence smoke tests, named screenshot capture, screenshot sanity checks, and old-name scans.

Scenario manifests live under `game/tests/validation/scenarios/`.

Script mapping lives at `game/tests/validation/script_coverage/production_scripts.json`.

Manual-only checks are tracked in `game/tests/validation/scenarios/manual_checks.json` and mirrored in `docs/production/07-current-manual-playtest.md`.

## Current Technical Risks

- UI density: the backroom computer is now useful but crowded. The next phase must improve information architecture, grouping, and visual hierarchy.
- Visual identity: graybox props prove the loop but do not yet communicate a compelling game store, backroom, or customer cast.
- Customer readability: customer roles are mechanically distinct but need stronger silhouettes, placement, and interaction presentation.
- Backroom identity: receiving, storage, management, repairs, paperwork, and hidden-thread cues need a coherent spatial pass.
- Fixture placement UX: panel controls work, but the final presentation needs clearer placement language, stronger affordances, and better visual composition.
- Manual validation load: the checklist is intentionally broad; future slices should keep it current while using automated screenshot coverage to catch regressions.
