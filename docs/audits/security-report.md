# Security Report

Date: 2026-06-02

This report documents the current hardening contracts cited by code comments
and tests. It is limited to verifiable safeguards present in the current tree.

## Findings

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
