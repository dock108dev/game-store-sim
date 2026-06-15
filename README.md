# Game Store Sim

First-person specialty video game retail simulator. The mechanical prototype is broad and validated; the visual baseline is not approved.

## Start Here

Read [docs/CURRENT_STATE.md](docs/CURRENT_STATE.md) first. Machine-readable status lives in [docs/status.json](docs/status.json). Tests should assert that status contract instead of depending on long production-plan prose.

The current visual direction is the [Art Language Rebuild](docs/visual-production/00-art-language-rebuild-plan.md). The old graybox, beta, broad-production, and hard-benchmark docs were removed because they kept routing work back toward cube-based scenes, label panels, and external-playtest readiness before the shop looks right.

## Current Rule

Do not expand catalog visuals, customers, decorations, or external playtest packaging until the opening route has an approved modular art-kit baseline.

The next implementation pass starts with:

- [Art Language Rebuild Plan](docs/visual-production/00-art-language-rebuild-plan.md)
- [Modular Asset Kit Spec](docs/visual-production/01-modular-asset-kit-spec.md)
- [Art Rebuild Validation Plan](docs/visual-production/02-art-rebuild-validation-plan.md)

## Validate

Run the full local gate from the repository root:

```text
scripts/validate_godot.sh
```

The gate writes logs, screenshots, and the contact sheet to `artifacts/validation/latest/`.

Current validated baseline after the docs overhaul:

- 566 GUT tests.
- 10705 GUT asserts.
- UI scenario automation coverage: 508/628.
- Production script mapping: 53/53.
- 3 active standalone validation tools.
- 60 catalog products.
- Desktop pack smoke, alpha performance smoke, screenshot capture/sanity, contact sheet, old-name scan, and 23 required screenshots pass.

## Active Docs

- [Docs Index](docs/README.md)
- [Current State](docs/CURRENT_STATE.md)
- [Visual Production](docs/visual-production/README.md)
- [Backlog](docs/production/04-backlog.md)
- [Validation](docs/production/06-validation.md)
- [Visual Bug List](docs/production/13-alpha-bug-list.md)
- [QA](docs/qa/README.md)
