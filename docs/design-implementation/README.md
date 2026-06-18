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
| 2 | `02-visual-module-system-spec.md` | Needs owner answers | Reusable build pieces, material rules, collision rules, and scene organization. |
| 3 | `03-store-shell-and-mall-entrance-slice.md` | Not started | Opening spawn, mall concourse, storefront, entrance, and first read. |
| 4 | `04-starting-store-layout-spec.md` | Not started | Exact floor plan, zone placement, backroom relationship, and day-one density. |
| 5 | `05-fixture-grid-slice.md` | Not started | Wall shelves, gondolas, endcaps, slatwall, browse paths, and stockable fixture rules. |
| 6 | `06-checkout-and-trade-in-counter-slice.md` | Not started | Register, trade-in station, behind-counter storage, and counter clutter. |
| 7 | `07-product-and-platform-visual-language-spec.md` | Not started | Fictional product cases, platform identity, price strips, stickers, and readable facings. |
| 8 | `08-required-zones-slice.md` | Not started | New releases, used games, demo, bargain, guides/media, hardware, and receiving support. |
| 9 | `09-density-and-clutter-rules.md` | Not started | Day-one occupancy, acceptable mess, object purpose, and anti-spam rules. |
| 10 | `10-signage-branding-and-store-identity-spec.md` | Not started | Store name, brand tone, signs, posters, headers, and copy style. |
| 11 | `11-lighting-materials-and-color-palette-spec.md` | Not started | Retail mood, contrast, flooring, fixtures, materials, and palette. |
| 12 | `12-validation-and-screenshot-checklist.md` | Not started | Per-slice screenshot gates, review form, binary pass/fail language. |
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

Write `02-visual-module-system-spec.md`.

That doc must define the actual reusable construction language before heavy scene implementation resumes.
