# Visual Blockers

Status: Active
Scope: MVP + first-store visual rebuild

This is not an alpha or beta bug list. It tracks blockers that prevent the opening store from reaching the Visual Bible target.

## Current Gate

Owner review blocked the first Visual Bible object-family implementation pass. Automated validation is green, but the screenshots still read as primitive Godot box geometry and do not meet the target inspiration.

The active target is:

- `docs/design-source-of-truth/`
- `docs/visual-bible/`
- `docs/design-implementation/work-packets/00-packet-index.md`

External beta/tester packaging remains blocked until a strict isolated hero art slice produces an approved screenshot.

## Open Blockers

| ID | Priority | Area | Problem | Required Resolution |
| --- | --- | --- | --- | --- |
| VIS-020 | P0 | Failed visual validation | The integrated object-family pass is technically present but visually rejected; it still reads boxy, primitive, and label-dependent. | Treat this pass as a failed visual validation and stop broad implementation. |
| VIS-021 | P0 | Hero art slice missing | The project does not yet have one screenshot that proves the desired art-production method. | Build one isolated hero art slice before any more broad mechanics, docs, or playable-store work. |

## Resolved Or Demoted

| ID | Area | Resolution |
| --- | --- | --- |
| VIS-001 | Documentation routing | Current routing is design source -> Visual Bible -> implementation packet index -> production/QA evidence. |
| VIS-005 | Store identity | `Games4U` remains editable default; legal-safe branding rules are documented in the Visual Bible. |
| VIS-006 | Screenshot evidence | Existing contact sheet remains regression evidence only, not art approval. |
| VIS-011 | Packet 08/09 review | Old packet docs were deleted from the active tree; their outcome is summarized as reference evidence only. |
| VIS-012 | Art-production method | Prior primitive/art-kit method was blocked; the follow-up object-family pass also failed visual validation. |
| VIS-013 | Product art | Implemented technically, but not accepted as visual baseline. Future product work must be proven inside the hero art slice first. |
| VIS-014 | Fixtures/displays | Implemented technically, but not accepted as visual baseline. Future fixture work must be proven inside the hero art slice first. |
| VIS-015 | Store shell | Implemented technically, but not accepted as visual baseline. Future shell work must be proven inside the hero art slice first. |
| VIS-016 | Counter/trade-in | Implemented technically, but not accepted as visual baseline. Future counter work must be proven inside the hero art slice first. |
| VIS-017 | Stockroom/receiving | Implemented technically, but not accepted as visual baseline. Future backroom work must be proven only after hero slice approval. |
| VIS-018 | Signage | Implemented technically, but not accepted as visual baseline. Signage cannot carry object readability. |
| VIS-019 | Owner visual review | Completed: owner rejected the object-family pass and ordered a hero art slice pivot. |

## Stop Conditions

Do not start broad catalog, customer visuals, employee visuals, decoration breadth, hidden narrative, later-era, beta/tester work, playable-store polish, or broad mechanics work while VIS-020 and VIS-021 are open.

Do not use a passing `scripts/validate_godot.sh` run as art approval or visual progress. It is regression evidence only.
