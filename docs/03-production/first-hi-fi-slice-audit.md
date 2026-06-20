# First Hi-Fi Slice Audit

Date: 2026-06-20

## Verdict

Do not batch-create the remaining asset inventory yet.

The repo is correctly pointed at a visual-first milestone, and the current Godot scene proves a coherent first asset pass exists. The next production move is a hi-fi pass on the smallest real slice:

1. opening/store setup
2. first customer/transaction staging
3. first meaningful decision presentation

The current benchmark should be treated as a blockout-quality visual scaffold, not a signed-off production art baseline.

## Evidence Reviewed

- `docs/MASTER_PLAN.md`
- `docs/06-decisions/0003-first-playable-scope.md`
- `docs/06-decisions/0004-visual-first-gate.md`
- `docs/01-design/vertical-slice-contract.md`
- `docs/01-design/visual-benchmark-first-0.3.md`
- `docs/01-design/art-direction.md`
- `docs/03-production/visual-first-task-list.md`
- `docs/03-production/visual-production-ready-graphics-checklist.md`
- `docs/04-validation/local-validation-plan.md`
- `docs/04-validation/manual-playtest-checklist.md`
- `docs/game_store_sim_300_object_asset_inventory.xlsx`
- `docs/game_store_sim_visual_production_ready_checklist.xlsx`
- `game/scenes/visual_benchmark/VisualBenchmarkStore.tscn`
- `game/scripts/tools/capture_visual_benchmark.gd`
- `scripts/validate_local.sh`
- `game/assets/visual_benchmark/visual_benchmark_asset_manifest.json`

## Validation Run

Command:

```bash
scripts/validate_local.sh
```

Result: pass.

Display-backed screenshot capture command:

```bash
cd game
GSS_VISUAL_BENCHMARK_SCREENSHOT_DIR=/Users/michaelfuscoletti/Desktop/game-store-sim/artifacts/validation/latest/screenshots/visual-benchmark \
  /Users/michaelfuscoletti/.local/bin/godot \
  --path /Users/michaelfuscoletti/Desktop/game-store-sim/game \
  --script res://scripts/tools/capture_visual_benchmark.gd
```

Result: all nine visual benchmark screenshots were captured at 1280x720.

Important gap: the same capture script failed under `--headless` because the dummy renderer returned a null viewport texture. The main local validation gate does not yet enforce the nine visual benchmark screenshots.

## Hi-Fi Pass 1 Implementation

Update: a focused hi-fi pass was implemented after this audit, without expanding into the 77-row Tier 1 asset pool.

Changed assets:

- `assets/blender/scripts/generate_visual_benchmark_store.py`
- `assets/blender/source/game_store_visual_benchmark_assets.blend`
- `assets/blender/exports/*.glb`
- `game/assets/visual_benchmark/*.glb`
- `game/assets/visual_benchmark/visual_benchmark_asset_manifest.json`
- `game/scripts/tools/capture_visual_benchmark.gd`

Scope stayed inside the existing benchmark packs:

- mall/store shell
- shelving
- counter/register
- receiving/backroom
- product cases
- signage/posters
- customer placeholder
- daily-report computer
- assembled full benchmark store

No broad inventory batch was created.

Specific improvements:

- storefront mullions, mall tile grout, neighboring lease hints, visible sign blocks, window decals
- ceiling grid, slatwall grooves, shelf lips, price rails, category strips, endcap cue
- colored fictional case spines, new/used sticker cues, held-case cover blocks
- shipment tape, labels, manifest cue, visible cases in the open box, odd-note cue
- register keypad, card reader, customer display, checkout sign, receipt/counter clutter
- customer shoulder/arm/shoe/hair/bag silhouette and threshold context
- daily-report screen hierarchy with title, sales, margin, restock, printout, keyboard/mouse details
- revised receiving and counter capture framing so the evidence shows the intended details

## Current Screenshot Review

Screenshot contact sheet:

`artifacts/validation/latest/screenshots/visual-benchmark/00-contact-sheet.png`

| Shot | Verdict | Notes |
| --- | --- | --- |
| `01-storefront-from-mall.png` | Pass for scaffold | Now reads as mall storefront with tile grid, glass, mullions, threshold, customer, and visible store identity. Still needs final art polish later. |
| `02-empty-sales-floor.png` | Pass for scaffold | Reads as understocked starter store with ceiling grid, slatwall, fixture hierarchy, category strips, and clear counter/shelf zones. |
| `03-receiving-backroom.png` | Revise | Improved framing and backroom objects are present, but this shot still needs stronger wall/receiving specificity and clearer open-box evidence from the wide angle. |
| `04-starter-shipment-open.png` | Pass for scaffold | Open shipment now has colored contents, label/tape cues, manifest/clipboard, and odd-detail direction. |
| `05-picked-up-case.png` | Pass for scaffold | Held case now has a clearer fictional cover block, sticker/price language, and hand framing while preserving store context. |
| `06-stocked-shelf-density.png` | Revise | Shelf density and used/new signage read better, but product variation should get one more pass before it becomes the long-term product grammar. |
| `07-counter-register.png` | Pass for scaffold | Counter now reads as checkout with sign, register, card reader, display, queue marker, and counter clutter. |
| `08-customer-entering-from-mall.png` | Pass for scaffold | Customer silhouette and mall-to-store threshold are readable. Still not final character art or animation. |
| `09-daily-report-view.png` | Revise | Report hierarchy is now visible, but the UI needs cleaner spacing and final business-tool layout before sign-off. |

Current state: the hi-fi pass is a successful benchmark iteration, not final visual sign-off. The remaining revise shots are receiving/backroom, shelf/product grammar, and daily report UI.

## Autonomous Reference Pass

