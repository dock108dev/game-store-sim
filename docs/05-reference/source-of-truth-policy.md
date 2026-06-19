# Source Of Truth Policy

## Purpose

This repo is both documentation repo and future implementation repo.

Markdown docs are the default source of truth for design, production, validation, and technical decisions.

## Canon Layers

### Current Production Truth

`docs/MASTER_PLAN.md` and `docs/06-decisions/` define current production direction.

### Build Specs

`docs/01-design/`, `docs/02-technical/`, `docs/03-production/`, and `docs/04-validation/` define what to build and how to verify it.

### Player-Facing Canon

`game-guide/` describes the long-form intended player experience. It is a validation source, but not every word is final.

### Inspiration

`real_inspiration/` and `other_game_inspiration/` are references to extract from, not assets to copy.

## Change Policy

If a production doc conflicts with `game-guide/`:

1. identify the conflict
2. decide whether guide or production doc should change
3. update the relevant doc
4. add a decision record if the change affects major direction

## Decision Records

Use `docs/06-decisions/` for decisions that are expensive to reverse.

Examples:

- engine choice
- platform target
- IP policy
- first playable scope
- save format
- rendering/art scale
- distribution path

## File Format Policy

Use Markdown for:

- design docs
- technical plans
- validation checklists
- milestone plans
- decision records
- source maps

Use other formats only when needed:

- source images
- engine assets
- generated screenshots
- exported builds
- spreadsheets only if formulas become important

If a PDF or Word-style artifact is needed later, generate it from Markdown instead of making it the source.

