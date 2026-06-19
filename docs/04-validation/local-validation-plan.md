# Local Validation Plan

## Goal

The repo should have a mandatory local validation gate from the start of implementation.

The gate should catch:

- parse/script errors
- broken project load
- broken save/load
- broken first playable flow
- blank screenshots
- missing required docs
- accidental real-world IP strings

## Future Command

Recommended command once the engine project exists:

```bash
scripts/validate_local.sh
```

## Expected Output Location

```text
artifacts/validation/latest/
  validation.log
  engine-smoke.log
  tests.log
  screenshots/
  summary.json
```

## Required Checks

### Documentation Check

Verify required docs exist:

- `docs/MASTER_PLAN.md`
- `docs/01-design/vertical-slice-contract.md`
- `docs/02-technical/architecture.md`
- `docs/04-validation/manual-playtest-checklist.md`

### Engine Project Check

Once created:

- project file exists
- project opens in headless or command-line mode
- no script load errors
- no missing required scenes

### Unit Tests

Required early tests:

- pricing calculation
- item location transition
- shelf slot validation
- register transaction
- save/load round trip
- day phase transition

### Smoke Test

Automated smoke should:

- launch main scene
- wait for scene ready
- verify player/camera exists
- verify starter shipment exists
- verify at least one fixture exists
- capture screenshot
- exit cleanly

### Screenshot Sanity

Screenshot check should fail if:

- image is missing
- image is blank
- image dimensions are wrong
- image is mostly one color

### IP Policy Check

Add a simple scanner for banned real-world terms once fictional naming begins.

The scanner should catch obvious real product/platform/store names in first-party data and docs, with allowlist support for documentation discussions.

## Failure Policy

The gate fails on:

- any script parse error
- missing required scene
- failed test
- missing screenshot
- blank screenshot
- save/load round trip failure
- accidental banned IP string in game data

Warnings are allowed for:

- incomplete later milestone docs
- placeholder art
- temporary unbalanced values

## Manual Validation Relationship

Automated validation proves the build is not broken.

Manual validation proves the game feels correct.

Both are required for milestone completion.

