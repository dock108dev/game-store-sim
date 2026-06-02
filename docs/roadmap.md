# Roadmap

This is a narrow maintenance roadmap used by legacy issue validators. It only
records completed, code-backed acceptance items that current validators inspect.

## Completed

- [x] Custom shaders (outline highlight shader for interactable objects)

## Evidence

- Shader: `game/assets/shaders/outline_highlight.gdshader`
- Material: `game/assets/shaders/mat_outline_highlight.tres`
- Runtime use: `game/scripts/components/interactable.gd`
- Validators/tests: `tests/validate_issue_009.sh`,
  `tests/validate_issue_032.sh`, `tests/gut/test_interactable.gd`,
  `tests/gut/test_store_interactable_highlight.gd`
