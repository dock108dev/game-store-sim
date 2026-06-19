# Phase Implementation Roadmap

Status: Active

## Purpose

This roadmap defines the current path from Visual Bible planning to owner validation. It replaces the old Packet 01-09 implementation sequence.

## Phase 0: Docs And Routing Cleanup

Goal: ensure agents read the current source of truth instead of deleted packet history.

Complete when:

- docs index points to Design Source, Visual Bible, implementation index, current blockers, and QA evidence
- stale alpha/beta and Packet 01-09 docs are removed from active routing
- `docs/status.json` only lists existing active docs
- docs/status GUT contract passes

## Phase 1: MVP Product Art Kit

Goal: prove products can carry the game-store fantasy.

Deliver:

- authored DVD-case mesh
- used/new case variants
- starter cover art for `Footy 2002`
- starter adventure/RPG franchise cover
- starter console box
- starter accessory/controller box
- price stickers and duplicate stack language

Validation:

- product close-up screenshot
- focused product tests
- full validation before completion if game assets/scenes changed

## Phase 2: MVP Fixture And Display Kit

Goal: prove shelves/racks/displays no longer read as primitive rectangles and rods.

Deliver:

- physical shelf/rack/display assets
- visible empty capacity
- stocked and empty states
- stocking compatibility
- snap/placement compatibility where relevant

Validation:

- empty fixture screenshot
- stocked fixture screenshot
- route/interaction tests

## Phase 3: Store Shell And Mall Interior Kit

Goal: replace prototype shell read with a clean early/mid-2000s mall store.

Deliver:

- storefront glass rhythm
- entrance/threshold trim
- drywall and carpet language
- quiet ceiling
- modest neighboring context

Validation:

- storefront/mall first-read screenshot
- 1280x720 walk-in check

## Phase 4: Counter/Register/Trade-In Kit

Goal: make checkout and trade-in read as a designed small-store workstation.

Deliver:

- straight counter/cash wrap
- POS/register/scanner/cash drawer/bags
- trade-in intake surface
- behind-counter hold/intake cues
- one-line customer queue support

Validation:

- counter/trade-in screenshot
- register/trade-in focused tests

## Phase 5: Stockroom/Receiving/Office Kit

Goal: make the backroom a real office + storage + receiving space.

Deliver:

- receiving area
- clean storage racks
- setup boxes
- office desk/computer/calendar
- sales-floor threshold/employee-only read

Validation:

- stockroom/receiving/office screenshot
- receiving/backroom interaction tests

## Phase 6: Minimal Signage And Store Identity Kit

Goal: support the store with restrained legal-safe signage after objects can read on their own.

Deliver:

- editable `Games4U` sign
- grand-opening sign
- open/closed sign support
- shelf labels
- restrained promo posters

Validation:

- sign readability screenshot
- legal-safe name review

## Phase 7: Playable Store Integration

Goal: replace primitive visible objects in the playable route while preserving mechanics.

Deliver:

- integrated product/fixture/shell/counter/stockroom/signage assets
- route cleanup
- screenshot review board
- updated blockers/status

Validation:

- focused tests
- `scripts/validate_godot.sh`
- owner review against 7.5/10 target

## Phase 8: Owner Review

Owner options:

1. Approve the object-family direction and continue integration.
2. Request targeted revisions to one or more object families.
3. Block the method and change art-production approach before more integration.

Tester/beta readiness remains blocked until the owner approves the MVP visual baseline.
