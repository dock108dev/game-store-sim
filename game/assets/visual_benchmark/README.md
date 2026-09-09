> **Historical reference — superseded 2026-09-07.** This document is not an active specification, work order, or acceptance record for the restart. Its locks and completion claims do not define current intent. Read the [current master plan](../../../docs/MASTER_PLAN.md).

# Visual Benchmark Game Assets

This folder contains `.glb` assets ready for Godot import.

The canonical source files live under `assets/blender/source/`, and exported copies live under `assets/blender/exports/`.

Godot consumes the files in this directory. The manifest `visual_benchmark_asset_manifest.json` maps every Godot-ready GLB back to the source `.blend`, Blender collection, export path, and required benchmark screenshots.

The assembled scene lives at `res://scenes/visual_benchmark/VisualBenchmarkStore.tscn` and instances `game_store_visual_benchmark_full.glb` with camera and lighting references for import QA.
