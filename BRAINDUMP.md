# Visual Overhaul Braindump

This is the working braindump for taking the retail sim visuals, graphics,
and moment-to-moment store functions to the next level. The `inspiration/`
folder is intentionally kept in-repo so future agents can keep referencing the
same visual target while implementing slices over time.

This document is not a pixel-copy brief. Treat the inspiration images as a
directional reference for readable first-person retail simulation: strong store
identity, practical build tools, visible stock economics, tactile checkout
work, customers with readable intent, and a room that feels operated instead
of merely assembled.

## Current Post-Audit Read

The repo already has the foundations needed for a strong visual pass:

- First-person store player, reticle interaction, hover highlight, and prompt
  surfaces are documented in `docs/architecture.md`.
- Store visuals are centralized through `StoreVisualKit`,
  `StoreVisualLayout`, `StoreLayoutRuntime`, and
  `ExpandableStoreShellRuntime`.
- Product cases, cartridges, console boxes, and price tags are created through
  `ProductVisualFactory` and `ProductVisualCaseBuilder`.
- Day-1 store-session flow already has concrete stages: talk to manager, check
  register, inspect back room, pick up stock, stock shelf, handle customer,
  close day.
- Build mode already has fixture placement, rotation, validation, prices,
  ghost preview, overlays, and fixture catalog scaffolding.
- Store customization already has featured displays and posters with gameplay
  effects, but the choices need stronger physical expression in the scene.
- The visual sweep exists and should remain the acceptance surface for route
  readability: `scripts/run_store_visual_sweep.sh`.

The gap is not "we need a new game architecture." The gap is that the current
route still reads like an early prototype compared with the inspiration set:
large blank walls, low fixture density, muted signage, sparse shelf economics,
limited exterior identity, and work surfaces that are functional but not yet
tactile.

## Inspiration Folder Contract

Reference directory:

```text
inspiration/
```

The folder currently contains 42 screenshots:

```text
IMG_1033.PNG through IMG_1074.PNG
```

Future agents should use these as a living reference board. When a visual or
functional slice is implemented, add a short note to the relevant implementation
doc or audit describing which reference cluster was used and how it was adapted
to Mallcore Sim.

Do not import, trace, or clone proprietary UI/art. Use these references to
extract patterns:

- where the camera stands
- how much stock density is visible
- how tools communicate valid placement
- how store identity appears in the first viewport
- how shelf products, prices, register screens, and customers communicate state
- how build/design actions are grouped
- how busy retail spaces avoid becoming unreadable

## Reference Clusters

### Storefront And Mall Identity

Reference files:

```text
IMG_1033.PNG
IMG_1034.PNG
IMG_1035.PNG
IMG_1037.PNG
IMG_1038.PNG
IMG_1048.PNG
```

What these imply:

- The store should have a readable exterior or threshold identity before the
  player is deep inside the loop.
- Glass frontage, signage, mall paving, window displays, benches, planters,
  posters, and neighboring storefronts help the shop feel anchored.
- The store name should be visible as a physical sign, not only as HUD text.
- The first view should communicate "small used-game shop in a mall" in a few
  seconds.

Mallcore adaptation:

- Add front glass, a sign canopy, store-hours plaque, window decals, and a
  visible entry threshold to the current hub-mode store entry.
- Keep the default flow fast. The player can still spawn inside the starter
  store, but spawn should include a view back toward the entrance and branded
  threshold.
- Later, if walkable mall mode becomes productized, reuse the same storefront
  identity kit.

### Store Construction And Expansion

Reference files:

```text
IMG_1040.PNG
IMG_1041.PNG
IMG_1042.PNG
IMG_1043.PNG
IMG_1044.PNG
IMG_1045.PNG
IMG_1046.PNG
IMG_1047.PNG
IMG_1050.PNG
IMG_1051.PNG
```

What these imply:

- Build/design tools need strong visual mode states.
- Ghost placement should show footprint, collision, material, and facing.
- Catalogs need locked/unlocked cards, prices, thumbnails, and categories.
- Room customization should cover fixtures, floor, wall, paint, signage,
  posters, counters, shelves, and decorative clutter.
