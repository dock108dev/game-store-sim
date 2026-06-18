# Screenshot Review

This is the screenshot evidence procedure for the current design/visual approval gate.

The question is not whether the project is mechanically complete. The question is whether the opening route reads as a small, underfunded, functional 2002-2004 independent game store with visible growth potential.

Use this after an implementation packet or [Validation And Screenshot Checklist](../design-implementation/12-validation-and-screenshot-checklist.md) calls for screenshots. Do not use this file as an independent implementation roadmap.

The current automated screenshot/contact-sheet set is provisional regression evidence. It was built during the graybox era, so a passing contact sheet or green `validate_godot.sh` run does not approve the design reset. Packet 07/08 may replace or expand screenshot targets when needed to judge the actual opening-store visual bar.

## Generate

Run:

```text
scripts/validate_godot.sh
```

Screenshots are written to `artifacts/validation/latest/screenshots/`.

Contact sheet:

```text
artifacts/validation/latest/screenshot-contact-sheet.png
```

## Primary Review Targets

- `main_scene.png`: storefront/entrance first read
- `storefront_entry.png`: entering the store and seeing interior promise
- `register_counter.png`: checkout plus trade-in center
- `stocked_aisle.png`: platform/game browsing density
- `receiving_area.png`: shipments and intake
- `backroom_summary.png`: management support without becoming the main fantasy

## Pass Criteria

Pass only if:

- the first view reads as a 2002-2004 specialty game store
- the store feels new, underfunded, understocked, promising, and operational
- storefront identity comes from facade, glass, trim, sign housing, mall context, and fictional store branding
- register/counter reads from silhouette, equipment, material, grouped props, and trade-in staging
- used games, new releases, platform sections, demo, bargain, guides/media, checkout, and receiving support are understandable
- product/fixture identity comes from rows, cases, boxes, stickers, posters, signs, and fixture design
- opening density is limited but intentional: 25-40% wall occupancy and 30-50% floor occupancy
- future growth is visible without future inventory physically sitting in the store
- large debug labels are not required to understand primary objects
- the 1280x720 real-window walk-in does not expose a prototype-heavy angle
- Packet 06 signage should show `Games4U` as the storefront default, a real closed/open sign state, attached shelf labels, and fictional promo posters without reviving debug label cards.

## Fail Criteria

Fail if:

- the scene reads as modern, sterile, empty, corporate, or abandoned
- the store does not communicate early-2000s game retail
- text labels are required to understand primary objects
- props look like scattered primitive clutter
- product/fixture identity is not readable before labels
- future inventory appears physically staged before it is purchased, unlocked, received, released, or traded in
- a visual module blocks movement or interaction

## Routing

If the review fails, keep work inside [Phase Implementation Roadmap](../design-implementation/14-phase-implementation-roadmap.md). Do not expand catalog, customer, decoration, hidden narrative, later-era, or external-playtest work to compensate for a weak opening store.
