# Security Report

Date: 2026-06-02

This report documents the current hardening contracts cited by code comments
and tests. It is limited to safeguards present in the current tree.

## §1 Boot Error Text Escaping

| ID | Current safeguard | Code basis |
| --- | --- | --- |
| `§1` | Boot failure text written into a BBCode-enabled label replaces literal `[` with `[lb]` before rendering, so content-loader or JSON-parser messages cannot be interpreted as BBCode tags. | `game/scripts/core/boot.gd` |

## §2 Persisted Identifier Bounds

| ID | Current safeguard | Code basis |
| --- | --- | --- |
| `§2` | Employment save loading caps persisted `employment_status` and `employer_store_id` strings at `MAX_PERSISTED_ID_LENGTH = 64` before constructing `StringName` values. Trust, approval, wage, and season fields are clamped or defaulted while loading. | `game/resources/employment_state.gd` |

## §3 Cumulative Save Collection Bounds

| ID | Current safeguard | Code basis |
| --- | --- | --- |
| `§3` | Hidden-thread save loading caps the run day range at `MAX_RUN_DAY = 30`, discovered artifacts at `MAX_DISCOVERED_ARTIFACTS = 32`, and persisted artifact ids at `MAX_PERSISTED_ID_LENGTH = 64`. Out-of-range artifact-day keys and overlong artifact ids are dropped. | `game/autoload/hidden_thread_system.gd` |

## §4 Settings Numeric Bounds

| ID | Current safeguard | Code basis |
| --- | --- | --- |
| `§4` | Settings load paths clamp display, preference, volume, keycode, text-scale, locale, and enum-shaped fields to bounded ranges. The settings file read is capped at `MAX_SETTINGS_FILE_BYTES = 262144`. | `game/autoload/settings.gd`, `tests/unit/test_settings_autoload.gd` |

## Finding IDs

| ID | Current safeguard | Code basis |
| --- | --- | --- |
| `F1` | Tutorial progress reads are capped at `MAX_PROGRESS_FILE_BYTES = 65536` before `ConfigFile.load()` handles the user-controlled `user://tutorial_progress.cfg` file. | `game/scripts/systems/tutorial_system.gd` |
| `F2` | Tutorial progress dictionaries are bounded by `MAX_PERSISTED_DICT_KEYS = 1024` and only known tutorial step ids are accepted into persisted step/tip maps. | `game/scripts/systems/tutorial_system.gd` |
| `F-09` | Save loading rejects or clamps invalid numeric values so NaN/Inf and out-of-range hand-edited save values do not poison economy comparisons or downstream calculations. | `game/scripts/core/save_manager.gd`, `tests/gut/test_save_load_numeric_hardening.gd` |
| `F-87` | Ambient-moment per-customer dedupe state is capped at `MAX_LAST_SPOTTED_ENTRIES = 64`; the oldest insertion is evicted if stale customer entries accumulate. | `game/scripts/systems/ambient_moments_system.gd` |

## Related Validation

- `tests/gut/test_save_load_numeric_hardening.gd` covers the numeric save-load
  hardening path.
- `tests/unit/test_settings_autoload.gd` covers oversized settings-file
  behavior for the settings autoload.
- `bash tests/run_tests.sh` is the maintained local gate that runs GUT and the
  shell validators when Godot is available.