- Expansion should feel spatial: bigger room, wider aisles, more display
  surfaces, stockroom upgrade, queue capacity, and better customer flow.

Mallcore adaptation:

- Extend build mode from "place fixture" to "design the store."
- Use tabs or category buttons for Fixtures, Surfaces, Signage, Decor,
  Register, Stockroom, Lighting.
- Every build action should have an in-world result and a gameplay reason:
  shelf capacity, browse time, queue capacity, theft visibility, rare item
  trust, employee efficiency, or demand shaping.
- Preserve physical contracts. Every major prop needs a named zone, size,
  facing, and no-overlap constraints.

### Shelf Economics And Product Readability

Reference files:

```text
IMG_1052.PNG
IMG_1053.PNG
IMG_1054.PNG
IMG_1055.PNG
IMG_1056.PNG
IMG_1057.PNG
IMG_1063.PNG
IMG_1068.PNG
IMG_1069.PNG
IMG_1070.PNG
IMG_1071.PNG
IMG_1074.PNG
```

What these imply:

- Products should not read as generic boxes.
- The player should see shelf fullness, empty gaps, price tags, featured stock,
  and high-value items at a glance.
- Product shapes matter: boxed cases, loose cartridges, consoles, controllers,
  manuals, card packs, sleeves, binders, trade-in piles.
- Pricing is part of the fantasy. Even if the real system is simple, the store
  should visually expose price tags and value decisions.

Mallcore adaptation:

- Add richer product templates to `retro_games_product_visual_catalog.json`.
- Add visible price tags to each stocked product state, not only optional
  decorative tags.
- Add shelf gap markers when stock is sold, held, or missing.
- Add category labels: Used Games, Consoles, Accessories, Guides, Trade-Ins,
  Holds, Staff Picks.
- Add "featured display" physical states driven by `StoreCustomizationSystem`.
- Add visible rarity/condition tells that are not just color: stickers, case
  sleeves, tag shapes, shelf position, protective case.

### Checkout, Register, And Transaction Work

Reference files:

```text
IMG_1039.PNG
IMG_1058.PNG
IMG_1059.PNG
IMG_1060.PNG
IMG_1061.PNG
IMG_1062.PNG
IMG_1072.PNG
IMG_1073.PNG
```

What these imply:

- The register should be a work surface, not just a modal trigger.
- A customer item on the counter should match the transaction being resolved.
- Price, cost, profit, and customer response should be represented through a
  mixture of physical props and clean UI.
- Receipts, card readers, scanners, money/change, and result states create the
  tactile retail feel.

Mallcore adaptation:

- Keep `RegisterScreenState` as the source for register display text and color,
  but make its physical surroundings richer.
- Add scanner, receipt slip, card reader glow, cash drawer line, item tray, and
  customer-side counter pad.
- During a sale, place the customer item on the counter and show an amount on
  the register monitor.
- After a sale, leave a receipt slip briefly and update shelf gap/customer
  reaction.
- For no-sale or rejected bundle, show different register/counter state rather
  than only panel text.

### Customers, Queue, And Store Life

Reference files:

```text
IMG_1034.PNG
IMG_1039.PNG
IMG_1065.PNG
IMG_1066.PNG
IMG_1067.PNG
IMG_1068.PNG
IMG_1070.PNG
IMG_1071.PNG
```

What these imply:

- Customers are visual state machines.
- Browsing customers should face shelves, carry items, pause, compare, queue,
  react, and leave.
- Queue layout must be obvious and inside the store.
- Staff/manager silhouettes need to read as employees, not generic NPC blobs.

Mallcore adaptation:

- Give manager/staff visual cues: cap or hair, shirt/apron, name badge,
  clipboard, lanyard, store-color accent.
- Give customers archetype cues: collector, parent, bargain hunter, hype teen,
  sports regular, reseller.
- Add lightweight state indicators in-world only when useful: browsing,
  needs help, queued, considering, annoyed, ready to buy.
- Add held-item props and counter handoff props.
- Align gameplay queue markers and visible stanchion/rope/floor mat footprint.

### UI, HUD, Panels, And Simulation Feedback

