# Abend Handling Audit

Date: 2026-05-31

This audit records the current handled-error contracts that are intentionally
allowed to continue after a warning, error, fallback, or soft gate. It is a
current-state reference, not a remediation backlog.

## Source Basis

- CI and local gates: `tests/run_tests.sh`, `scripts/run_godot_tests.sh`,
  `tests/audit_run.sh`, `scripts/render_nightly_videos.sh`, and
  `.github/workflows/*.yml`.
- Boot and content loading: `game/scripts/core/boot.gd`,
  `game/autoload/data_loader.gd`, and `game/autoload/content_registry.gd`.
- Runtime state and persistence: `game/scenes/world/game_world.gd` and
  `game/scripts/core/save_manager.gd`.
- Store-session, checkout, visual, and audio fallbacks:
  `game/scripts/store_session/store_session_controller.gd`,
  `game/scripts/systems/checkout_system.gd`,
  `game/scripts/visuals/product_visual_catalog.gd`,
  `game/scripts/visuals/store_visual_layout.gd`,
  `game/scripts/visuals/product_visual_factory.gd`,
  `game/scripts/visuals/store_visual_kit.gd`, and
  `game/autoload/audio_manager.gd`.

## Current Contracts

| Area | Current behavior | Disposition |
| --- | --- | --- |
| Headless GUT shutdown noise | `scripts/run_godot_tests.sh` filters documented Godot renderer/object cleanup noise, then trusts GUT's `All tests passed` summary and separately fails on unexpected `ERROR:` lines. Expected project-owned `push_error` patterns are allowlisted in the script. | Retained. The script keeps engine teardown noise out of the CI signal while preserving a project-owned unexpected-error gate. |
| Local test fallback without Godot | `tests/run_tests.sh` runs static guards and shell validators when no Godot binary is resolved. If `GODOT` or `GODOT_EXECUTABLE` is set but invalid, the runner exits with an error. | Retained. This keeps non-Godot static validation usable on developer machines without pretending a configured-but-missing Godot binary is valid. |
| Interaction audit without Godot | `tests/audit_run.sh` allows a local skip when no Godot binary is configured, but exits with an error when `CI=true` and Godot is missing. | Retained. Local ergonomics and CI enforcement are intentionally different. |
| Weekly visual review | `.github/workflows/nightly.yml` marks the visual snapshot lane `continue-on-error: true`; `scripts/run_store_visual_sweep.sh` writes captures and reports missing baselines without failing when the reviewed baseline bucket is absent. | Retained. The weekly visual lane is advisory; blocking validation remains in the PR/main and release gates. |
| Nightly video timeout | `scripts/render_nightly_videos.sh` uses `timeout` or `gtimeout` when available and hard-fails in CI if neither command is present. Outside CI, it can fall back to the surrounding process/job timeout. | Retained. CI gets an explicit timeout requirement; local/manual runs keep a fallback. |
| Boot content loading | `DataLoaderSingleton.load_all()` scans `res://game/content/`, requires a root `"type"` field, caps JSON reads at `1 MiB`, aggregates load errors, and boot stops in `boot.gd` before the main menu when content errors remain. | Retained. Boot content errors are fail-loud and visible in the boot error panel. |
| Store-session content loading | `StoreSessionController._load_content()` treats Day 1 and event JSON as required. `_load_json(path, required)` escalates missing required files with `push_error`; optional future-day placeholders remain warning-only. Open, oversized, and malformed JSON errors are `push_error` paths. | Retained. Required Day 1 content fails loud; optional content-strip placeholders stay recoverable. |
| GameWorld state validation | `GameWorld` state validation emits `push_error` for invariant failures and also sends a player-visible notification, while keeping gameplay running. Empty starter inventory for the configured starting store aborts new-game bootstrap with an error and notification. | Retained. Core starter-stock failure blocks the run; other validation drift remains nonblocking but visible. |
| Save section handling | `SaveManager` reads save sections only when they are dictionaries. Wrong-typed sections and present sections whose optional owner is not wired emit once-per-key warnings through `_warn_save_handling_once()`. | Retained. The loader preserves compatibility while surfacing unexpected present-but-unusable sections. |
| Save write/load failure | Save write, migration, slot-index, and invalid-load paths warn or error, return failure, and emit player-facing or event-bus feedback where the owning method defines it. Save-file reads are capped at `10 MiB`. | Retained. Save integrity paths fail closed instead of silently accepting corrupt or unsupported data. |
| Visual catalog/layout loading | `ProductVisualCatalog.load_from_path()` and `StoreVisualLayout.load_from_path()` return catalog objects with `load_error` and emit `push_warning` for missing or malformed visual JSON. | Retained. Catalog-wide failure is visible without making `DataLoader` boot-block on visual-only product art or generated-layout data. |
| Generated store physical-contract fallback | `StoreVisualLayout.validate_physical_contract()` reports data-level physical-contract errors through `StorePhysicalContractValidator` and `StoreRoomContractValidator`. `ExpandableStoreShellRuntime` warns and uses local fallback coordinates when a referenced physical-contract value is missing or malformed at runtime. | Retained. Layout-contract tests keep authored data strict; runtime fallback keeps a store scene recoverable if optional visual-layout metadata is unavailable. |
| Product visual fallback | `ProductVisualFactory` and `StoreVisualKit` can return `null` or placeholder visuals when optional product-art resources, templates, or fixture assets are missing. | Retained. Presentation fallback is allowed because gameplay identity and inventory state are owned elsewhere. |
| Checkout invalid sale inputs | `CheckoutSystem.initiate_sale()` warning-returns for null customer/item or non-positive sale price and emits `EventBus.checkout_failed`. | Retained. Existing tests exercise the warning-return contract; the failure event makes the dropped sale observable. |
| Checkout invalid queue payload | `_on_checkout_queue_ready()` warns and emits `EventBus.checkout_failed` before completing a non-`Customer` queue payload. | Retained. Completion remains non-crashing, but bad payloads are no longer silent. |
| Modal focus recovery | `ModalPanel` double-open and corrupt-pop paths are `push_error` contracts; freeing an open modal auto-pops the modal focus frame. `ModalQueue` clears before scene swaps. | Retained. Input recovery takes precedence over crashing a run, and ownership drift remains CI-visible through `ERROR:` output. |
| Settings and difficulty persistence | Settings and difficulty systems clamp or default malformed persisted values and continue after warning/error paths. | Retained. Bad user config does not block play or corrupt game content. |
| Audio path fallback | `AudioManager` warns for unknown SFX or missing audio paths and rejects registry paths containing `..`. | Retained. Missing audio is cosmetic; traversal-like registry content is rejected before load. |
| Debug and dev-only helpers | Debug overlays, debug camera affordances, and force-place / force-complete helper paths are gated by debug build/project settings or no-op in release. | Retained. Release builds are intentionally quieter and less permissive. |

## Current Risk Posture

Critical and high severity hidden-failure classes are not documented here
because the reviewed current contracts either fail loud, warn once, emit a
structured event, show a player notification, or are confined to advisory
automation and presentation-only fallback.

The remaining accepted risk is operational visibility: `push_warning` and
`push_error` are not always player-facing in release builds, and advisory
workflow artifacts rely on review discipline. The current CI contracts cover
unexpected GUT `ERROR:` output, required audit checkpoints, static repository
guards, resource integrity, GDScript lint, fresh-install smoke, and release
export validation.

## Escalations

None.
