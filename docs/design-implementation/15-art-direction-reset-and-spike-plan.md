# Art Direction Reset And Spike Plan

Status: Historical reference, superseded by Visual Bible and current work packets
Owner decision: block current visual direction
Runtime target: Godot remains the integration/runtime unless the art spike proves it cannot support the target
Art workflow target: Blender-authored modular assets, bitmap textures, and legally clean asset packs/custom authored pieces

## Purpose

The current Godot store scene is frozen as a mechanics prototype. It proves interactions, inventory, receiving, checkout, stockroom systems, save/load, and validation coverage. It does not prove the final visual direction.

This doc records the block decision that led to the Visual Bible. It is not the active work queue. Current implementation state lives in `docs/CURRENT_STATE.md` and `docs/design-implementation/work-packets/00-packet-index.md`.

## Owner Answers

Locked owner answers for this reset:

- Style target: polished stylized indie. Late-PS2 memory is inspiration only, not a strict fidelity ceiling.
- Godot primitives are not the primary art-production method.
- Blender-authored modular assets are allowed and expected.
- First proof shot: inside looking out.
- Store vibe: small chain game store.
- Third-party asset packs are allowed if legally clean.
- Store footprint, facade, layout, and world placement may change heavily.
- Target owner visual score for Visual Bible implementation passes is 7.5/10.

## Why The Current Direction Is Blocked

The current scene improved mechanically and structurally, but it still reads like arranged primitive geometry:

- flat wall, facade, and ceiling planes
- block-built checkout and receiving props
- simple shelf/counter silhouettes
- label-dependent product and workflow communication
- contact-sheet evidence built for regression, not art approval

More incremental labels, panels, cubes, or prop piles will not solve this. The production method must change.

## Inspiration Folder Role

The `inspiration/` and `new_real_inspiration/` folders are now primary art-direction input. They should be used to extract visual rules, not copied directly.

Use `inspiration/` for stylized game-world scaffold:

Reference patterns visible in the inspiration set:

- strong storefront identity from sign housing, lit trim, glass rhythm, door position, and neighboring storefront context
- small-chain storefronts with simple but designed facade shapes
- neon or lit edge accents used sparingly as trim, not as random strips
- grounded pedestrian mall/strip-mall exterior with flooring, planters, railings, windows, benches, and neighboring businesses
- warm interior office/backroom surfaces with wood desks, shelves, CRT/computer props, posters, calendars, binders, and paperwork
- dense detail from material breaks and authored props, not from scattered boxes
- readable commercial spaces with trim, mullions, frames, ceiling fixtures, and believable floor transitions

Use `new_real_inspiration/` for period retail construction:

- wire-grid and acrylic game-case shelving
- dense rows of visible game cases, not generic blocks
- platform header strips, sale tags, yellow price stickers, and shelf dividers
- fluorescent drop ceilings and bright chain-retail lighting
- low commercial carpet, tile transitions, and simple retail flooring
- glass display cases with boxed consoles and premium product anchors
- register/counter surfaces with scanner, bags, console boxes, stacks of cases, and promo cards
- poster walls, mural panels, hanging promo signs, and branded aisle/category markers
- small-chain/staff retail language without copying real brands

## Do Not Continue

Do not keep polishing the existing `graybox_store` / `store_world` visual route as the final art baseline.

Do not add more cube shelves, label cards, or primitive prop clusters to solve visual quality.

Do not start broad catalog, customers, decorations, hidden narrative, or beta tester prep until the art spike is approved.

Do not use `scripts/validate_godot.sh` or the existing contact sheet as the art approval source.

## Keep From Current Build

Keep these systems and route them into the future art rebuild:

- first-person controller
- interaction contract
- inventory and product data
- receiving workflow
- carrying/stocking
- checkout/register/trade-in systems
- stockroom/backroom computer workflows
- save/load
- validation harness as regression evidence

## Art Spike Scope

Build one isolated art scene first. It should not carry the full store.

Required view:

- player starts inside the store looking out through the storefront
- visible storefront glass/door/frame/sign from inside
- visible mall or small-chain retail corridor outside
- visible first 10-15 feet of store interior
- one counter or one wall shelf anchor
- no customers
- no employees
- no broad catalog
- no debug labels

Success means one screenshot can convince the owner that this is the right visual production method.

## Required Art Modules

The spike should prove these modules before full-store rebuild:

1. storefront glass kit: mullions, door, handle, threshold, decals, interior/exterior frames
2. sign/facade kit: small-chain sign housing, lit trim, fascia panels, believable mounting
3. floor kit: interior commercial carpet/tile transition plus exterior mall flooring
4. ceiling/light kit: retail ceiling plane, panel seams, fluorescent or recessed light fixtures
5. wall kit: paint panels, baseboard, trim, poster mounting, outlet/utility details
6. counter or shelf hero module: designed silhouette, bevels, shelves/cubbies, material breaks
7. product-row proxy: bitmap-backed cases/boxes that read without text labels
8. backroom/office hint: desk/computer/poster/calendar/shelf language if visible from the shot

## Asset Workflow

Preferred production path:

1. Extract reference rules from `inspiration/`.
2. Extract period retail rules from `new_real_inspiration/`.
3. Source legally clean low-poly/retail/mall/office asset packs where useful.
4. Create or adapt Blender modules for the required art modules.
5. Use bitmap textures or atlases for signs, product faces, posters, labels, carpet/tile, and surface detail.
6. Import modules into Godot as a separate art-spike scene.
7. Capture a large single-shot review image and a small route if needed.
8. Only after owner approval, rebuild the game store scene from the approved kit.

## Spike Acceptance Bar

The spike passes only if:

- it reads as a small chain game store before labels
- the inside-looking-out shot has storefront, retail corridor, and interior anchors
- the image has real authored geometry: trims, bevels, frames, panels, props, and material breaks
- bitmap detail does meaningful work
- it avoids the current primitive cube-store read
- it feels like a polished stylized indie game store with early/mid-2000s retail inspiration
- it is simple enough to expand into the actual playable store

## Validation

Validation for this phase is visual first:

- owner-facing screenshot or review board
- side-by-side current screenshot versus art-spike screenshot
- notes mapped back to `inspiration/` and `new_real_inspiration/` rules
- optional Godot load smoke if imported into Godot

The full `scripts/validate_godot.sh` gate is still useful only after the spike integrates with the playable scene.

## Next Implementation Packet

Packet 09 was created and executed. Owner feedback after Packet 09 still rated the result as too primitive, so future implementation must use:

- `docs/visual-bible/README.md`
- `docs/visual-bible/08-art-production-pipeline.md`
- `docs/visual-bible/09-mvp-object-implementation-checklist.md`

Packet 09 remains reference evidence, not production approval.