Reference files:

```text
IMG_1058.PNG
IMG_1059.PNG
IMG_1060.PNG
IMG_1062.PNG
IMG_1063.PNG
IMG_1064.PNG
IMG_1068.PNG
IMG_1069.PNG
```

What these imply:

- Good retail-sim UI is compact and practical.
- Panels expose decisions: price, cost, profit, inventory, quantity, rent,
  customer want, time, and objective.
- The UI should support fast repeated actions without covering the work surface
  more than necessary.

Mallcore adaptation:

- Keep HUD compact and anchored away from the work surface.
- Use physical props for local state and panels for decision detail.
- Avoid giant modal explanations during first-person work.
- Build a consistent panel pattern for catalog, price setting, inventory,
  checkout, daily summary, and store customization.
- Preserve accessibility: strong contrast, colorblind-safe icons/shapes,
  readable type sizes, and non-color-only states.

## Visual North Star

The game should read as:

```text
A small, slightly scrappy mall used-game shop where every fixture,
product, customer, and register interaction visibly affects the business.
```

The player fantasy:

- I know what store I am in.
- I can tell what needs doing without reading a paragraph.
- I can see what I own.
- I can see what I am selling.
- I can see why a customer is here.
- I can improve the store and immediately understand the impact.
- The room gets denser, richer, and more operational as the run progresses.

## Visual Pillars

### 1. First-Viewport Store Identity

The first seconds should prove the shop concept.

Required first-view signals:

- Retro Rewind / used-game identity sign.
- Front glass or mall threshold context.
- Checkout/register readable from spawn.
- Manager/staff target visible.
- Starter display or shelf visible.
- Stockroom reads as employee-only back-of-house.
- Queue lane is inside the shop.

Avoid:

- Blank wall dominance.
- Dark gray-box booth shapes.
- Huge empty floor with one tiny object.
- Floating props that do not align with gameplay.
- UI labels carrying all meaning.

### 2. Readable Retail Density

The store should feel full without becoming noisy.

Good density:

- Shelves with repeated small product silhouettes.
- A few larger anchor props: counter, wall shelf, display table, console box,
  stockroom shelf.
- Quiet background clutter: boxes, paper stacks, posters, cords, display mats.
- Strong work-surface dominance: the current action area must still win.

Bad density:

- Random clutter on the register hiding the monitor.
- Decorative props blocking objectives.
- Posters or signs with no gameplay relationship.
- A shelf full of same-shape boxes with no category distinction.

### 3. Physical State Before Text

Every major state should have a physical sign.

Examples:

- Register ready: screen glow, drawer line, printer idle, lane clear.
- Sale pending: item on counter, amount on display, customer in front.
- Receipt settled: printed slip visible, item removed or bagged.
- Shelf stocked: visible cases/cartridges in slots.
- Shelf sold down: gaps, missing tags, tilted leftovers.
- Backroom stock: labeled boxes, pickup highlight, shelf/bay count.
- Featured display: special sign, spotlight, front-row placement.
- Promo poster: actual wall poster with category-specific graphic language.

Text is allowed, but it should confirm physical context rather than replace it.

### 4. Gameplay-Driven Decoration

Decor should not be arbitrary. Every visual upgrade should map to one or more
gameplay categories:

- Capacity: more shelf slots, stockroom slots, queue length.
- Conversion: better displays improve specific customer intent.
- Trust: cleaner checkout, visible receipts, testing station, organized holds.
- Demand: posters and featured displays shift customer spawn/demand.
- Efficiency: stockroom layout, counter tools, scanner, employee pathing.
- Risk: clutter, blind spots, hidden-thread props, suspicious holds.

### 5. Low-Poly But Specific

The game does not need realistic assets to look rich. It needs specific
silhouettes and consistent materials.

Good low-poly specificity:

- Console box has handle/stripe/platform shape.
- Cartridge has label, contact strip, notch.
- Register has monitor, base, drawer, scanner, receipt printer.
- Manager has employee silhouette and badge/clipboard.
- Stockroom has metal shelving, box labels, tape, hand truck.
- Mall exterior has glass, threshold, signage, store-hours plaque.

