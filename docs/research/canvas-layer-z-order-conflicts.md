# Canvas Layer Z-Order Bands

Date: 2026-06-02

CanvasLayer ordering is centralized in `game/scripts/ui/ui_layers.gd`. Scene
files keep explicit numeric `layer` values so Godot editor state, tests, and
external tools can read the intended order without executing scripts.

## Current Bands

| Constant | Layer | Current role |
| --- | --- | --- |
| `WORLDSPACE` | `5` | World UI layer in `game/scenes/world/game_world.tscn`. |
| `HUB_CHROME` | `20` | Reserved hub chrome band. |
| `HUD` | `30` | Main HUD. |
| `RAIL` | `40` | Objective rail. |
| `TUTORIAL` | `50` | Tutorial overlay. |
| `WORLD_PROMPT` | `60` | Interaction prompt. |
| `DRAWER` | `70` | Inventory/drawer surfaces. |
| `MODAL` | `80` | Modal surfaces, including day summary. |
| `PAUSE` | `90` | Pause menu. |
| `SYSTEM` | `100` | System-level UI. |
| `POST_FX` | `110` | CRT overlay post-process. |
| `DEBUG` | `120` | Debug overlays. |

## Validation

`tests/gut/test_canvas_layer_bands_issue_007.gd` verifies the tracked scene
CanvasLayer values and checks that the `UILayers` constants match the band
table for the active bands it covers.
