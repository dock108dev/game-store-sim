# Visual Bible Implementation Review

Status: Active
Purpose: Review plan for the next MVP object-family implementation pass

## Current Position

The current playable store is a mechanics prototype. The next implementation pass should build MVP object families from `docs/visual-bible/` and then integrate them into the playable route.

The review goal is not beta readiness. The review goal is to answer:

> Does the MVP object-family pass move the store from a primitive 4.5/10 read toward the 7.5/10 Visual Bible target?

## Required Implementation Evidence

Each Visual Bible packet should produce:

- changed files summary
- focused tests for changed contracts
- screenshots from the game window when the scene changes
- notes on what was authored in Blender/asset pack/Godot
- explicit list of remaining primitive placeholders
- full `scripts/validate_godot.sh` before completion for implementation packets

Docs-only packet assembly can use the focused docs/status GUT test.

## Required Review Screenshots

The next visual implementation pass should capture larger, owner-facing screenshots for:

- product close-up: starter game cases, console box, accessory package, price sticker, cover art
- empty fixture capacity: shelf/rack/display with visible open slots
- stocked fixture capacity: same fixture with starter stock placed
- storefront/mall first read
- checkout/trade-in counter
- stockroom/receiving/office
- first-person walk-in at 1280x720 or larger

The old contact sheet may still be generated as regression evidence, but it is not the visual approval artifact.

## Review Criteria

Pass only if:

- products read as legal-safe video game merchandise before labels
- fixtures read as physical retail objects, not primitive racks
- empty starter state feels intentional and promising
- store shell reads as clean early/mid-2000s mall retail
- counter/trade-in/receiving areas communicate their function from object design
- signage is restrained and supportive
- routes and interactions still work
- future catalog or locked inventory is not physically staged as owned stock

Fail if:

- the scene still depends on large labels to explain objects
- shelves or displays are still rectangles with a few rods or cubes
- cover art is not recognizable enough from first-person distance
- day-one stock looks like a future-state full store
- the playable store becomes less usable while improving screenshots

## Owner Decision Options

After a Visual Bible implementation pass:

1. Approve the object-family direction and continue integration.
2. Request targeted revisions to one or more object families.
3. Block the method again and change art-production approach before more integration.

## Current Next Review

The first review should focus on product art and fixture/display quality. If those still fail, broader store-shell polish will not solve the core visual problem.