Bad low-poly:

- Generic cubes with no role.
- Same material on every wall/floor/fixture.
- Props without scale cues.
- Characters that do not communicate job, mood, or intent.

## Core Overhaul Backlog

### Slice 1: Day-1 Spawn Visual Parity

Goal:

Make `01_spawn_first_look.png` read like a small used-game shop without UI
labels.

Work:

- Strengthen storefront/entry threshold inside the current hub-mode flow.
- Add branded sign canopy and wall identity panel.
- Reduce blank wall dominance from spawn.
- Ensure checkout, manager, starter display, stockroom, and queue are visible.
- Add stronger stockroom enclosure and doorway readability.
- Add small but meaningful checkout clutter: card reader, receipt printer,
  scanner, drawer seam, paper slip.
- Give the manager employee-specific visuals.

Acceptance:

- Run `bash scripts/run_store_visual_sweep.sh`.
- Inspect `artifacts/visual_sweep/retro_games_day_one/current/01_spawn_first_look.png`.
- A fresh reviewer should identify shop type, first action, manager, register,
  starter display, and stockroom within three seconds.

### Slice 2: Starter Shelf And Product Readability

Goal:

Make the starter display visibly communicate stock, product type, price, and
future gaps.

Work:

- Add product-specific slot placement for the three free starter delivery items.
- Ensure `console_neo_ignite`, `neo_ignite_motorway_kings_loose`,
  `neo_ignite_kingdom_embers_loose`, and related starter items resolve through
  content/product visual paths without `ContentRegistry: unknown ID` warnings
  during the visual sweep.
- Add default visible price tags for stocked items.
- Add shelf/category labels for starter table/wall.
- Add empty slot or gap state after sale/customer outcome.
- Add optional protective case or "featured" marker for high-value stock.

Acceptance:

- Visual sweep has no unknown starter product ID warnings.
- `03_shelf_wall_product_focus.png` shows distinct product forms and prices.
- Product type remains readable at 1280x720.

### Slice 3: Register Work Surface

Goal:

Turn checkout into a tactile work surface.

Work:

- Keep `RegisterScreenState` as the semantic state owner.
- Add item-on-counter node for active transaction.
- Add customer-side counter target and staff-side register tools.
- Add receipt slip visibility for settled sales.
- Add no-sale/refusal state at counter.
- Add scanner/card-reader feedback.
- Tie register display amount to active checkout data where possible.

Acceptance:

- `02_checkout_manager_counter.png` clearly shows the register area.
- Sale moments show a visible item, amount, and outcome.
- Counter props support the action instead of hiding the monitor.

### Slice 4: Build/Design Tool Upgrade

Goal:

Make build mode feel like a store design tool rather than a debug grid.

Work:

- Add category tabs: Fixtures, Shelves, Counters, Signage, Decor, Surfaces,
  Lighting, Stockroom.
- Add fixture thumbnails or simple silhouettes.
- Add price, capacity, unlock status, and effect metadata to each catalog card.
- Add move/rotate/sell/place affordances with visible mode color.
- Add wall/floor material swatches.
- Add placement ghost with footprint, facing arrow, valid/invalid state, and
  collision reason.
- Persist design choices through store layout/customization where possible.

Acceptance:

- A player can enter build mode and understand what they can buy/place without
  reading external docs.
- Invalid placement reason is clear.
- Existing placement validation and no-overlap contracts still pass.

### Slice 5: Store Customization Becomes Physical

Goal:

Make `StoreCustomizationSystem` choices visible in the room.

Work:

- Poster selection changes actual wall poster art/geometry.
- Featured category changes display signage, product grouping, light accent,
  or shelf label.
- Morning note hint can be inferred through store context, not only text.
- Add category-specific display props:
  - new console hype: console box tower, launch poster, brighter sign
  - old-gen clearance: sale tags, bargain bin, hand-written sign
  - used bundles: bundle mat, controller pile, multi-item tag
  - sports games: annual sports row, cheap sticker, fan/jersey accent
  - accessories: controller bin, cable hooks, battery pack labels
  - family friendly: colorful front-facing cases, lower shelf line