Update: a second autonomous pass used `real_inspiration/` and `other_game_inspiration/` as extraction sources.

Reference rules applied:

- Dense retail shelves should come from repeated product faces, price ticks, category headers, and shelf rails.
- Mall identity should read through tile rhythm, glass, threshold, ceiling grid, and visible store signage.
- Game-store specificity should come from fictional platform sections, sale stickers, cover-color families, window posters, and counter clutter.
- Register/counter should read as a transaction point through display, sale price, card reader, customer-facing sign, receipt paper, and glass-case contents.
- Receiving should read as operational through box labels, tape, manifest/clipboard, sort board, visible case rows, and backstock staging.
- Daily report should read as a business screen with simple metrics, not a debug dump or decorative text wall.

Additional changes:

- Added two-sided product-cover construction so shelf cases show color from benchmark camera angles.
- Added repeated wall cover faces and yellow price ticks to make shelf density feel closer to real retail reference.
- Added platform/category chips, accessory pegboard language, and clearance/endcap cues.
- Added front-window decal/sign detail and mall tile/ceiling rhythm.
- Added glass counter display, memory-card-style contents, impulse rack, sale display, and counter paperwork.
- Added receiving tape gun, label roll, sort board, backstock shelf moved outside the report sightline, and clearer open-box contents.
- Simplified daily report text into separated metric rows.
- Adjusted capture framing where older cameras hid the intended evidence.

Final autonomous-stop verdict:

- `01-storefront-from-mall.png`: signoff candidate.
- `02-empty-sales-floor.png`: signoff candidate.
- `03-receiving-backroom.png`: signoff candidate.
- `04-starter-shipment-open.png`: signoff candidate.
- `05-picked-up-case.png`: signoff candidate.
- `06-stocked-shelf-density.png`: signoff candidate.
- `07-counter-register.png`: signoff candidate.
- `08-customer-entering-from-mall.png`: signoff candidate.
- `09-daily-report-view.png`: signoff candidate.

The benchmark is now at the point where additional iteration depends on human taste validation: whether this stylized-density direction is the desired game look. No local validation blocker remains.

## Smallest Real Hi-Fi Slice

The smallest useful production slice is not all 0.3% gameplay. It is the screenshot-driven version of the first store day:

1. Before opening: player stands in mall and understands the storefront.
2. Setup: player reads sparse sales floor, receiving/backroom, starter shipment, and stocked shelf density.
3. First handling decision: player sees one carried/inspectable case and understands new/used/price-sticker language.
4. First commerce moment: one customer enters, counter/register reads as the sale location, and the daily report has a believable business-tool direction.

This slice does not require final inventory systems, final customer AI, final animation, final soundscape, or all first-playable UI. It requires final-ish visual rules for the first player-visible loop.

## Asset Scope Audit

The asset inventory contains 300 rows. The visual workbook marks 77 rows as Tier 1 / Benchmark MVP candidates. That is still too many for the next pass.

Observed candidate concentration:

- 28 candidate rows for case and shelf density
- 21 candidate rows for storefront
- 10 candidate rows for empty sales floor
- 7 candidate rows for counter/register
- 6 candidate rows marked support/later
- 3 candidate rows for cross-shot signage/color
- 2 candidate rows for receiving/shipment

Production implication: Tier 1 is a review pool, not a build queue. The next pass should select only assets that improve one of the nine benchmark shots.

## Locked Asset Rules For Next Pass

Use these rules before creating any additional broad asset batches:

- Asset must map to one of the nine benchmark screenshots.
- Asset must improve the current screenshot read, not merely fill the spreadsheet.
- Asset must establish a reusable rule: scale, material, palette, fixture slot logic, product grammar, signage grammar, customer silhouette, or UI hierarchy.
- Asset must be fictional and legally clean.
- Asset must have a source artifact and `.glb` export if accepted as physical art.
- Asset is not done until it appears in Godot and improves the target screenshot.

## Next Hi-Fi Pass Work Order

1. Fix screenshot capture enforcement.
   - Add the visual benchmark capture to the validation path using a display-backed mode on macOS.
   - Keep nonblank/dimension sanity for all nine required images.
   - Do not rely on `--headless` for visual capture unless the renderer path is changed and verified.

2. Lock the nine-shot review board.
   - Use `artifacts/validation/latest/screenshots/visual-benchmark/` as the evidence folder.
   - Track pass/revise/fail/defer per screenshot.
   - Do not start broad asset generation until each shot has a written reason.

3. Run the hi-fi pass in this order.
   - Storefront and empty sales floor: they define the first read and scale.
   - Shelf density and carried case: they define product grammar.
   - Receiving/shipment: it defines the first setup action.
   - Counter/register and customer entry: they define the first sale moment.
   - Daily report: it defines the first business decision frame.

4. Reduce the Tier 1 asset list.
   - Create a smaller first-pass lock set from the 77 candidates.
   - Defer support/later rows unless they directly improve a shot.
   - Avoid building all platform/product variants before the product grammar is approved.

5. After visual sign-off, batch-create the rest.
   - Expand from locked product grammar.
   - Expand from locked fixture dimensions and materials.
   - Expand from locked signage and UI rules.
   - Then update the spreadsheet statuses and review verdicts.

## Immediate Cut Line

Do not work on:

- trade-ins
- returns
- services
- supplier networks
- launch calendar
- employees
- expansion
- rare inventory
- full secret web
- final customer animation system
- final soundscape
- all 300 asset rows
- all 77 Tier 1 candidate rows

## Production Decision

Proceed with the hi-fi pass for the initial benchmark slice.

The first minimal asset pass has done its job: it exposed a coherent shape and produced screenshots. The next risk is not missing asset quantity. The next risk is freezing weak visual rules into hundreds of downstream assets.
