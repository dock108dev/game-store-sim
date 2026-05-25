## Pre-run hook executed once before the GUT test suite starts.
## Resets DifficultySystemSingleton to "normal" so tests that do not set a
## difficulty tier are not affected by persisted user preferences.
extends GutHookScript


func run() -> void:
	DifficultySystemSingleton.set_tier(&"normal")