Acceptance:

- Cycling poster/featured category changes the physical scene.
- Spawn/demand effects still come from the existing customization system.
- Visuals do not imply effects that the system does not apply.

### Slice 6: Customer And Queue Readability

Goal:

Make customer flow and intent readable before panels open.

Work:

- Align visible queue lane with gameplay queue markers.
- Add customer idle states: entering, browsing, comparing, queued, counter,
  leaving.
- Add held item prop for customers who have selected or returned an item.
- Add archetype visual accents while keeping low-poly style.
- Add reaction cues for sale, no-sale, bundle accepted, bundle rejected,
  clean exchange, refused return.
- Keep the manager/staff spot out of the queue lane.

Acceptance:

- Queue is entirely inside store and points to register.
- Customer state can be inferred from position/pose/held item.
- No NPC blocks first-day route anchors.

### Slice 7: Lighting, Materials, And Atmosphere

Goal:

Replace prototype flatness with a deliberate low-poly retail material system.

Work:

- Define material families:
  - mall threshold: glass, brushed metal, stone/tile
  - sales floor: warm wood/laminate, shelf metal, acrylic, paper tags
  - checkout: worn counter, black plastic, green register glow, receipt paper
  - stockroom: cooler blue/gray walls, metal shelves, cardboard, tape
  - signage: amber CRT accent, store-color borders, poster paper
- Add practical lights: register glow, CRT monitor glow, sign glow, stockroom
  strip light, display table accent.
- Use color contrast to separate zones.
- Avoid all-brown/all-blue/all-gray scenes. Keep the warm retail floor, cooler
  stockroom, amber store identity, and small saturated product accents.

Acceptance:

- Spawn and shelf captures have clear foreground/midground/background.
- Stockroom reads back-of-house.
- Products and work surfaces remain visible under lighting.

### Slice 8: Visual Regression And Review Discipline

Goal:

Make visual progress hard to accidentally regress.

Work:

- Keep using `scripts/run_store_visual_sweep.sh` for every geometry/camera/
  route/readability change.
- Add or update baselines once a slice is accepted.
- Extend manifest rows for:
  - storefront identity
  - build/design tool
  - stocked shelf before sale
  - shelf after sale/gap
  - active checkout transaction
  - customer queue
  - store customization poster/featured display
- Keep review criteria explicit:
  - no blank-wall dominance
  - no oversized-door dominance
  - no disconnected-prop dominance
  - work surface is dominant in action captures
  - route target is not hidden by props or UI
  - UI is readable and not clipped

Acceptance:

- Visual changes produce fresh captures.
- Important visual choices are reflected in manifests, tests, or docs.
- Baseline updates are intentional, not incidental.

## System-Specific Upgrade Notes

### `StoreVisualKit`

Current role:

- Central registry for reusable fixture and prop visuals.

Upgrade direction:

- Add higher-level fixture families, not only prop IDs.
- Ensure every prop has a clear role: fixture, work-surface tool, shelf product,
  signage, decor, route cue, stockroom object.
- Add more procedural helper builders for small repeated items:
  - price tag variants
  - sale stickers
  - shelf-talkers
  - poster cards
  - cable hooks
  - receipt slips
  - label plates
  - queue rope/stanchion pieces

### `StoreVisualLayout`

Current role:

- Loads fixture/product placements and physical contracts.

Upgrade direction:

- Treat layout JSON as the physical truth surface.
- Add explicit named zones for storefront, front window, checkout, queue,
  starter display, used games wall, accessories bin, stockroom pickup bay,
  staff path, customer route, and featured display.
- Each authored fixture should declare:
  - `zone`
  - `role`
  - `position`
  - `rotation`
  - `size` or footprint
  - `facing`
  - `no_overlap_constraints`
  - whether it is action-critical or dressing

### `ExpandableStoreShellRuntime`

Current role:

- Builds the starter shell, physical anchors, checkout, stockroom, route
  cues, and day-one scene context.

Upgrade direction:

- Keep shell generation deterministic.
- Move repeated visual concepts into helper builders if the file keeps growing.
- Make storefront and stockroom surfaces feel intentionally different.
- Avoid letting route cues become decorative clutter. Cues should explain
  movement or focus.

