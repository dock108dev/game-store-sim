# Fixtures And Displays

Status: Active visual bible
Spreadsheet families: Shelving, Display, fixture-related Architecture
Primary IDs: OBJ-042, OBJ-056 through OBJ-079, OBJ-063 through OBJ-071, OBJ-076, OBJ-077, OBJ-080, OBJ-081, OBJ-083, OBJ-091

## Target Read

Fixtures are the main reason the current scene still reads primitive. The next pass must treat fixtures as actual retail objects, not as panels with a few cubes on them.

The store should use physical shelves, racks, bins, cases, and counters that can hold meaningful quantities of product. Product should not live primarily on wall hooks. The MVP store walls are drywall; product display should be carried by fixtures that look bought, placed, and useful.

## Locked Decisions

- Walls are mostly drywall; fixtures hold product.
- Starter store uses an initial starter pack for pre-day-one setup.
- Fixtures are player-placeable/configurable unless structurally fixed.
- Fixtures are not "quality upgrades" from ugly to nice. Progression is size/function/capacity/type.
- Empty capacity is good and should be visible.
- Fixtures should commonly hold 10-30 items.
- Do not build a fixture as a rectangle with four lines and call it done.

## Fixture Families

| ID | Object | Bible Direction |
| --- | --- | --- |
| OBJ-056 | Single-sided wall game shelf | Physical shelf/rack against drywall, 10-30 DVD cases, visible empty capacity. |
| OBJ-057 | Double-sided gondola shelf | Low floor browsing unit with real endcaps, shelf thickness, side panels, base, and capacity. |
| OBJ-058 | Narrow endcap display | Promotional fixture with sign topper and stocked/empty states. |
| OBJ-059 | Tall used-game wall bay | Later/used-focused fixture; should hold many DVD cases with dividers and used stickers. |
| OBJ-060 | New release slat shelf bay | Clean front-facing display for hero releases; should make cover art obvious from player distance. |
| OBJ-062 | Accessory rack concept | Convert any pegboard-style spreadsheet intent into a physical packaged-accessory rack for MVP; not a main game display solution. |
| OBJ-067 | Bargain dump bin | Physical bin with internal volume and visible loose cases when stocked. |
| OBJ-068 | Portable game case rack | Smaller-scale fixture for handheld boxes/cases. |
| OBJ-076 | Controller hanging rail | Accessory fixture; hanging rail/cards are okay for packaged accessories. |
| OBJ-077 | Memory card/accessory shelf strip | Small packaged accessory fixture, not a game shelf substitute. |

## Display Families

| ID | Object | Bible Direction |
| --- | --- | --- |
| OBJ-042 | Counter impulse rack | Small counter rack for memory cards/batteries/cables later; day-one optional. |
| OBJ-063 | Glass hardware display case | Authored glass case with frame, lock, light, shelves, and premium item support. |
| OBJ-064 | Glass counter display insert | Later high-value small-item display. |
| OBJ-065 | Strategy guide floor rack | Magazine-style angled rack, not a flat shelf. |
| OBJ-066 | Magazine spinner rack | Later authenticity fixture; wire spinner can be asset-pack sourced. |
| OBJ-069 | Console box floor stack | Player choice display; stack should show real box proportions and repeated boxes. |
| OBJ-070 | Preorder standee display | Later promotional cardboard standee; not day-one clutter unless one campaign requires it. |
| OBJ-071 | Poster snap frame | Reusable frame for marketing, not random wall clutter. |
| OBJ-080 | Trade-in promo display tower | Later promotional tower. |
| OBJ-081 | New hardware launch pedestal | Later launch event showcase. |
| OBJ-083 | Employee picks shelf | Later personality/merchandising fixture. |
| OBJ-091 | Wall-mounted TV bracket | Demo support only; should include bracket/cables if visible. |

## Capacity Rules

Fixtures need readable capacity states:

- Empty: player can see open slots/shelf capacity.
- Partially stocked: one or two product groups without looking broken.
- Stocked: repeated products stack/fill naturally.
- Full: visually dense but still readable.

Empty capacity should be indicated through shelf ledges, dividers, subtle floor/shelf outlines, or object absence. Do not use floating labels or black rods that look like debug markers.

## Mesh And Shape Rules

Every MVP fixture should include:

- authored silhouette
- bevels/rounded edges where appropriate
- material breaks between shelf, frame, side panel, base, trim, and sign holder
- depth and thickness that can be read from first-person camera
- collision separate from visual mesh when needed
- clear stocked/empty anchors for item placement

Acceptable fixture materials:

- black/dark metal frame
- cheap clean laminate
- acrylic or glass panels
- plastic bins
- wire racks for magazines/accessories only

Avoid:

- four rods plus one rectangle
- paper-thin shelves
- flat panels pretending to be storage
- single-purpose fixtures that hold only two or three products unless they are counter impulse displays

## Starter Fixture Pack

The first implementation should create a starter pack that supports pre-day-one setup:

- one wall/floor game fixture that can hold 10-30 DVD cases
- one demo display/kiosk if included in inventory
- one receiving/setup surface or box flow
- optional small accessory/console display surface

The fixture pack should make the store feel understocked because the player has little inventory, not because the store has no usable retail infrastructure.

## Validation Shots

Required:

- empty starter fixture close shot
- same fixture with two starter games placed
- duplicate stack read with multiple copies
- normal player-height aisle shot showing fixture silhouette

Pass criteria: the fixture reads as a real retail display object before products or labels are added.
