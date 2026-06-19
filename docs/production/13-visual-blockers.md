# Visual Blockers

Status: Active
Scope: MVP + first-store visual rebuild

This is not an alpha or beta bug list. It tracks blockers that prevent the opening store from reaching the Visual Bible target.

## Current Gate

Owner review previously rated the pre-Visual-Bible direction around 4.5/10. The first object-family implementation pass is now integrated and ready for owner review. Automated validation is green, but owner review still decides whether this pass is good enough to continue toward beta/tester preparation.

The active target is:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/work-packets/00-packet-index.md`

External beta/tester packaging remains blocked until a Visual Bible implementation pass is reviewable against the 7.5/10 target.

## Open Blockers

| ID | Priority | Area | Problem | Required Resolution |
| --- | --- | --- | --- | --- |
| VIS-019 | P0 | Owner visual review | The first Visual Bible object-family pass is implemented, but not owner-approved. | Review product, fixture, shell, counter, receiving, stockroom, and storefront screenshots against the 7.5/10 target. |

## Resolved Or Demoted

| ID | Area | Resolution |
| --- | --- | --- |
| VIS-001 | Documentation routing | Current routing is design source -> Visual Bible -> implementation packet index -> production/QA evidence. |
| VIS-005 | Store identity | `Games4U` remains editable default; legal-safe branding rules are documented in the Visual Bible. |
| VIS-006 | Screenshot evidence | Existing contact sheet remains regression evidence only, not art approval. |
| VIS-011 | Packet 08/09 review | Old packet docs were deleted from the active tree; their outcome is summarized as reference evidence only. |
| VIS-012 | Art-production method | MVP object families were implemented and integrated into the playable route; pending owner review decides whether the method is accepted. |
| VIS-013 | Product art | Starter DVD cases, cover variants, platform/genre language, price stickers, stack language, and console/accessory packaging are implemented for review. |
| VIS-014 | Fixtures/displays | Twelve-slot stockable fixture language, empty capacity, rails, dividers, trim, and stocking compatibility are implemented for review. |
| VIS-015 | Store shell | Storefront, drywall/carpet/ceiling, glass, trim, and quiet wall treatment are implemented for review. |
| VIS-016 | Counter/trade-in | Register counter, scanner, cash drawer, bags, trade-in tray, and clean queue support are implemented for review. |
| VIS-017 | Stockroom/receiving | Receiving intake, racks, office desk/computer/calendar, storage, and staff threshold cues are implemented for review. |
| VIS-018 | Signage | Minimal signage/store identity support is implemented for review as part of the shell/counter/backroom pass. |

## Stop Conditions

Do not start broad catalog, customer visuals, employee visuals, decoration breadth, hidden narrative, later-era, or beta/tester work while VIS-019 is open.

Do not use a passing `scripts/validate_godot.sh` run as art approval. It is regression evidence only.
