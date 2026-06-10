# Release Package Check

Use this only after screenshot review passes.

## Preconditions

- `scripts/validate_godot.sh` passes.
- `docs/qa/screenshot-review.md` passes.
- `docs/production/13-alpha-bug-list.md` has no open P0 issue.
- The external handoff remains `docs/production/15-alpha-playtest-package.md`.

## Pack Smoke

Run:

```text
scripts/verify_desktop_export.sh --pack-smoke
```

Pass if:

- `artifacts/builds/desktop/game-store-sim.pck` exists and is nonempty.
- The verifier reports a successful pack boot smoke.
- Logs are present under `artifacts/builds/desktop/`.

## Manual Build Review

The pack smoke is not a signed app release. Before sending to a tester, confirm:

- Godot export templates are available on the release machine.
- Any macOS binary export/signing limitation is named in the handoff.
- Start, save, quit, relaunch, and continue work in the actual distributed build.
- Settings and window-mode choices remain readable after relaunch.

## External Handoff

Before reopening the alpha package:

1. Rerun `scripts/validate_godot.sh`.
2. Run this release package check.
3. Confirm `docs/production/15-alpha-playtest-package.md` still names build commands, artifact paths, known issues, feedback form, rollback plan, and the shorter tester script.
4. Confirm rollback checkpoints are still meaningful for the current branch.

Keep the package paused if binary export, save/load relaunch, screenshot review, or a P0/P1 readability issue fails.
