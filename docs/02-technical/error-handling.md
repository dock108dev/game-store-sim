# Error handling and recovery

This describes the September 23 source maintenance checkout based on `8b84f8f621af0613b08fbb9051ee6aec0548d51c`. It is **not included in the frozen B9 app under B10 owner review**. The separate checkout is `/Users/michaelfuscoletti/.codex/worktrees/abend-handling/game-sim`. No schema, economy, owner save, artifact or acceptance status changed.

## Runtime contract

Business commands still reject invalid/stale/unavailable actions with false or their existing structured result. These are expected gameplay outcomes, not exceptions. Claims, event identities and phase checks still prevent duplicate purchases, sales and settlements. Staff restore cancels unfinished execution claims while preserving inventory and buyer reservations. No automatic transaction retry is added.

A checkpoint writes a temporary file, flushes, checks the I/O result and renames it over the destination. Invalid existing checkpoints are preserved. Failure leaves the business transaction live and the previous successful checkpoint intact; `save_pending` and `last_save_ok` distinguish that from persistence success. Retry saves current state without replaying the business command. A missing configured checkpoint path now also sets failure status accurately. Load validates a candidate before publishing it; a read error, malformed JSON or integrity failure leaves the current session unchanged. Terminal restart retains its archive/conflict gate.

For a separate `week-*.json`, checkpoint persistence and `active-week.txt` publication are separate operations. A failed locator update means **the week is saved but Continue has not been updated**. Save and quit stays open with a retry dialog. Restart and ordinary Save retain the warning instead of replacing it with success text. A Continue click whose previously valid checkpoint has become unavailable now gives an explicit failure message in the entry menu.

## Diagnostics and response

Each failed storage attempt prints `STORAGE_FAILURE` with operation, stage and numeric Godot error code. State failures also retain `last_storage_error` and a per-instance failure count (`attempt`); successful save/load clears the last error. Stages distinguish opening, reading, parsing, integrity, temporary-file writing/flushing, replacement, missing target and terminal conflict. These records contain no file contents, JSON parser excerpts, absolute paths or business payloads. There is no log throttling or remote telemetry. Existing development action/report logs remain unchanged and should be treated as local session data.

- For a failed checkpoint, keep the app open, check available disk space and folder access, then use Retry save. Do not repeat a business transaction to repair storage.
- For a locator failure, the dialog names the saved checkpoint's basename. Repair access/space and retry Save before quitting. The state save flag can legitimately say saved while locator publication is pending.
- Preserve malformed/incompatible originals. New week uses a separate file; do not delete or migrate an owner checkpoint as a troubleshooting shortcut.
- For an integrity or repeated terminal-conflict failure, retain the attempt and logs for engineering review. Do not replace the terminal archive.

Atomic replacement is not a power-loss durability guarantee. No directory fsync, multi-process locking or automatic temporary-file recovery is provided. Leftover `.tmp` files are not successful checkpoints. Locator publication and checkpoint replacement are not one filesystem transaction; a process/OS crash between them can still require manual recovery. Owner-file inspection/recovery requires its own concrete authorization.

## Validation tool behavior

`python3 encounter/scripts/validate.py` copies the project into a unique synthetic namespace before launching Godot. It now also runs `test_storage.gd`. `run_check` rejects nonzero exits and Godot error logs even when Godot returns zero. Expected recovery diagnostics and ordinary warnings do not themselves fail a suite; assertions must verify the resulting state. Warnings remain in retained logs.

Timeout (900 seconds), launch failure and keyboard interruption now write `<check>-exit.json` with `exit: null` and `status: timeout`, `launch_failed` or `interrupted`, then propagate the original exception. This cannot be mistaken for exit zero. `subprocess.run` owns killing/reaping its direct child on timeout/interruption; no descendant process-tree guarantee is added. Partial logs remain available. An interrupted run is not a pass, and its temporary project can contain additional results not yet copied into final evidence. `context.json` identifies it. Exception records omit command/output text; the local traceback and raw engine log remain private engineering diagnostics.

## Review coverage and retained boundaries

The repository search covered tracked GDScript, Python and shell sources, including current runtime, validators, captures/build tools, historical `game/`, samples and Blender asset tooling. Current runtime has no exception-catching language construct, network service, scheduler, queue worker, provider client or environment-based warning filter. Its principal recovery boundaries are typed business rejections, save/load and UI session flow.

Deliberate resilience retained: false/structured gameplay rejections, failed-checkpoint retry, terminal preservation, cancellation of unfinished claims, missing-checkpoint startup and warning-only validation logs. Invalid checkpoint probes may produce repeated diagnostics because each actual attempt is recorded. Existing schema validation and source organization remain together per the maintenance decision.

Historical Blender tools still include an EEVEE-to-Workbench broad fallback and suppressed collection-link errors. They are not the active game/render pipeline; before reactivating them, narrow engine capability handling, report the actual renderer and fail on unexplained link failures. Historical root shell validation overwrites its `latest` evidence and must not be used for this pass. Export/packaged qualification and historical capture wrappers retain their own subprocess behavior, including some unbounded export steps; consolidate bounded failure records when those workflows are next authorized. No artwork rebuild, signing, packaging or frozen-evidence rewrite was performed here.

## Verified source changes

[Retained isolated evidence](../../encounter/evidence/abend-20260923T134545761299Z/context.json) binds the executable source tested with Godot 4.6.2:

| Check | Result |
| --- | --- |
| Headless editor import/compile | Passed |
| Storage failures/recovery | 9 checks passed |
| Week state and shared regressions | 706 + 86 checks passed |
| Headless presentation, including unavailable Continue and locator open/rename failure | 32 recorded checks passed |
| Terminal restart and malformed-save flow | 10 recorded checks passed |
| Python validation wrapper | 5 tests passed, including timeout, interruption and launch-failure records |

All six Godot processes exited zero with no engine/script errors or warnings. Storage-failure records are expected injected failures. Python syntax and whitespace checks passed. No rendered/Retina run, full-week scene suite, packaged app, real-audio, power-loss/disk-full hardware simulation or owner acceptance was performed. A future replacement app needs separate packaging qualification and an identified resumed owner review; the existing B10 candidate remains unchanged.
