# GitHub Actions CI readiness

September 23, 2026: **LOCALLY READY — HOSTED UNVERIFIED**. Changes live in the separate maintenance checkout at `/Users/michaelfuscoletti/.codex/worktrees/abend-handling/game-sim`, based on `8b84f8f621af0613b08fbb9051ee6aec0548d51c` plus the uncommitted maintenance work. The original checkout and B9/B10 candidate are unchanged.

## Ordinary pull-request contract

`.github/workflows/ci.yml` defines workflow **Encounter CI**, job/check **Encounter checks**, triggered by pull requests, pushes to `main`, and manual dispatch. It uses one `macos-15` runner, Python 3.14 and the official universal Godot 4.6.2 Standard archive. The archive SHA-256 is pinned and checked before extraction; the validator also checks the exact engine version string. No Python package installation is needed: these tools/tests use the standard library. Godot imports source assets afresh in a disposable copied project with an isolated save namespace.

The job runs Python syntax compilation and current Python unit tests, then `validate.py --ci`. This imports/compiles Godot and runs week-state, shared regressions, SSOT, security, storage, pending-price, presentation and restart checks headlessly with Dummy audio. `run_basic_checks` supplies the same first portion of the existing local validator; CI does not duplicate a separate test list. A selection test guards against accidentally adding native exits or full-week scene campaigns to this mode. Default validation retains its existing larger selection.

The `--engine` option accepts an explicit executable while retaining the existing local default. `--output` requires a new evidence directory. CI cannot combine with `--render`/`--capture`; it preserves partial result files in a finally block. This is source qualification only, not packaged/presentation/owner acceptance.

## Security and operational choices

- All action versions use immutable full commit SHAs with verified version comments. Checkout does not persist credentials. Sparse checkout selects the active encounter and workflow files; historical projects are not built.
- Workflow permissions are `contents: read`. No secrets, privileged PR events, environment approvals, deployments, signing, publishing or owner data are involved.
- A 20-minute job limit and bounded engine/download steps prevent indefinite runs. Concurrency cancels superseded PR/branch runs.
- No cache is used: the project has no dependency install requiring one, and clean imports avoid stale Godot cache passes.
- The diagnostic upload runs even on failure, retains only this run's output directory for seven days, and warns if setup failed before evidence creation. It does not upload historical evidence or owner saves.
- Dependabot checks GitHub Actions pins monthly. No npm/pip lockfile, service container or irrelevant web-security job was invented. Godot version/hash updates require explicit source qualification; Dependabot does not update the engine archive.

Relevant upstream references: [GitHub runner labels](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [checkout inputs](https://github.com/actions/checkout/blob/34e114876b0b11c390a56381ad16ebd13914f8d5/action.yml), [artifact inputs](https://github.com/actions/upload-artifact/blob/ea165f8d65b6e75b540449e92b4886f43607fa02/action.yml), and [official Godot release](https://github.com/godotengine/godot-builds/releases/tag/4.6.2-stable).

## Read-only hosted inspection

The public repository is `dock108dev/game-store-sim`, default branch `main`. No checked-in `.github` workflows existed in the incoming source. GitHub lists managed CodeQL, Dependabot Updates and Dependency Graph workflows. Latest observed CodeQL check name is **Analyze (python)**, successful on hosted `main` commit `22ac1bcbf6f4cc65fd7425508a1f471e2306dff9`. That is historical evidence only, not a result for this checkout.

The branch-protection API reports main is not protected, and the repository ruleset list is empty. No required checks are currently configured. No hosted settings, branch protection, secrets, integrations or runs were changed. After a separately authorized push and observed successful PR run, the owner can choose to require **Encounter checks** and the managed CodeQL check. Managed Dependabot/Dependency Graph activity is not an additional required PR check promised by this file.

## Validation performed

- `python3 encounter/scripts/validate.py --ci`: PASS, nine zero-exit processes including import; 866 recorded Godot checks. [Exact source context and evidence](../../encounter/evidence/validation-20260923T140642801044Z/context.json).
- `PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p 'test_*.py' -v`: PASS, nine tests.
- Python source syntax compilation: PASS.
- Both workflow and Dependabot YAML parsed with Ruby's installed YAML parser. Job names, triggers, expressions, paths, action pins/inputs and shell scripts inspected; shell syntax and whitespace checks passed. `actionlint` is not installed, so no actionlint result is claimed.
- The official release API confirms the pinned asset URL and SHA-256; action-tag APIs confirm the three full commit SHAs. The hosted archive installation itself was not run locally; local execution used the already installed matching Godot build.

Hosted macOS provisioning, archive installation, artifact upload and current-source CodeQL remain unverified until a new authorized push/PR. Packaging/signing, full-week scenes, rendered/Retina checks and owner review were deliberately not run. The workflow must be submitted together with its supporting maintenance source/tests, not copied onto the older hosted main alone.
