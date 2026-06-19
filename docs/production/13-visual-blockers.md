# Visual Blockers

Status: Active
Scope: MVP + first-store visual rebuild

This is not an alpha or beta bug list. It tracks blockers that prevent the opening store from reaching the Visual Bible target.

## Current Gate

Owner review still rates the current visual direction around 4.5/10. The current playable Godot scene is valuable as a mechanics prototype, but it is not the visual baseline.

The active target is:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/work-packets/00-packet-index.md`

External beta/tester packaging remains blocked until a Visual Bible implementation pass is reviewable against the 7.5/10 target.

## Open Blockers

| ID | Priority | Area | Problem | Required Resolution |
| --- | --- | --- | --- | --- |
| VIS-012 | P0 | Art-production method | The prior Godot-primitive/art-kit route still reads too boxy and assembled. | Build MVP object families with authored meshes, bitmap/detail textures, and stronger silhouettes before playable-store reintegration. |
| VIS-013 | P1 | Product art | Starter games and product cases are not yet strong enough to sell the store fantasy from first-person distance. | Implement Visual Bible product kit: DVD cases, cover variants, platform/genre language, price stickers, stack language, console/accessory packaging. |
| VIS-014 | P1 | Fixtures/displays | Shelves, displays, and storage still read too much like rectangles/rods instead of retail fixtures. | Implement fixture/display kit with capacity, bevels, material breaks, empty slots, and stocking compatibility. |
| VIS-015 | P1 | Store shell | Mall/store architecture still has too many flat planes and prototype edges. | Implement shell kit: drywall, carpet, ceiling, storefront trim, glass rhythm, neighboring context, and quieter wall treatment. |
| VIS-016 | P1 | Counter/trade-in | Checkout/trade-in reads functionally but not yet like a designed small-store cash wrap. | Implement counter/register/trade-in kit with POS, scanner, drawer, bags, cubbies/intake, and clean one-line queue support. |
| VIS-017 | P1 | Stockroom/receiving | Receiving and storage still need to read as real operational areas rather than labeled props. | Implement stockroom/receiving/office kit with racks, receiving desk, boxes, office computer/calendar, and clean storage organization. |
| VIS-018 | P2 | Signage | Text/signs must support the store without carrying the object read. | Implement minimal signage/store identity kit after product/fixture/shell assets can stand on their own. |

## Resolved Or Demoted

| ID | Area | Resolution |
| --- | --- | --- |
| VIS-001 | Documentation routing | Current routing is design source -> Visual Bible -> implementation packet index -> production/QA evidence. |
| VIS-005 | Store identity | `Games4U` remains editable default; legal-safe branding rules are documented in the Visual Bible. |
| VIS-006 | Screenshot evidence | Existing contact sheet remains regression evidence only, not art approval. |
| VIS-011 | Packet 08/09 review | Old packet docs were deleted from the active tree; their outcome is summarized as reference evidence only. |

## Stop Conditions

Do not start broad catalog, customer visuals, employee visuals, decoration breadth, hidden narrative, later-era, or beta/tester work while VIS-012 through VIS-017 are open.

Do not use a passing `scripts/validate_godot.sh` run as art approval. It is regression evidence only.
