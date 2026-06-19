# Work Packet Index

Status: Active
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`

## Purpose

This file is the current packet queue for the Visual Bible rebuild.

The old Packet 01-09 files were deleted from the active tree because they described the rejected graybox/art-kit/polish sequence. The useful lessons from those packets are now summarized here and in the Visual Bible. Agents should not recreate the old sequence or treat deleted packet names as the next work.

## Required Read Order

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/visual-bible/README.md`
4. `docs/visual-bible/09-mvp-object-implementation-checklist.md`
5. `docs/design-implementation/README.md`
6. `docs/design-implementation/13-agent-work-packet-template.md`
7. This packet index

## Legacy Packet Outcome

| Legacy packet group | Outcome |
| --- | --- |
| Packet 01-08 | Implemented enough to prove mechanics and store anchors, but not enough for the target visual bar. Deleted as active instructions. |
| Packet 09 | Improved the direction but still rated around 4.5/10 by owner review. Deleted as active instruction and retained only as reference evidence in current state/production notes. |

Hard lessons carried forward:

- Do not polish the existing primitive store as the final visual source.
- Do not rely on labels to make objects understandable.
- Do not add random wall clutter to hide blankness.
- Do not stage locked/future inventory as if it already exists.
- Do not let `scripts/validate_godot.sh` or the contact sheet approve art quality.
- Build authored object families first, then integrate.

## Current Packet Queue

| Order | Packet to create | Primary Visual Bible docs | Result |
| ---: | --- | --- | --- |
| 1 | MVP product art kit | `03-product-art-and-packaging.md`, `04-fictional-platforms-and-games.md`, `09-mvp-object-implementation-checklist.md` | Starter DVD cases, cover art, console/accessory packages, price stickers, stack language, close-up screenshot. |
| 2 | MVP fixture and display kit | `02-fixtures-and-displays.md`, `09-mvp-object-implementation-checklist.md` | Shelves/racks/displays with 10-30 item capacity, empty slots, authored silhouettes, stocking compatibility. |
| 3 | Store shell and mall interior kit | `01-store-shell-architecture.md`, `07-signage-marketing-and-store-identity.md` | Clean mall storefront, drywall, carpet, ceiling, storefront trim, modest neighboring context. |
| 4 | Counter/register/trade-in kit | `05-counter-register-and-trade-in.md` | Straight counter, POS, scanner, bags, cash drawer, trade-in/intake staging, one queue route. |
| 5 | Stockroom/receiving/office kit | `06-stockroom-receiving-office.md` | Real backroom, receiving area, clean storage racks, office desk/computer/calendar, day-one delivery state. |
| 6 | Minimal signage/store identity kit | `07-signage-marketing-and-store-identity.md`, `04-fictional-platforms-and-games.md` | `Games4U`, grand-opening sign, shelf labels, legal-safe promos, readable but restrained copy. |
| 7 | Playable store integration | All Visual Bible docs | Replace primitive visible objects in the playable route while preserving current mechanics. |
| 8 | Owner review package | `08-art-production-pipeline.md`, production/QA docs | Screenshots, notes, validation, blocker update, approve/revise/block path. |

## Packet Creation Rules

Use `docs/design-implementation/13-agent-work-packet-template.md`.

Each packet must include:

- exact Visual Bible docs to read
- files likely to change
- asset authoring requirements
- tests to add/update
- screenshot evidence
- acceptance checklist
- stop/ask-owner conditions
- commit expectation

## Validation Rule

Docs-only packet assembly can use focused doc/status tests.

Implementation packets must run:

```text
scripts/validate_godot.sh
```

The gate proves regression stability only. Owner visual review proves whether the 7.5/10 art target is met.
