# Validation And Signoff

## Purpose

Validation answers one question:

Does the current build deliver the fantasy of opening and operating a small early-2000s independent game store at the quality bar documented in the Visual Bible?

Automated tests prove stability. Owner review proves design success.

## Current Validation Stance

The mechanics are broadly functional. The design reset is not complete until the store read, layout, product language, fixture quality, density, and progression hooks match the source of truth and `docs/visual-bible/`.

Current owner review blocks beta/tester expansion: the integrated Visual Bible object-family pass is technically present but visually rejected. The next approval target is one isolated hero art slice screenshot that proves the art-production method can reach the target inspiration.

## Required Evidence

Every production-route implementation pass should produce:

- focused GUT tests for changed contracts
- full `scripts/validate_godot.sh` when production-route mechanics or scenes change
- updated screenshots/contact sheet
- owner screenshot review against this folder and `docs/visual-bible/`
- manual 1280x720 walk-in from entrance to checkout
- notes on what changed and what still violates the source of truth

The current hero art slice proof is different: it should produce one owner-facing screenshot first. Passing automation is not visual approval.

## Primary Review Screenshots

Review these first:

- `main_scene.png`: storefront/entrance first read
- `storefront_entry.png`: entering the store and seeing interior promise
- `register_counter.png`: checkout plus trade-in center
- product close-up: starter cases, console/accessory packaging, cover art, and price stickers
- fixture capacity: empty and stocked shelf/rack/display states
- stockroom/receiving/office: operational backroom read

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
- product cases, shelves, displays, counters, and receiving props still read as primitive assembled geometry
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

Then make the smallest implementation pass that directly addresses that class. For the current failure, that means a single isolated hero art slice. Do not broaden catalog, customers, hidden narrative, mechanics, docs, or late-era content to compensate for a weak opening store.

## Implementation Cycle

Use this cycle:

1. Pick the smallest visual proof needed.
2. Implement only the assets and scene changes required for that proof.
3. Capture owner-facing screenshots.
4. Run focused scene/doc tests.
5. Run full validation only if the production route changed.
6. Review screenshots.
7. Ask for owner corrections/signoff.

The next phase should not start until the current phase is stable and reviewable.
