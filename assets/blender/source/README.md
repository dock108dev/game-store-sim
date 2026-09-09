> **Historical reference — superseded 2026-09-07.** This document is not an active specification, work order, or acceptance record for the restart. Its locks and completion claims do not define current intent. Read the [current master plan](../../../docs/MASTER_PLAN.md).

# Blender Source Assets

Production `.blend` files for first-party visual benchmark assets live here.

Generated files in this folder are source assets, not disposable exports.

## Current Source

- `game_store_visual_benchmark_assets.blend` is the canonical source for the first 0.3% visual benchmark package.
- The file is organized into export collections: `Store Shell`, `Shelving Pack`, `Counter Register`, `Receiving Backroom`, `Product Cases`, `Signage Posters`, `Customer Placeholder`, `Daily Report Computer`, and `Full Benchmark Store`.
- Keep all brands, games, platforms, posters, labels, and store names fictional.

Regenerate the source and GLBs from the repo root:

```zsh
blender --background --python assets/blender/scripts/generate_visual_benchmark_store.py
```
