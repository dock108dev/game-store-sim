# Current sources of truth

September 23 maintenance source: `/Users/michaelfuscoletti/.codex/worktrees/abend-handling/game-sim`, HEAD `8b84f8f621af0613b08fbb9051ee6aec0548d51c` plus the preceding error-handling/security work and this uncommitted pass. The original checkout and frozen B9 app remain unchanged; B10 review continues on that app. Source checks are not replacement-artifact qualification or owner acceptance.

## Domain ownership

Domain: scope, authorization and acceptance

SSOT module/file: linked Desktop `game_sim_next_steps.md` for scope; `docs/03-production/b10-owner-review.md` for review facts; `docs/MASTER_PLAN.md` is the repository index.

Why this is authoritative: current user direction and exact-candidate review records supersede dated delivery prose.

Known callers: README, engineering handoffs, maintenance/review tasks.

Domain: entry and save namespaces

SSOT module/file: `encounter/project.godot`, with `export_presets.cfg` selecting `personal_beta`.

Why this is authoritative: Godot loads these settings; separate development/personal namespaces are deliberate, not aliases.

Known callers: Godot, development launcher, `validate.isolate_project`, personal build/qualification scripts.

Domain: content and demand

SSOT module/file: `encounter/week_content.gd`.

Why this is authoritative: `CATALOG`, `PRODUCTS`, release dates and roster generation supply the actual first-week content.

Known callers: `state.gd` through `Week` and catalog aliases; `main.gd`, `used.gd`, current week tests through state. Prices chosen by the player are inputs, not alternate reference policies.

Domain: business transitions and checkpoint validation

SSOT module/file: `encounter/state.gd`.

Why this is authoritative: commands own commit conditions; `SCHEMA_VERSION`, `RULESET_ID`, bounded `read_checkpoint`, `valid` and `load_from` own restoration.

Known callers: scene actions, Continue/reload menu probes, save/quit, restart/archive checks and current state/scene tests.

Domain: financial settlement and week/day summaries

SSOT module/file: `encounter/economy.gd`, using state-owned `events` and frozen settlements.

Why this is authoritative: it settles bills and reconstructs financial totals.

Known callers: state finalization/validation/business reports and financial UI. `state.report(product)` is a distinct current-day merchandising projection including product misses and physical counts; it is not a substitute for `business_report` operating results.

Domain: used acquisition and staff claims

SSOT module/file: `encounter/used.gd` for seller terms/offers/acquisition validation; `encounter/staff.gd` for claims/employment reconstruction, coordinated by state commands.

Why this is authoritative: both ordinary player and employee operations use the same state-owned copies, cash and job records.

Known callers: state, scene physical actions and regression tests.

Domain: geometry, presentation and development mode policy

SSOT module/file: `layout.gd` for fixture/route geometry; `main.gd` for input/session/mode policy; `actor.gd` for rig animation.

Why this is authoritative: scene transactions use shared layout ports and state commands; `development_options` controls supported fixture switches.

Known callers: main scene, state layout checks, assortment launcher, capture runner and current scene tests. Personal exports ignore development switches.

Domain: current source validation

SSOT module/file: `encounter/scripts/validate.py`.

Why this is authoritative: it selects current suites, isolates save state and records source hashes/process failures.

Known callers: documented default command and balance evaluation via its helpers. Python wrapper/capture-security tests supplement it. Historical slice test files are not an alternative current validation matrix.

## Changes and candidate inventory

| Candidate | Usage investigation | Action |
| --- | --- | --- |
| UI compatibility parse/check plus state loader | Continue/reload probes parsed the file, compared literal schema/ruleset, then loaded/parsed it again. | **Route through SSOT.** Menu calls `State.load_from` once and renders its failure category. Incompatibility belongs to the loader and references state constants. |
| Repeated state schema/ruleset literals and duplicate phase validation | Reset and validation independently embedded identity; `valid` checked the same phase/version twice. | **Consolidate.** State constants supply fresh identity and compatibility validation; remove the redundant check. No schema migration or value change. |
| `demo_price`, pricing mode parser and `Compare Pricing.command` | Only the retired launcher, historical R3 documentation and the prior security test called the mode. It set legacy low/reference/high values; its reference was $21.99 versus current Curb reference $20.00. No current validator selected it. | **Delete.** Remove the launcher, variable, setup and supported option. A development `--pricing-demo=…` now returns a specific error and exits 2 before play. The personal-feature boundary continues to ignore development flags. Ordinary labels and pending-label tests remain. |
| Assortment comparison and `--capture` | `Compare Assortments.command` and `capture_full_shift.py` remain explicit retained review workflows; main supplies their adapters. | **Keep with rationale.** They execute state commands with separate development checkpoint paths; their staged histories/prices are diagnostic inputs, not alternative catalog rules. Their historical results are not current week qualification. No capture run performed here. |
| Historical `game/`, root shell scripts, sample projects and old slice tests | These have separate historical entry points and retained evidence/assets. The current README and validator exclude them. | **Preserve/defer risky removal.** They are not current setup/build/test commands. Do not erase historical evidence or native sources as a cleanup shortcut. A later archival pass can relocate executable historical tools after identifying retained reproduction requirements. |
| Old B10-next/no-export text in active guides | Contradicted current Desktop tracker, B10 record and existing personal export preset. | **Correct.** Current index/setup describe B10 in progress and separate maintenance source. Dated delivery/evidence records remain unchanged. |

The persistence loader's `incompatible` stage is the UI-facing classification for wrong schema/ruleset. Other read/parse/integrity failures remain safe failures with originals retained. The menu no longer owns a second acceptance policy. Existing bounded reads, locator recovery, exactly-once business checks and release-mode isolation remain intact.

## Supported paths and retained limits

Run the encounter through its launcher, or validate through `python3 encounter/scripts/validate.py`. The current state/content is schema 10 / B6 rules, with later presentation improvements. New ordinary product prices remain player choices; no automatic economic rebalance occurred.

`--pricing-demo` is unsupported. Do not use a historical delivery's comparison instructions as current setup. Current optional development modes are assortment comparison (`stocked`/`missing`) and capture. Personal packaging is a separate explicitly authorized workflow; this pass does not run it. Development and personal save directories must remain distinct.

No routing/authentication/ingestion service exists to consolidate. Export/packaged qualification wraps a frozen artifact and has different identity and save-isolation requirements from current source validation; it was not blindly redirected through the source runner. A future consolidation should preserve those candidate boundaries and validate instrumented/final packages separately. Historical executable relocation and broader packaging-helper consolidation remain separate work, not implied current support.

## Validation

[Retained context](../../encounter/evidence/ssot-20260923T135633115410Z/context.json) binds the current executable source and isolated Godot 4.6.2 namespace. `incoming/` and `incoming-manifest.json` preserve affected inputs, including the deleted pricing launcher. Prior error-handling/security evidence is unchanged.

Headless import/compile and focused SSOT, security, storage, week-state, shared-regression, pending-price, presentation and restart checks passed. The SSOT suite checks fresh identity, valid and invalid menu/loader agreement, incompatible classification, removed-mode rejection, removed-launcher absence and catalog alias ownership. The security test now reflects supported modes rather than expecting the retired pricing adapter. No historical tests were deleted or relabeled as current validation.

The focused selection calls `validate.isolate_project`, `write_context` and `run_check` with `--headless --script` for the affected suites, retaining logs/exits/results. Standard Python wrapper/capture tests, syntax, documentation links and whitespace checks pass. This is source validation only: no full-week scene campaign, rendered capture, packaging, owner saves, commit, push or publication.