### `ProductVisualFactory`

Current role:

- Builds designed product visuals from item metadata and the product visual
  catalog.

Upgrade direction:

- Expand template variety for platform families and condition states.
- Add product-level tag metadata:
  - condition sticker
  - rarity marker
  - trade-in marker
  - staff-pick marker
  - sale/clearance marker
  - protective-case marker
- Ensure all starter items resolve during automation and visual sweeps.

### `RegisterScreenState`

Current role:

- Owns semantic register states and physical screen text/color.

Upgrade direction:

- Keep this as the state owner.
- Add paired work-surface props for each state.
- Avoid putting sale logic here; it should display state from the checkout/store
  session systems.
- Add tests that assert state-to-visual mapping for screen text, receipt, and
  counter item visibility.

### `StoreCustomizationSystem`

Current role:

- Owns per-day featured display and poster choices with spawn/demand effects.

Upgrade direction:

- Add an adapter from customization state to physical store dressing.
- Keep gameplay effect tables here, but render choices through visual systems.
- Add visual state tests for poster and featured display changes.

## UI Direction

### HUD

Keep the HUD compact. It should tell the player:

- day/time/phase
- money
- current objective
- active prompt
- small event log/status feedback

It should not cover the local work surface.

### Catalog Panels

Build/design panels should expose:

- item name
- thumbnail/silhouette
- price
- owned count
- capacity/effect
- unlock status
- category
- place/move/sell controls

Use dense, practical UI. Avoid marketing-style cards or oversized hero copy.

### Checkout Panels

Checkout UI should expose:

- customer archetype or need
- item(s)
- base price / current price
- discount or bundle option
- profit signal
- confirm / decline / bundle action
- result feedback

The panel should support the physical counter action, not replace it.

### Inventory/Stockroom Panels

Inventory UI should expose:

- item
- platform/category
- quantity
- condition
- shelf/backroom location
- price
- action: stock, hold, inspect, price, move

Avoid making inventory a spreadsheet-only game. Every important inventory
change should eventually create a visible shelf/backroom/counter change.

## Content And Economy Hooks

Visual upgrades should reinforce existing simulation systems:

- Platform hype should show up in poster/display demand.
- Rarity should change shelf treatment.
- Condition should change stickers, sleeves, or price tags.
- Customer archetype should influence browsing target and reaction.
- Staff/manager trust should affect access, notes, and visible staff support.
- Hidden-thread/scapegoat-risk content should stay environmental and subtle,
  not announced by the UI.

## Suggested New Docs During Build

Add these as implementation matures:

```text
docs/style/storefront-identity.md
docs/style/build-mode-design-tool.md
docs/style/product-visual-catalog.md
docs/style/register-work-surface.md
docs/style/customer-visual-states.md
docs/style/visual-sweep-acceptance.md
```

Keep this braindump broad. Put concrete finalized contracts in narrower docs.

## Definition Of Done For A Visual Slice

A visual slice is not done when the code compiles. It is done when:

- The in-world state communicates the intended gameplay state.
- `scripts/run_store_visual_sweep.sh` produces fresh captures.
- A reviewer can inspect the relevant PNG without running the game.
- The route target remains readable without UI labels.
- Any new physical object has a named owner and zone.
- Existing no-overlap and route contracts still pass.
- The implementation does not rely on proprietary reference assets.
- The doc or test surface records why the visual exists.

## Immediate Next-Agent Prompt

Use this when handing off the first implementation pass:

```text
Implement the Day-1 visual parity slice from docs/style/visual-overhaul-braindump.md.
Start with spawn readability and do not broaden into all store systems.
Use inspiration/ as reference, but create original low-poly assets/procedural props.
Preserve the current store-session route and physical layout contracts.
Run scripts/run_store_visual_sweep.sh and review 01_spawn_first_look.png,
02_checkout_manager_counter.png, and 03_shelf_wall_product_focus.png.
Fix ContentRegistry starter product warnings if they affect product visuals.
Do not update baselines until the new captures are explicitly accepted.
```
