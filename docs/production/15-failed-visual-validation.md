# Failed Visual Validation

Status: Active blocker
Date: 2026-06-19
Decision: Block the current MVP Visual Bible object-family pass

## Decision

The current pass is technically integrated but visually rejected.

`scripts/validate_godot.sh` passed, but that does not mean the visual direction passed. The validation script is now treated as regression evidence only. It cannot define visual progress, art approval, beta readiness, or whether the store is close to the inspiration.

## Why It Failed

Latest screenshots still read as primitive Godot geometry:

- products read as simple shapes and tiny labels, not convincing game merchandise
- fixtures still feel like assembled rectangles and rods
- walls and ceiling still look like flat graybox surfaces
- storefront is cleaner but still not enough to carry the fantasy
- counter and backroom remain block-built and sparse
- contact sheet proves stability, not art quality

Owner feedback: this is “just not working or really doing much.”

## Blocked Work

Do not continue:

- broad agents touching mechanics
- broad playable-store polish
- beta/tester preparation
- full catalog visuals
- customer or employee visuals
- hidden narrative visuals
- decoration breadth
- more validation-script-driven visual passes

## Required Pivot

Next work is one strict isolated hero art slice.

The slice must prove one screenshot before any broad implementation continues:

- mall/storefront exterior or concourse read
- first 15-20 feet inside the shop
- one believable counter
- one believable fixture
- 2-3 believable game cases or boxes
- authored mesh and bitmap/detail workflow
- no customers
- no employees
- no full catalog
- no gameplay mechanics expansion
- no broad docs rewrite

## Pass Criteria

The hero slice passes only if the owner can look at one screenshot and say the store finally resembles the target inspiration enough to build from that method.

Automated tests may confirm the scene loads, but they do not approve the art.
