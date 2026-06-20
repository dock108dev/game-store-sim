# Blender Exports

Accepted `.glb` exports generated from Blender source files live here.

The matching game-import copies live under `game/assets/visual_benchmark/`.

These files are generated from `assets/blender/source/game_store_visual_benchmark_assets.blend` and should not be hand-edited. Re-export with:

```zsh
blender --background --python assets/blender/scripts/generate_visual_benchmark_store.py
```

Expected production packs:

- `mall_store_shell.glb`
- `starter_shelving_pack.glb`
- `checkout_counter_register.glb`
- `receiving_backroom_pack.glb`
- `product_case_pack.glb`
- `signage_and_posters_pack.glb`
- `customer_placeholder.glb`
- `daily_report_computer.glb`
- `game_store_visual_benchmark_full.glb`
