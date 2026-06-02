# Decision 0007: Data-Driven Store Registry

Date: 2026-06-02

## Decision

`game/content/stores/store_definitions.json` is the source of truth for the
shipping store roster. `StoreRegistry` is a runtime cache seeded from
`ContentRegistry`, not a hardcoded list of store scenes.

## Current Evidence

- `StoreRegistry` is registered as an autoload in `project.godot`.
- `game/autoload/store_registry.gd` seeds via `_seed_from_content_registry()`
  and reads `ContentRegistry.get_all_store_ids()`, `get_scene_path()`, and
  `get_display_name()`.
- `StoreRegistry.resolve(store_id)` fails loud for unknown ids through
  `push_error` and `AuditLog.fail_check`.
- `scripts/validate_single_store_ui.sh` rejects `StorefrontCard`,
  `SneakerCitadel`, and `sneaker_citadel` residue in game source.
- `tests/validate_issue_019_store_registry.sh` validates registry seeding,
  unknown-id handling, and duplicate-register behavior.

## Current Roster

The current shipping roster is `retro_games`, as declared in
`game/content/stores/store_definitions.json`.
