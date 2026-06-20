# Visual Production Ready Graphics Checklist

This checklist turns the current docs and `docs/game_store_sim_300_object_asset_inventory.xlsx` into a production gate for the first 0.3% visual benchmark.

The target is not a complete art library. The target is one believable early-2000s mall game shop environment that can pass the required benchmark screenshots.

## Source Of Truth

Use these sources in order:

1. `docs/MASTER_PLAN.md`
2. `docs/06-decisions/0004-visual-first-gate.md`
3. `docs/01-design/visual-benchmark-first-0.3.md`
4. `docs/01-design/art-direction.md`
5. `docs/03-production/visual-first-task-list.md`
6. `docs/game_store_sim_300_object_asset_inventory.xlsx`
7. `game-guide/` for long-range canon and future asset parking

## Production Rule

- [ ] Do not add broad gameplay systems to compensate for weak visuals.
- [ ] Do not treat the engine proof scene as production art.
- [ ] Do not build all 300 inventory rows before the benchmark passes.
- [ ] Do build the smallest asset set that makes the nine required screenshots look like a real game.
- [ ] Do keep every brand, platform, product, poster, box, and logo fictional.

## Blender Setup

- [ ] Blender launches locally.
- [ ] Source `.blend` files are saved for accepted first-party assets.
- [ ] Reusable generation scripts are saved when AI-assisted Blender Python is used.
- [ ] Accepted game-ready exports are `.glb`.
- [ ] Temporary Blender autosaves and throwaway renders are not treated as production assets.
- [ ] Every exported asset has an intentional origin, applied transforms, descriptive object names, and simple material names.
- [ ] Every imported asset is verified in Godot, not only in Blender.

## Minimum Asset Set Before Broad Expansion

- [ ] Mall concourse segment.
- [ ] Glass storefront and entrance threshold.
- [ ] Fictional storefront sign.
- [ ] Starter sales floor shell.
- [ ] Commercial floor material.
- [ ] Fluorescent ceiling lighting setup.
- [ ] Backroom/receiving space.
- [ ] Starter shipment box or box set.
- [ ] Invoice or manifest visual cue.
- [ ] Checkout counter.
- [ ] Register object.
- [ ] Retail-specific counter clutter.
- [ ] Wall shelf or rack.
- [ ] Freestanding shelf or gondola.
- [ ] Receiving table, pallet, or staging surface.
- [ ] At least ten physical fictional game cases that read together on a shelf.
- [ ] New/used visual distinction.
- [ ] Price sticker and shelf label language.
- [ ] Held-case first-person presentation.
- [ ] Simple customer body or staged silhouette.
- [ ] Backroom computer or report presentation surface.
- [ ] Daily report UI direction.

## Art Direction Gate

- [ ] The store reads as warm early-2000s mall retail.
- [ ] The space is understocked, not unfinished.
- [ ] Shelves, counter, cases, and player camera are at believable human scale.
- [ ] Products provide most of the color through fictional box art, stickers, and shelf rows.
- [ ] Fixtures provide structure and reusable display logic.
- [ ] Signage clarifies the store without explaining the game.
- [ ] Lighting is bright enough for retail clarity and warm enough for nostalgia.
- [ ] The palette is not dominated by one hue family.
- [ ] The scene avoids sterile showroom, photoreal brand-copy, parody, nostalgia museum, and unreadable clutter looks.

## Screenshot Sign-Off

Each required screenshot must be captured from a macOS build or from a matching validation scene path.

- [ ] `01-storefront-from-mall.png`: mall concourse, storefront glass, entrance, sign, warm light through glass.
- [ ] `02-empty-sales-floor.png`: starter floor, counter, shelves, empty capacity, receiving/backroom route.
- [ ] `03-receiving-backroom.png`: starter shipment, staging surface, backroom computer or office hint, operational clutter.
- [ ] `04-starter-shipment-open.png`: open shipment, multiple physical items, invoice/manifest cue, optional harmless odd detail.
- [ ] `05-picked-up-case.png`: held case/box view, readable fictional cover block, store context behind it.
- [ ] `06-stocked-shelf-density.png`: about ten physical game cases, price tags or shelf labels, believable one-to-one stock density.
- [ ] `07-counter-register.png`: register/counter, customer and staff side cues, counter clutter, sale-flow location.
- [ ] `08-customer-entering-from-mall.png`: customer crossing from mall into store, entrance context, credible body silhouette.
- [ ] `09-daily-report-view.png`: report UI or backroom computer report state, believable business-tool hierarchy.

Each screenshot verdict must be one of:

- [ ] `pass`: ready to build on.
- [ ] `revise`: direction is right but needs iteration.
- [ ] `fail`: does not match the game.
- [ ] `defer`: intentionally postponed with a written reason and no damage to the scaffold.

The visual benchmark is not signed off until all nine screenshots are `pass` or intentionally deferred without weakening the scaffold.

## Asset Spreadsheet Rules

- [ ] Treat `Priority=Must` and `MVP?=Yes` rows as the first review pool.
- [ ] Treat `Priority=High` rows as authenticity and density after the first pass reads correctly.
- [ ] Park `Low`, late-era, hidden narrative, expansion, and mature-store rows unless they directly support a required screenshot.
- [ ] Every asset row selected for production needs owner, status, complexity, target screenshot, source artifact, Godot import path, and review verdict.
- [ ] An asset is not done until it improves a target screenshot or is explicitly marked as support work.

## Godot Integration Gate

- [ ] Visual benchmark scene exists and launches.
- [ ] Scene includes mall concourse, storefront, sales floor, counter, backroom, starter shipment, shelves, physical items, and one customer staging point.
- [ ] Imported `.glb` files are referenced from stable paths.
- [ ] Materials render correctly in the Godot scene.
- [ ] Collision and interaction needs are documented or implemented.
- [ ] No script load, parse, missing resource, or runtime errors appear.
- [ ] The main repo entry point no longer implies placeholder art is the production baseline once the benchmark scene is ready.

## Validation Gate

- [ ] `scripts/validate_local.sh` passes.
- [ ] Screenshot sanity rejects missing, blank, wrong-size, or mostly-one-color captures.
- [ ] Visual benchmark screenshots are written under `artifacts/validation/latest/screenshots/visual-benchmark/`.
- [ ] `GSS_EXPORT_MACOS=1 scripts/validate_local.sh` passes before milestone sign-off.
- [ ] Manual visual review passes every required shot or records explicit deferrals.

## Cut Line

Cut or defer these until after visual sign-off unless they are needed to stage a required screenshot:

- [ ] trade-ins
- [ ] returns
- [ ] services
- [ ] supplier networks
- [ ] launch calendar
- [ ] employees
- [ ] neighboring-unit expansion
- [ ] rare inventory
- [ ] full secret web
- [ ] mature-store fixture families
- [ ] final character animation system
- [ ] final UI flows beyond benchmark presentation

## Final Production Ready Definition

The first visual production milestone is ready when:

- [ ] The nine benchmark screenshots are captured.
- [ ] The screenshots look like one coherent game world.
- [ ] Required MVP assets from the spreadsheet are either used, intentionally replaced, or explicitly deferred.
- [ ] Blender source and `.glb` exports exist for accepted physical assets.
- [ ] Godot integration is stable.
- [ ] Local and export-enabled validation pass.
- [ ] Human visual review says the first store can be built on.
