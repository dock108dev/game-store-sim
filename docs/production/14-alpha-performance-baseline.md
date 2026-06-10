# Alpha Performance Baseline

This is the Stop 13.2 performance pass. It records the current repeatable smoke metrics and the broad regression thresholds enforced by `scripts/measure_alpha_performance.sh`.

Run from the repository root:

```text
scripts/measure_alpha_performance.sh --full
```

The full validation gate runs the same smoke as `scripts/measure_alpha_performance.sh --skip-export` after `scripts/verify_desktop_export.sh --pack-smoke` has created the desktop pack.

Artifacts:

- Core Godot metrics: `artifacts/performance/latest/alpha-performance-core.json`
- Shell/export metrics: `artifacts/performance/latest/alpha-performance-shell.json`
- Timed screenshot: `artifacts/performance/latest/performance-main-scene.png`
- Screenshot log: `artifacts/performance/latest/performance-screenshot.log`
- Pack startup log: `artifacts/performance/latest/performance-pack-startup.log`

## Current Metrics

Latest measured values from Stop 13.2:

| Metric | Current | Threshold | Source |
| --- | ---: | ---: | --- |
| Main scene resource load | 141 ms | 5000 ms | Godot performance tool |
| Main scene instantiate | 23 ms | 5000 ms | Godot performance tool |
| Main scene settle, 5 frames | 53 ms | 5000 ms | Godot performance tool |
| Main scene 60-frame step | 413 ms | 5000 ms | Godot performance tool |
| UI panel cycle | 43 ms | 1500 ms | Godot performance tool |
| Customer pathing, 100 ticks | 4 ms | 1000 ms | Godot performance tool |
| Save codec encode/decode/restore | 0 ms | 1000 ms | Godot performance tool |
| Main-scene screenshot capture | 930 ms | 20000 ms | Shell wrapper |
| Exported pack startup | 413 ms | 15000 ms | Shell wrapper |

The thresholds are intentionally broad alpha regression guards. They are not final performance budgets. Tighten them only after the content pass stabilizes scene density.

## Coverage

The performance smoke covers:

- Main scene resource loading, instantiation, settle frames, and 60-frame stepping.
- Settings, pause, and save/load modal open/close cycle.
- Customer manager claim/pathing loop over 100 deterministic ticks.
- Store save codec create, encode, decode, and restore roundtrip.
- Main-scene screenshot capture timing.
- Exported desktop pack startup timing.

## Follow-Up

- Stop 13.3 should add regression tests for any P1 fixes that change fixture placement, queue composition, screenshot framing, or core-loop behavior.
- Stop 13.4 content work should rerun this performance smoke after adding visual density.
- Stop 13.6 playtest packaging should rerun `--full` on the final handoff machine and record any export-template/signing differences.
