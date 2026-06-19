# Work Packet: Store Shell, Counter, And Backroom Kit

Status: Visually rejected as baseline
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/visual-bible/01-store-shell-architecture.md`
Dependencies: `docs/visual-bible/05-counter-register-and-trade-in.md`, `docs/visual-bible/06-stockroom-receiving-office.md`, `docs/visual-bible/07-signage-marketing-and-store-identity.md`, `docs/visual-bible/09-mvp-object-implementation-checklist.md`
Expected commit scope: reusable shell/counter/backroom modules, material/detail improvements, module tests, and review notes

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/visual-bible/README.md`
4. `docs/visual-bible/01-store-shell-architecture.md`
5. `docs/visual-bible/05-counter-register-and-trade-in.md`
6. `docs/visual-bible/06-stockroom-receiving-office.md`
7. `docs/visual-bible/07-signage-marketing-and-store-identity.md`
8. `docs/visual-bible/09-mvp-object-implementation-checklist.md`

## Context

- Current problem: the store shell, counter, and backroom contain the right functional anchors but still expose flat/prototype geometry.
- Target player-facing result: the store reads as a clean mall retail shop with a real cash wrap, trade-in station, stockroom, receiving area, and office/storage support.
- Existing systems that must keep working: opening route, register, trade-in, receiving, backroom computer, customer queue, route clearance, and screenshot targets.
- Visual/design docs that define success: shell architecture, counter/trade-in, stockroom/receiving/office, signage/store identity.
- Known prior failures to avoid: large flat slabs, cluttered random walls, label-dependent function, fake back half-wall, receiving visible as loose labeled blocks.

## In Scope

- Drywall/carpet/quiet ceiling details.
- Storefront/threshold/module details.
- Counter POS/scanner/cash drawer/bags/trade-in tray detail.
- Stockroom receiving table, storage racks, setup boxes, office desk/computer/calendar cues.
- Reusable module assets or bounded module scene improvements.
- Module/scene-load tests.

## Out Of Scope

- Product case art internals.
- Shelf-slot/fixture internals.
- Full playable-store integration after product/fixture workers finish.
- Customer/employee/broad decoration work.

## Acceptance Checklist

- [x] Shell/counter/backroom modules read as authored retail objects, not raw geometry.
- [x] Routes and core interactions remain clear.
- [x] Counter and receiving read from object design before labels.
- [x] Stockroom reads as office + storage.
- [x] Focused scene/module tests pass.
- [x] Full validation runs before completion if game assets/scenes changed.

## Implementation Evidence

- Added retail material resources for low-pile carpet and soft drywall panels.
- Added/updated shell and storefront kit scenes: `store_shell_finish_kit.tscn`, `storefront_facade_bay.tscn`, and `storefront_glass_door_open.tscn`.
- Added/updated counter, receiving, and backroom kit scenes: `register_counter_kit.tscn`, `receiving_intake_kit.tscn`, and `backroom_staff_threshold_kit.tscn`.
- Wired the approved art-kit route into `res://scenes/world/store_world.tscn` and the benchmark scene.
- Updated world module manifests and art-language tests.
- Review screenshots:
  - `artifacts/validation/latest/screenshots/storefront_entry.png`
  - `artifacts/validation/latest/screenshots/register_counter.png`
  - `artifacts/validation/latest/screenshots/receiving_area.png`
  - `artifacts/validation/latest/screenshots/stockroom_doorway.png`

## Validation

Latest full gate:

```text
scripts/validate_godot.sh
```

Result: passed with 592 GUT tests, 12273 asserts, desktop pack smoke, performance smoke, screenshot sanity, contact sheet generation, and old-name scan.

Owner visual signoff failed. This shell/counter/backroom work is regression/mechanics context only and must not be treated as the accepted visual baseline.

Future shell, counter, and backroom art must be proven through the hero art slice before broad integration.

## Stop Conditions

- Module work requires broad edits to `store_world.tscn` before product/fixture agents are integrated.
- Visual improvement risks breaking register, receiving, or backroom mechanics.
- The shell still reads like flat graybox after detail pass.
