## Test fixture: minimal node that satisfies the contract
## `StoreStatusPanel.seed_for_day` expects from the active day controller —
## membership in the `store_session_controller` group plus an `_objectives`
## Array[Dictionary] property accessible via `Object.get(...)`.
##
## Used by `test_store_session_hud.gd` so the HUD lifecycle tests do not need to
## instantiate the full `StoreSessionController` (which would drag in the
## entire retro_games scene tree).
extends Node


var _objectives: Array[Dictionary] = []
