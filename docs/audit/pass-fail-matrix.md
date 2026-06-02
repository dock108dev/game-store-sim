# Runtime Audit Pass/Fail Matrix

Date: 2026-06-02

`tests/audit_required_checkpoints.txt` is the executable source of truth for
the interaction-audit checkpoint roster. `tests/audit_run.sh` compares
structured `AUDIT: PASS <checkpoint>` and `AUDIT: FAIL <checkpoint>` lines
against that manifest and emits exactly one `AUDIT: N/M verified` summary.

## Required Checkpoints

| Area | Checkpoints |
| --- | --- |
| Boot | `boot_scene_ready`, `main_menu_ready`, `new_game_clicked` |
| Gameplay shell | `gameplay_shell_ready` |
| Transition | `transition_requested`, `scene_change_ok` |
| Store ready | `store_id_resolved`, `scene_instantiated`, `controller_ready`, `content_instantiated`, `camera_active`, `player_present`, `input_gameplay`, `objective_matches` |
| Loop | `interaction_fired`, `day_open`, `day_close` |
| Golden path | `golden_path` |

## Gate Behavior

- Missing required checkpoints fail the audit unless the active known-fail file
  explicitly lists them.
- Unexpected `AUDIT: FAIL` lines fail the audit unless explicitly known-fail.
- Known-fail entries that start emitting `PASS` fail the audit until the stale
  known-fail entry is removed.
- `scripts/generate_audit_scenario_report.py` writes the scenario report after
  log parsing.
