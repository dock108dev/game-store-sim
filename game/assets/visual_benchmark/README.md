# Visual Benchmark Game Assets

This folder contains `.glb` assets ready for Godot import.

The canonical source files live under `assets/blender/source/`, and exported copies live under `assets/blender/exports/`.

Godot consumes the files in this directory. The manifest `visual_benchmark_asset_manifest.json` maps every Godot-ready GLB back to the source `.blend`, Blender collection, export path, and required benchmark screenshots.

The assembled scene lives at `res://scenes/visual_benchmark/VisualBenchmarkStore.tscn` and instances `game_store_visual_benchmark_full.glb` with camera and lighting references for import QA.
