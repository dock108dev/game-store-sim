# Validation And Signoff

## Purpose

Validation answers one question:

Does the current build deliver the fantasy of opening and operating a small early-2000s independent game store?

Automated tests prove stability. Owner review proves design success.

## Current Validation Stance

The mechanics are broadly functional. The design reset is not complete until the store read, layout, product language, density, and progression hooks match the source of truth.

## Required Evidence

Every implementation pass should produce:

- focused GUT tests for changed contracts
- full `scripts/validate_godot.sh` before completion
- updated screenshots/contact sheet
- owner screenshot review against this folder
- manual 1280x720 walk-in from entrance to checkout
- notes on what changed and what still violates the source of truth

## Primary Review Screenshots

Review these first:

- `main_scene.png`: storefront/entrance first read
- `storefront_entry.png`: entering the store and seeing interior promise
- `register_counter.png`: checkout plus trade-in center
- `stocked_aisle.png`: platform/game browsing density
- `receiving_area.png`: shipments and intake
- `backroom_summary.png`: management support without becoming the main fantasy

## Source-Of-Truth Checklist

A pass is not ready if any of these fail:

- era does not read as 2002-2004
- store reads as modern, sterile, empty, or corporate
- game inventory is not the visual focus
- platform sections are not understandable
- used games, new releases, trade-in, demo, bargain, guides/media, and checkout are missing or unclear
- the store has no obvious growth path
- money appears to unlock everything
- the environment relies on debug labels instead of fixtures, signage, and products
- customer routes do not encourage browsing

## Vertical Slice Approval

Approve only when:

- the player can operate for about 30 minutes using in-game tools
- the store feels authentic and underfunded rather than empty
- the core loop works: order, receive, stock, price, sell, trade in, review finances
- future inventory and progression are visible but locked
- owner review agrees that the store no longer feels like a prototype

## Correction Path

If review fails, classify the failure:

- era mismatch
- layout problem
- density problem
- product language problem
- storefront/counter first-read problem
- progression visibility problem
- interaction regression
- asset quality problem

Then make the smallest implementation pass that directly addresses that class. Do not broaden catalog, customers, hidden narrative, or late-era content to compensate for a weak opening store.

## Implementation Cycle

Use this cycle:

1. Pick one source-of-truth phase.
2. Implement only the assets and scene changes required for that phase.
3. Update tests and docs.
4. Run focused tests.
5. Run full validation.
6. Review screenshots.
7. Ask for owner corrections/signoff.

The next phase should not start until the current phase is stable and reviewable.
