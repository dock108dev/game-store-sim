# MVP Object Implementation Checklist

Status: Active visual bible
Source: `docs/design-implementation/game_store_sim_300_object_asset_inventory.xlsx`
Scope: MVP + first-store objects only

## Quality Gate

Every MVP object family must answer these before implementation:

- What does it read as from normal player height?
- What object-specific silhouette prevents primitive read?
- What material/texture work carries the detail?
- What is placeable/configurable versus structurally fixed?
- What screenshot proves it meets the target?
- Does it support the day-one empty-ish setup state?

## Tier A First Pass

These objects should be implemented before broadening the catalog because they directly drive the first impression.

| Priority | IDs | Object Family | Required Result |
| --- | --- | --- | --- |
| 1 | OBJ-097/102/etc. + starter game rows | DVD game case kit | Authored cases, cover art texture, spine, price sticker, stack duplicates. |
| 2 | Starter game rows | `Footy 2002` and adventure RPG | Recognizable legal-safe cover art, readable from player distance. |
| 3 | Starter platform hardware rows | Console box and accessory package | Retail box/package with platform identity, player-placeable. |
| 4 | OBJ-056/057/060 | Starter shelf/rack/display | Physical fixture holding 10-30 products with empty capacity. |
| 5 | OBJ-001/003/004/007/008/009 | Store shell/front read | Mall interior storefront, drywall, carpet, quiet ceiling, readable sign. |
| 6 | OBJ-026/027/029/030/031/036 | Counter/register/trade-in | Straight combined counter with detailed POS/scanner/intake surface. |
| 7 | OBJ-010/246/247 | Receiving/backroom start | Real stockroom entry and receiving boxes for starter setup. |
| 8 | OBJ-204 + OBJ-003 | Store identity | `Games4U` logo/sign kit, editable later. |

## Tier A Acceptance

Tier A objects must not be final-facing primitives.

Acceptance checklist:

- authored mesh or licensed asset with clear silhouette
- UV/bitmap/material detail where industry-standard
- no floating label dependency
- legal-safe fictional identity
- screenshot proof at player distance
- screenshot proof close enough to inspect shape/materials

## Tier B First Pass

These are important but can follow Tier A once the first impression improves.

| IDs | Object Family | Required Result |
| --- | --- | --- |
| OBJ-063/064 | Glass display cases | Authored glass/frame/lock/light; high-value display support. |
| OBJ-065/066 | Guide/magazine racks | Angled/spinner rack silhouettes, later guide/media support. |
| OBJ-067/079 | Bargain/clearance fixtures | Dump bin/shelf with orange tag system, later discount flow. |
| OBJ-071/160/161 | Poster/snap frame templates | Minimal day-one sign support, swappable later. |
| OBJ-084/169 | Coming soon/release board | Later release calendar visual; do not clutter day one. |
| OBJ-034/040/047/048 | Back counter/storage props | Clean storage/hold/tote details as needed. |
| OBJ-210/212/217 | Demo kiosk/screen | Demo display with CRT or screen texture/loop support. |

## Day-One Starter Setup

Pre-day-one setup should include:

- receiving area with starter shipment
- player-placeable starter shelf/rack/display
- two starter games
- one console
- one accessory/controller
- minimal signage, likely `Games4U` plus one grand-opening sign
- no customers/employees until store open
- no future inventory physically present

## Object Family Recipes

### Starter DVD Case

- Mesh: DVD case with bevel, spine, face, thickness.
- Texture: cover art, platform band, price sticker, optional used sticker.
- States: new, used later, duplicate stack.
- Screenshot: close face, shelf row, duplicate stack.

### Starter Fixture

- Mesh: physical shelf/rack with capacity for 10-30 cases.
- Texture/material: laminate/metal/plastic/acrylic as appropriate.
- States: empty, partially stocked, full.
- Screenshot: empty capacity, two games placed, normal aisle shot.

### Console Box

- Mesh: realistic retail box with front/side/top panels and box seams.
- Texture: platform identity, product silhouette, readable color blocking.
- States: single box, stack of boxes.
- Screenshot: placed on shelf/floor/backroom.

### Accessory Package

- Mesh: small box/card package.
- Texture: platform identity and simple product silhouette.
- States: single, repeated small stock.
- Screenshot: on starter fixture or counter rack.

### Storefront/Sign

- Mesh: sign housing, glass/door/mullions, threshold.
- Texture: readable `Games4U`, optional store hours/open sign.
- States: open/closed later.
- Screenshot: mall-facing and inside-looking-out.

### Counter/Register

- Mesh: straight counter with register, scanner, receipt printer.
- Texture/material: laminate, plastic, screen, small stickers.
- States: idle day-one, later transaction use.
- Screenshot: customer side, staff side, POS close.

### Receiving/Stockroom

- Mesh: backroom door, receiving boxes, storage racks, desk/computer/calendar.
- Texture/material: clean utility surfaces.
- States: unopened/opened shipment, empty/stocked rack.
- Screenshot: doorway, receiving, office/storage.

## Deferred From MVP Detail

Do not spend first rebuild time on:

- all 300 product rows
- full poster campaign system
- heavy used-hardware detail
- cable/memory-card breadth
- shrinkwrap/new seals
- broad hidden narrative prop set
- customers/employees
- late-era platform breadth

## Review Board Requirement

The next art review board should show:

1. storefront/interior first read
2. starter fixture empty capacity
3. starter fixture stocked with two games
4. product closeups
5. counter/register
6. receiving/stockroom

No before screenshot is required. The current look is considered obsolete.
