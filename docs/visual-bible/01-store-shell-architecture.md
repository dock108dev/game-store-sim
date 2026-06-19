# Store Shell And Architecture

Status: Active visual bible
Spreadsheet families: Architecture, Signage entrance rows, floor/ceiling/supporting utility rows
Primary IDs: OBJ-001 through OBJ-017, plus store identity rows OBJ-203 and OBJ-204 where relevant

## Target Read

The first store is an interior mall game shop. It should read clean, open, newly occupied, and understocked, not grimy, abandoned, or packed with future content. The shell should provide a believable store envelope while staying quiet enough that fixtures and products become the first visual interest.

The visual target is polished stylized indie, not strict PS2 reconstruction. Low-poly is acceptable only when it feels authored. Large flat planes are acceptable for walls and floors only if the material, trim, baseboards, lighting, and proportions make them read intentional.

## Locked Decisions

- Production baseline is a mall interior store, not a strip-mall exterior.
- Day-one store is clean/open/new.
- Floor is carpet as the main retail surface.
- Walls are mostly drywall, not slatwall walls covered with hooks.
- Ceiling exists but should not draw attention.
- Store colors should be muted and eventually player-customizable.
- Storefront/signage must be readable, with `Games4U` as default.

## MVP Shell Objects

| ID | Object | Bible Direction |
| --- | --- | --- |
| OBJ-001 | Narrow storefront glass door | Open mall storefront door with real frame, handle, threshold, glass thickness, and open/closed-ready pivot. |
| OBJ-002 | Front window poster bay | Mostly clear glass on day one; one restrained grand-opening/poster area max. |
| OBJ-003 | Storefront logo sign placeholder | Legible mall sign, configurable later, not a parody of a real retailer. |
| OBJ-004 | Low-pile carpet flooring | New firm commercial carpet, muted, subtle texture, no polished modern floor. |
| OBJ-005 | Back wall slatwall system | Retire as wall-hook baseline for first rebuild; replace with drywall plus placed physical shelving/rack fixtures. |
| OBJ-006 | Side wall slatwall system | Same as OBJ-005; side walls should support fixtures, not become hook grids. |
| OBJ-007 | Painted drywall strip | Primary wall language. Clean muted drywall with baseboards, trim, outlets, and optional editable color panels. |
| OBJ-008 | Suspended ceiling grid | Quiet drop ceiling with panels, seams, and a few vents/diffusers. Do not make it the focal point. |
| OBJ-009 | Fluorescent ceiling light bank | Bright, even retail lighting. Mesh plus real light source. |
| OBJ-010 | Backroom door | Visible utility/staff doorway, real depth, simple staff-only sign, leads to stockroom/office. |
| OBJ-012 | Cash wrap wall panel | Behind-counter wall can be mostly empty day one, with real cabinetry/back counter context. |
| OBJ-013 | Queue floor mat | Optional subtle rubber mat for queue area; should not be needed to explain the store. |
| OBJ-014 | Entrance security pedestals | Later authenticity prop, not required for day-one MVP unless composition needs it. |
| OBJ-017 | Exit sign | Small static realism prop; keep understated. |

## Geometry Requirements

Store shell modules should be Blender-authored or equivalent authored modular meshes for any close-camera work:

- storefront mullions and door frame with bevels
- sign housing with depth and mounting structure
- doorway/threshold with trim
- baseboards and floor transitions
- ceiling grid as a quiet modular kit
- wall panels with seams, outlets, subtle scuffs, and editable color surface support

Godot primitives can be used for collision or hidden blockout, but not as the visible final art for the storefront, door, ceiling fixtures, or player-facing architecture.

## Material Requirements

- Carpet: low-pile, firm, slightly textured, clean/new.
- Drywall: muted neutral, editable later, subtle variation, not flat gray.
- Trim/baseboard: darker commercial trim, clean edges.
- Glass: transparent with reflection/tint, visible thickness, believable frames.
- Sign housing: readable cream/light panel or equivalent, not pixel-noise text.
- Ceiling: off-white acoustic panels with quiet seams and simple diffusers.

## Day-One Composition

The opening view should communicate:

- this is a store in a mall
- the store is new and not fully built out
- the player is about to set up a first batch of inventory
- there is enough physical retail structure to trust the world

Avoid:

- full future inventory on walls
- random posters everywhere
- slatwall covering all walls
- large empty gray planes
- labels explaining zones that should be visually obvious

## Validation Shots

Required after shell implementation:

- inside-looking-out storefront shot
- entrance-from-mall shot
- first 10-15 feet of store interior shot
- ceiling/floor/wall material shot from normal player height

Pass criteria: screenshots read as a clean mall game store shell at a glance, without needing debug labels.
