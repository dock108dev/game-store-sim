# Design Implementation Index

## Purpose

This folder turns `docs/design-source-of-truth/` into agent-ready implementation work.

The source-of-truth docs define the target. This folder defines how work is sliced, sequenced, validated, and handed off so multiple implementation passes can move quickly without drifting back into graybox, art-kit-only, or broad-content work.

## Authority

If this folder conflicts with `docs/design-source-of-truth/`, the design source of truth wins.

If a slice cannot satisfy the design source of truth without changing a core gameplay mechanic, stop and record the decision point before continuing.

## Implementation Policy

- Work may start on a slice once its dependencies are complete.
- Work does not need final owner signoff before the next dependent slice starts, but every slice must end in a reviewable state.
- Commit after each completed slice for tracking.
- Keep working through the roadmap until a validation failure, design decision, or implementation blocker requires owner input.
- Preserve existing mechanics while replacing the visual/design surface.
- Do not broaden catalog visuals, customers, decoration breadth, hidden narrative, later-era content, or external playtest packaging until the opening store baseline is reviewable against the design source of truth.

## Agent Operating Rules

Every implementation agent should:

1. Read `docs/CURRENT_STATE.md`.
2. Read `docs/design-source-of-truth/README.md`.
3. Read this index.
4. Read the current slice packet and all dependency packets.
5. Make only the changes required for the current slice.
6. Update docs/tests that describe changed behavior or validation.
7. Run focused tests for changed contracts.
8. Run `scripts/validate_godot.sh` before marking the slice complete.
9. Commit the completed slice.

Do not use visible debug labels, loose primitive clutter, or future inventory staging as a shortcut for store readability.

## Running Document List

| Order | Document | Status | Purpose |
| ---: | --- | --- | --- |
| 1 | `README.md` | Complete | Implementation index, operating rules, slice order, and dependency policy. |
| 2 | `02-visual-module-system-spec.md` | Complete | Reusable build pieces, material rules, collision rules, and scene organization. |
| 3 | `03-store-shell-and-mall-entrance-slice.md` | Complete | Opening spawn, mall concourse, storefront, entrance, and first read. |
| 4 | `04-starting-store-layout-spec.md` | Complete | Exact floor plan, zone placement, backroom relationship, and day-one density. |
| 5 | `05-fixture-grid-slice.md` | Complete | Starter wall shelves/racks, movable purchasable fixtures, labels, visible capacity, and snap placement rules. |
| 6 | `06-checkout-and-trade-in-counter-slice.md` | Complete | Shared checkout/trade-in station, clean register setup, one-line queue, and behind-counter hold/intake storage. |
| 7 | `07-product-and-platform-visual-language-spec.md` | Complete | Legal-safe fictional platforms, two-tone case language, cover art, stickers, prices, and starter titles. |
| 8 | `08-required-zones-slice.md` | Complete | Inventory-source zones, player labels, demo placement, hardware/receiving rules, and first-use guidance. |
| 9 | `09-density-and-clutter-rules.md` | Complete | Empty-promising day-one density, setup clutter, stockroom planning desk, console box stacks, and visual-review rules. |
| 10 | `10-signage-branding-and-store-identity-spec.md` | Complete | Editable store name, early-2000s mall signage, shelf labels, posters, neighboring signs, and copy tone. |
| 11 | `11-lighting-materials-and-color-palette-spec.md` | Complete | Bright store lighting, warmer mall lighting, commercial carpet, editable panels, fixture materials, and palette rules. |
| 12 | `12-validation-and-screenshot-checklist.md` | Complete | Screenshot-first validation, final game-window review, detailed notes, fail language, and docs-only skip rules. |
| 13 | `13-agent-work-packet-template.md` | Not started | Standard template for every implementation packet. |
| 14 | `14-phase-implementation-roadmap.md` | Not started | Master dependency map from planning through owner validation. |

## Dependency Model

Slices should generally follow this order:

1. Visual module system.
2. Store shell and mall entrance.
3. Starting store layout.
4. Fixture grid.
5. Checkout and trade-in counter.
6. Product and platform visual language.
7. Required zones.
8. Density, clutter, signage, lighting, and validation polish.

Later slices may start when their dependencies are complete. For example, product visual language can begin once fixture scale and platform-section rules are stable; it does not need to wait for every checkout prop.

## Slice Completion Definition

A slice is complete when:

- the requested assets/scenes/code are implemented
- mechanics touched by the slice still work
- docs reflect the current behavior
- focused tests pass
- full `scripts/validate_godot.sh` passes
- screenshots/contact sheet are regenerated
- the slice is committed
- any owner decision points are documented clearly

Owner signoff can happen after the slice is complete. Approval is not required to continue non-conflicting dependent work, but rejected visuals must be corrected before broadening scope.

## Standard Slice Packet Sections

Each future slice doc should include:

- Goal
- Player-facing result
- Dependencies
- In scope
- Out of scope
- Required assets/modules
- Likely scene files
- Likely script files
- Tests to add or update
- Screenshot targets
- Acceptance checklist
- Stop/ask-owner conditions
- Commit expectation

## Current Next Step

Write `13-agent-work-packet-template.md`.

That doc must define the standard work packet format implementation agents should use for each future code/asset pass.
