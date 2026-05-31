# Abend Handling Audit

Date: 2026-05-31

Scope: full repository, with primary risk assessment on shipping Godot runtime code under `game/`, and secondary assessment on CI, scripts, tests, and documentation. Third-party `addons/gut/` code was treated as dependency behavior unless repo-owned scripts suppress, allowlist, or reinterpret its output.

Search basis:

- Broad pattern scan for `push_error`, `push_warning`, `return {}`, `return []`, `return null`, `fallback`, `silent`, `ignore`, `suppress`, `best-effort`, `no-op`, `continue-on-error`, known-fail manifests, and lint suppressions.
- Runtime aggregate: 243 `push_error` and 347 `push_warning` occurrences under `game/autoload`, `game/scripts`, `game/scenes`, and `game/ui`.
- Lint suppression aggregate: 70 `gdlint:` directives across repo-owned GDScript.
- Repository file count sampled for audit: 711 files at depth 3 for common repo-owned source, script, workflow, and doc types.

## 1. Executive Summary

Overall assessment: the project is intentionally defensive and unusually explicit about error handling. Most production-path suppressions are documented in code comments and convert dangerous silent failures into `push_error`, `push_warning`, structured `AUDIT:` lines, player notifications, or CI-visible stderr gates. The main residual risks are not classic swallowed exceptions. They are gaps where partial data or presentation fallback allows gameplay to continue without enough structured telemetry to distinguish "acceptable degradation" from a real content or save integrity incident.

Severity count:

| Severity | Count |
| --- | ---: |
| Critical | 0 |
| High | 0 |
| Medium | 9 |
| Low | 14 |
| Note | 7 |

Category count:

| Category | Count |
| --- | ---: |
| CI/log suppression and soft gates | 5 |
| Content/data fallback | 8 |
| Runtime fail-loud-and-continue | 7 |
| Warning/no-op guard | 5 |
| Environment/debug strictness | 3 |
| Lint/static suppression | 1 |
| Security-sensitive suppression | 1 |

Production suppressions appear mostly acceptable and mostly "Low" or "Note". The cases that deserve attention first are:

1. `ProductVisualCatalog` and `StoreVisualLayout` store `load_error` but do not consistently emit runtime warnings at load time.
2. `SaveManager` silently omits or ignores optional subsystem save sections when system references are absent or section types do not match.
3. `GameWorld` load/new-game validation emits `push_error` but keeps gameplay running after state invariant failures.
4. `StoreSessionController._load_json` downgrades missing content files to warning plus `{}` even when a missing file may remove Day-1 beats.
5. `CheckoutSystem.initiate_sale` intentionally warning-returns on invalid sale input, which is reasonable for tests but can silently drop a sale if production preconditions drift.

## 2. Detailed Findings Table

| ID | File path | Area | Category | Exact behavior | Trigger / failure mode | Current handling | Prod impact | Observability impact | Data integrity risk | Security risk | Reliability risk | Recommended disposition | Severity | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ABH-01 | `scripts/run_godot_tests.sh:34`, `scripts/run_godot_tests.sh:75` | GUT gate | CI/log suppression | Filters shutdown `WARNING`/`ERROR` noise and allowlists known `push_error` lines. | Godot headless teardown noise or tests intentionally exercising fail-loud paths. | Ignores filtered noise, trusts `All tests passed`, rejects unexpected `ERROR:`. | None at runtime. | Good for expected cases, but allowlist breadth can hide a new matching error. | Low. | Low. | Medium if regex grows stale. | Keep, but split allowlist into named patterns and test it with fixtures. | Medium | High |
| ABH-02 | `tests/audit_run.sh:41` | Interaction audit | CI soft skip | If Godot is unavailable and no explicit `GODOT` is set, exits 0 after warning. | Local or misconfigured runner without Godot. | Audit is skipped. | None in shipped game. | Can hide missing audit execution outside fully provisioned CI. | Low. | Low. | Medium for release process confidence. | Keep for local ergonomics, but make CI require an explicit `CI=true` hard failure. | Medium | Medium |
| ABH-03 | `.github/workflows/nightly.yml:56` | Weekly visual review | Soft gate | Visual snapshot job uses `continue-on-error: true`. | Visual regression or capture failure in weekly job. | Job reports failure but workflow can still pass. | No direct runtime impact. | Advisory lane can be overlooked. | Low. | Low. | Low. | Accept as advisory if separate PR/main visual gates exist; document review ownership. | Low | High |
| ABH-04 | `scripts/render_nightly_videos.sh:27` | Movie render automation | Timeout fallback | Uses `timeout`/`gtimeout` when available; otherwise runs Godot without per-scenario timeout. | Platform lacks timeout command. | Relies on workflow job timeout. | None in game. | Failure is delayed and less localized. | None. | None. | Low. | Accept, or fail fast when timeout command is missing in CI. | Low | High |
| ABH-05 | `scripts/generate_audit_scenario_report.py:79`, `scripts/generate_audit_scenario_report.py:198` | Audit report generation | Fallback/default | Missing metadata and malformed JSON snippets become warnings/default objects. | Metadata file absent, non-object, or individual JSON parse errors. | Produces report with warnings and defaults. | None in game. | Good if warnings are reviewed; weak if report consumers only scan pass/fail. | Low. | Low. | Low. | Accept, but show warnings prominently in generated Markdown summary. | Low | High |
| ABH-06 | `game/scripts/store_session/store_session_controller.gd:2963` | Store-session content | Content fallback | Missing JSON file logs warning and returns `{}`; open/oversize/malformed content logs error and returns `{}`. | Content file stripped, missing, unreadable, oversized, or malformed. | Continues with empty event data. | Can remove day/customer beats while loop remains playable. | Warning/error visible only in logs/CI. | Medium. | Low. | Medium. | Tighten missing Day-1 required content to `push_error`; keep optional future-day placeholders as warning. | Medium | High |
| ABH-07 | `game/scenes/world/game_world.gd:1104` | New/load validation | Fail-loud continue | State validation emits `push_error` for mismatches but does not return to menu or block gameplay. | Loaded or new state violates expected active store/cash/ownership invariants. | Logs error and continues. | May allow degraded or inconsistent session. | Good CI signal if tests scan `ERROR:`, weak in player-only release logs. | Medium. | Low. | Medium. | Keep for nonfatal validation, but add player-visible recovery or telemetry for invariant failures in release. | Medium | High |
| ABH-08 | `game/scripts/core/save_manager.gd:430`, `game/scripts/core/save_manager.gd:620` | Save collection/distribution | Silent optional section | Optional systems are saved/loaded only if references exist; type mismatches are skipped. | System reference missing or save section type not a `Dictionary`. | Section omitted or ignored without warning. | Potential partial save/load if wiring regresses. | Low: missing section may not be obvious. | Medium. | Low. | Medium. | Warn once for expected-present systems missing during save/load; keep optional future systems silent. | Medium | Medium |
| ABH-09 | `game/scripts/core/save_manager.gd:251`, `game/scripts/core/save_manager.gd:280` | Save/load | Fail-loud plus notification | Write failures push error and notify player; migration failures push error and fail load. | Disk write failure, corrupt save, unsupported schema, migration failure. | Returns `false`, emits warning/error and player notification. | Protects progress from silent loss. | Good. | Low. | Low. | Low. | Accept; this is healthy resilience. | Note | High |
| ABH-10 | `game/autoload/data_loader.gd:496`, `game/autoload/data_loader.gd:506` | Content loading | Warning aggregation | Static callers get warning plus `null`; boot callers aggregate `_load_errors` and warn, with later GameManager hard fail. | JSON read/parse/size failures. | Warning at loader, content-load failure escalates at GameManager. | Boot should fail before play when content load errors aggregate. | Good, but static utility callers can degrade quietly if they ignore `null`. | Medium. | Low. | Medium. | Audit static callers and require explicit handling for `null` returns. | Medium | High |
| ABH-11 | `game/autoload/data_loader.gd:775` | Starter inventory | Fail-loud empty fallback | Unknown store, empty canonical, missing store, and missing item definitions return empty/skip after `push_error`; category mismatch warns and skips. | Store or starter inventory content typo. | Game boots but CI sees `ERROR:`; GameWorld also warns on empty inventory. | Day 1 can become empty if warnings are not gated. | Good in CI, weaker in release. | Medium. | Low. | Medium. | Escalate empty known-store starter inventory to hard session failure, or block new-game start. | Medium | High |
| ABH-12 | `game/scripts/visuals/product_visual_catalog.gd:31`, `game/scripts/visuals/store_visual_layout.gd:23` | Visual catalog/layout | Silent load_error | Loader returns catalog object with `load_error` instead of logging. | Missing or malformed visual JSON. | Callers must inspect `load_error`; many fallback to generic visuals. | Presentation degrades, likely playable. | Weak: a catalog-wide visual outage may look like design fallback. | Low. | Low. | Medium. | Emit `push_warning` once at load point or central visual bootstrap. | Medium | High |
| ABH-13 | `game/scripts/visuals/product_visual_factory.gd:33`, `game/scripts/visuals/store_visual_kit.gd:262` | Product visuals | Null fallback | Missing catalog/template/resource returns `null`; callers often use placeholder visuals. | Missing scene/resource/template. | Placeholder or no visual. | Mostly cosmetic, but could hide product identity issues. | Low unless caller warns. | Low. | Low. | Low. | Accept for optional visuals; add once-per-ID warnings for required retail fixtures. | Low | High |
| ABH-14 | `game/autoload/content_registry.gd:145`, `game/autoload/content_registry.gd:528` | Content registry lookup | Downgraded warning | Unknown runtime IDs warn instead of error; boot duplicates/conflicts push error. | Optional lookup for unknown ID. | Empty route/ID with `push_warning`. | Callers can recover; boot validation catches structural issues. | Good. | Low. | Low. | Low. | Accept; this is a clear fail-soft boundary. | Note | High |
| ABH-15 | `game/autoload/store_registry.gd:1`, `game/autoload/store_registry.gd:128` | Store registry | Fail-loud null fallback | Unknown/duplicate store IDs `push_error`, `AuditLog.fail_check`, and return `null`/empty path. | Bad store ID or duplicate registration. | Observable error, no silent overwrite. | Prevents ambiguous store routing. | Strong. | Low. | Low. | Low. | Accept; well designed. | Note | High |
| ABH-16 | `game/autoload/scene_router.gd:52`, `game/autoload/scene_router.gd:141` | Scene routing | Warning/error event | In-flight transitions are ignored with warning; transition failures emit `push_error`, `AuditLog.fail_check`, and `scene_failed`. | Double navigation or invalid path/target. | Does not throw, preserves current scene. | Reasonable UX; double-click drops request. | Good structured signal for failures. | Low. | Low. | Low. | Accept; add UI feedback only if users can trigger lost navigation. | Low | High |
| ABH-17 | `game/scripts/ui/modal_panel.gd:1`, `game/scripts/ui/modal_panel.gd:235`, `game/scripts/ui/modal_panel.gd:277` | Modal focus stack | Auto-recovery | Double open and corrupt pop emit `push_error`; freed active modal auto-pops CTX_MODAL and continues. | Caller opens twice, sibling corrupts focus stack, scene frees panel while open. | Recovers focus stack where possible. | Prevents stuck input, but signals invariant break. | Good in CI; release may only log. | Low. | Low. | Medium. | Keep; add runtime telemetry/player-safe fallback for repeated modal errors. | Medium | High |
| ABH-18 | `game/autoload/settings.gd:343`, `game/autoload/settings.gd:649`, `game/autoload/settings.gd:714` | Settings | Defaults after invalid config | Corrupt/oversize config avoids engine parse noise, resets/defaults invalid settings, warns. | User config malformed, unsupported locale, bad resolution/font setting. | Uses defaults and continues. | User preferences may reset, gameplay unaffected. | Good warnings. | Low. | Low. | Low. | Accept. | Low | High |
| ABH-19 | `game/autoload/difficulty_system.gd:163`, `game/autoload/difficulty_system.gd:219` | Difficulty persistence | Best effort | Failed difficulty config load keeps in-memory tier; failed persist warns and continues. | Settings file corrupt/unwritable. | Current session continues. | Tier may not persist to next launch. | Warning visible in logs only. | Low. | Low. | Low. | Accept; optionally notify player on persist failure. | Low | High |
| ABH-20 | `game/autoload/manager_relationship_manager.gd:430`, `game/autoload/manager_relationship_manager.gd:482`, `game/autoload/manager_relationship_manager.gd:582` | Manager notes | Mixed warning/error fallback | Missing whole optional blocks warn and return fallback/empty; missing required tier/normal candidates push error. | Bad or partial notes JSON. | Morning/end-of-day commentary may disable or fall back. | Mostly content/UX degradation. | Good for required structural breaks; acceptable warning for fixtures. | Low. | Low. | Low. | Accept, but ensure production JSON missing optional blocks is covered by content validation. | Low | High |
| ABH-21 | `game/scripts/systems/checkout_system.gd:120` | Sale initiation | Warning/no-op | Null customer/item or non-positive agreed price warns and returns with `_is_processing` false. | Bad sale caller precondition. | Sale is dropped. | Could lose a sale if production preconditions drift. | Warning only. | Medium. | Low. | Medium. | Promote production-only invalid sale inputs to `push_error` or emit checkout failure event. | Medium | High |
| ABH-22 | `game/scripts/systems/checkout_system.gd:241` | Checkout queue | Silent completion | Non-`Customer` queue-ready payload emits `checkout_completed` and returns without warning. | Bad signal payload. | Queue item is treated completed. | Could hide a wiring bug. | Low. | Medium if sale was expected. | Low. | Medium. | Add `push_warning` for non-Customer payloads, possibly once per type. | Medium | Medium |
| ABH-23 | `game/scripts/systems/customer_system.gd:650`, `game/scripts/systems/customer_system.gd:675`, `game/scripts/systems/customer_system.gd:812` | Day-1 spawn reliability | Race no-ops and fallback timer | Legitimate race guards silently return; missing forced-spawn timer warns. | Duplicate stock event, day rollover, active customer, missing timer. | Avoids spam and forces Day-1 customer within 12 seconds when possible. | Good player reliability. | Good for missing timer, silent for normal races. | Low. | Low. | Low. | Accept. | Note | High |
| ABH-24 | `game/scripts/characters/customer.gd:512`, `game/scripts/world/customer_nav_config.gd:37` | Navigation | Degraded movement fallback | Missing nav agent/region/navmesh warns per customer and uses direct-line movement; unsafe targets sanitize to safe defaults. | Bad scene wiring or bad navmesh bake. | Customers still move. | Gameplay continues with lower fidelity. | Good, possibly noisy. | Low. | Low. | Low. | Accept; CI should fail repeated nav fallback in acceptance scenarios. | Low | High |
| ABH-25 | `game/autoload/audio_manager.gd:134`, `game/autoload/audio_manager.gd:530` | Audio | Warning and path rejection | Unknown SFX/path warns; path containing `..` is rejected with warning. | Bad audio registry key/path or attempted traversal segment. | Audio omitted; traversal not loaded. | Cosmetic audio loss. | Warnings deduped for missing paths. | Low. | Low positive control. | Low. | Accept; classify traversal warning as security-sensitive but currently low risk due `res://` asset loading. | Note | High |
| ABH-26 | `game/scenes/debug/debug_overlay.gd:21`, `game/scripts/stores/retro_games.gd:598`, `game/scripts/ui/moments_tray.gd:47` | Debug surfaces | Release quietness | Debug overlays and shortcuts short-circuit or `queue_free` in release builds; debug-only warnings unavailable in release. | Release export. | Debug affordances removed. | Appropriate. | Release logs quieter by design. | None. | Low. | Low. | Accept; documented environment difference. | Note | High |
| ABH-27 | `game/scripts/stores/store_controller.gd:573`, `game/scripts/systems/checkout_system.gd:805` | Dev shortcuts | Release no-op | Dev force-place and force-complete sale helpers no-op in release. | User/dev shortcut outside debug build. | Returns false or no effect. | No production effect. | Caller debug overlay owns warning. | None. | Low. | Low. | Accept. | Note | High |
| ABH-28 | multiple, e.g. `game/scripts/store_session/store_session_controller.gd:1`, `game/autoload/data_loader.gd:1` | Static analysis | Lint suppression | Broad `gdlint:disable` directives for max lines/public methods/returns/class order. | Large legacy or intentionally monolithic files. | Lint ignores complexity checks. | No runtime effect. | Reduces static maintainability signal. | Low. | Low. | Low. | Track suppressions as debt; prefer scoped disables for new code. | Low | High |
| ABH-29 | `game/scripts/store_session/store_session_controller.gd:934` | Day close | Duplicate no-op | Duplicate `day_close_confirmed` after summary spawned warns and returns. | Double signal emit or duplicate listener. | Prevents double day advance and delta wipe. | Protects data integrity. | Good warning. | Low positive control. | Low. | Low. | Accept; well designed guard. | Note | High |
| ABH-30 | `game/scripts/systems/inventory_system.gd:51`, `game/autoload/game_manager.gd:77`, `game/autoload/game_manager.gd:445` | General gameplay state | Warning/error returns | Invalid inventory add errors and returns; missing remove warns false; invalid state transition warns false; missing DataLoader warns/errors and records session failure. | Caller or wiring drift. | Operation rejected, current state retained. | Usually safe; can hide repeated invalid operations without aggregation. | Mixed: session failures recorded, simple warnings not counted. | Low to medium. | Low. | Low. | Add counters/telemetry for repeated warnings in one session. | Low | Medium |

## 3. Finding Details

### ABH-01: GUT gate filters and allowlists errors

`scripts/run_godot_tests.sh` strips headless engine shutdown noise before writing the GUT log, then trusts the final `All tests passed` summary and separately rejects unexpected `ERROR:` lines. This exists because Godot's headless teardown can return nonzero or emit engine-internal resource noise after a passing suite. It is intentional and mostly safe. The risk is regex drift: a future real error matching `EXPECTED_ERROR_RE` would be allowed. Recommendation: keep the suppression but split expected patterns into named fixtures with tests.

### ABH-02: Audit runner can skip locally when Godot is missing

`tests/audit_run.sh` exits 0 if no Godot binary is found and neither `GODOT` nor `GODOT_EXECUTABLE` was explicitly set. This is a developer convenience, not a production runtime path. In CI, the workflow installs Godot before invoking the script, so the usual risk is low. The residual risk is process drift: if a future CI lane calls the audit without setup, it can look green while doing nothing. Recommendation: hard-fail when `CI=true`.

### ABH-03: Weekly visual review is advisory

The weekly visual snapshot lane is explicitly `continue-on-error: true`. This is an intentional soft gate, appropriate for noisy visual baselines. The only risk is review discipline: failed advisory artifacts can be ignored. Recommendation: keep it advisory if PR/main validation owns blocking coverage and assign a review owner.

### ABH-04: Nightly video timeout depends on platform utilities

`render_nightly_videos.sh` uses `timeout` or `gtimeout` if available and otherwise runs without a per-scenario timeout. The workflow job timeout still bounds the whole job. Recommendation: fail fast in CI if no timeout tool is found, or document that only the job-level timeout applies.

### ABH-05: Audit reports default around metadata gaps

The Python report generator records warnings for missing metadata and returns `{}` for malformed embedded JSON. This is safe for report generation but can reduce report quality. Recommendation: keep the fallback and ensure warning lists are visible in generated reports.

### ABH-06: Store-session JSON missing file returns empty data

`StoreSessionController._load_json` treats read, oversize, and parse failures as `push_error`, but missing files as `push_warning` plus `{}`. The comments explain this is to allow future content strips. That is reasonable for optional placeholders, but Day-1/customer-event content is gameplay-critical. Recommendation: distinguish required paths from optional future-day placeholders and escalate missing required content.

### ABH-07: GameWorld validation does not block degraded state

New/load validation emits `push_error` for invariant failures and keeps gameplay running. This favors player continuity over hard stops. It is defensible for nonfatal drift, but if cash/active-store/ownership invariants break, later behavior can be confusing or corrupt. Recommendation: keep nonblocking validation for low-impact issues; for core invariants, show a recovery UI or return to menu.

### ABH-08: SaveManager silently omits optional sections

Save collection and distribution only touch systems that are currently referenced, and load ignores non-dictionary sections. This supports incremental systems and backwards compatibility, but it also means a wiring regression can produce a partial save without an immediate warning. Recommendation: classify systems as required, optional, and retired; warn for missing expected systems or wrong section types.

### ABH-09: Save/load failures are well surfaced

Save write errors emit `push_error`, notify the player, and return false. Load schema and migration failures warn or error and refuse load. This is the desired pattern for data integrity. Recommendation: keep as-is.

### ABH-10: DataLoader utility callers can ignore null

Boot callers aggregate `_load_errors` and GameManager escalates content-load failure, but static utility callers that do not provide `on_error` get warning plus `null`. The fallback is intentional. The risk is caller discipline. Recommendation: audit static callers and require either explicit `on_error` or an explicit fallback comment.

### ABH-11: Starter inventory can degrade to empty

`create_starting_inventory` emits `push_error` for unknown store and missing definitions, but still returns an array. GameWorld warns if the result is empty. CI should catch `push_error`; a release player may only see an empty backroom. Recommendation: for the configured starting store, fail new-game bootstrap if starter inventory resolves empty.

### ABH-12: Visual catalog/layout failures are too quiet

Visual catalog and layout loaders put a message into `load_error` and return an object. That keeps rendering paths simple but makes a catalog-wide failure easy to miss if callers fall back. Recommendation: emit a once-per-load `push_warning` at the loader or require callers to surface `load_error`.

### ABH-13: Product visual nulls and placeholders are acceptable but under-instrumented

Product visual creation returns `null` when the catalog, item, template, or resource is missing; some callers replace it with a fallback mesh. This is acceptable for optional polish assets. Required product/fixture visuals should warn once per missing ID so art/content regressions are visible.

### ABH-14: ContentRegistry uses recoverable unknown-ID warnings

Unknown runtime IDs warn and return empty results, while duplicate and alias conflicts at boot push errors. This distinction is healthy: runtime callers can probe optional content without failing CI, and boot validation still catches structural registry corruption.

### ABH-15: StoreRegistry is a strong fail-loud boundary

Unknown store IDs and duplicates emit `push_error`, structured `AuditLog.fail_check`, and return `null`/empty path. This is a good model: no silent overwrite, no ambiguous route, and structured incident evidence.

### ABH-16: SceneRouter preserves current scene on routing failure

In-flight route attempts warn and are ignored; actual scene-change failures push error, emit audit failure, and emit `scene_failed`. This is appropriate controlled suppression. User-facing feedback may be useful only if a normal player can trigger a dropped route.

### ABH-17: ModalPanel auto-recovers focus stack corruption

Modal double-open and mismatched focus pop are `push_error` paths; freeing an active modal auto-pops CTX_MODAL. This prevents stuck input, which is the right runtime priority. Repeated modal errors should be elevated to telemetry or a QA failure because they indicate ownership drift.

### ABH-18: Settings use safe defaults after invalid config

Settings pre-validates config to avoid noisy engine parse errors, clamps invalid values, resets bad preferences, and warns. This is low risk: user settings may reset, but gameplay and saves are protected.

### ABH-19: Difficulty persistence is best effort

The current difficulty tier remains in memory if settings persistence fails. This is acceptable, but a player-visible notification would be better if the failure means their choice will not survive restart.

### ABH-20: Manager notes distinguish optional degradation from content breaks

ManagerRelationshipManager pushes errors for required missing candidates and warnings for partial fixture/test-style blocks. The policy is mostly clear. Add content validation coverage so production JSON never depends on the warning-only fixture path.

### ABH-21: Sale initiation precondition failures only warn

`CheckoutSystem.initiate_sale` warning-returns on null input or non-positive price, preserving tested fallback behavior. In production, those inputs represent sale pipeline drift. Recommendation: either promote production calls to `push_error` or emit a checkout-failed event that can be surfaced in telemetry.

### ABH-22: Non-Customer checkout payload completes silently

`_on_checkout_queue_ready` emits `checkout_completed` and returns when payload is not a `Customer`, with no warning. This is one of the clearer hidden-failure candidates because it treats an invalid payload as completed work. Recommendation: add a warning with type/path details, at least once per bad payload type.

### ABH-23: Day-1 forced-spawn races are intentionally quiet

CustomerSystem silently returns for duplicate/racing timer cases and warns if the forced-spawn timer is missing after a declined checkout. This is well judged: normal races should not spam logs, but missing infrastructure is visible.

### ABH-24: Navigation falls back with visible warnings

Missing nav agent/region/navmesh engages direct-line movement with per-customer warnings, and staff-only targets sanitize to safe positions. This is acceptable controlled degradation. Acceptance scenarios should fail if fallback becomes common in production scenes.

### ABH-25: Audio missing assets degrade safely; traversal is rejected

Unknown SFX and missing audio paths warn and continue. Registry paths containing `..` are rejected. This is security-sensitive but low risk because the path is repo content and Godot resource loading remains constrained. Keep the warning.

### ABH-26: Release builds remove debug surfaces

Debug overlay, debug camera, and moments tray controls are gated behind debug build/project settings. Production is intentionally quieter and less permissive. This is appropriate.

### ABH-27: Dev shortcuts no-op outside debug

Debug force-place and force-complete flows return false or no-op in release builds. This prevents accidental production cheats and is acceptable.

### ABH-28: Broad lint suppressions are maintenance debt

Large files disable complexity-related `gdlint` checks. This does not hide runtime errors directly, but it reduces static pressure on high-risk files that also contain many fallback paths. Recommendation: allow existing suppressions, but require scoped disables or refactors for new modules.

### ABH-29: Duplicate day-close confirmation is safely ignored

StoreSessionController warns and returns if day close is re-emitted after the summary spawned. This protects daily deltas from being wiped twice and is an example of healthy suppression.

### ABH-30: General gameplay state guards mostly fail safe

Inventory, GameManager, and related systems usually reject invalid operations with warning/error and retain current state. That is safe. Repeated warnings could still become operational blind spots. Recommendation: add counters or structured audit events for repeated warning classes in one session.

## 4. Categorization

### Acceptable prod notes

- ABH-09 Save/load failure handling
- ABH-14 ContentRegistry runtime unknown-ID warnings
- ABH-15 StoreRegistry fail-loud lookups
- ABH-23 Day-1 forced-spawn race guards
- ABH-25 Audio path traversal rejection and missing-audio warnings
- ABH-26 Release debug-surface stripping
- ABH-27 Dev shortcut release no-ops
- ABH-29 Duplicate day-close no-op guard

### Acceptable but should be documented

- ABH-03 Weekly visual review is advisory
- ABH-04 Nightly video timeout fallback
- ABH-18 Settings defaults after bad config
- ABH-19 Difficulty persistence best effort
- ABH-28 Broad lint suppressions

### Acceptable but needs better telemetry

- ABH-01 GUT expected-error allowlist
- ABH-05 Audit metadata/report defaults
- ABH-10 DataLoader static caller warning/null
- ABH-12 Visual catalog/layout `load_error`
- ABH-13 Product visual null/placeholder fallback
- ABH-17 ModalPanel repeated recovery errors
- ABH-24 Customer navigation direct-line fallback
- ABH-30 Repeated general warning/error returns

### Should be tightened before prod

- ABH-02 Audit runner should hard-fail skip in CI
- ABH-06 Required store-session content should not be warning-only when missing
- ABH-07 Core GameWorld state invariant failures should have recovery behavior
- ABH-08 SaveManager expected subsystem omissions/type skips should warn
- ABH-11 Empty starter inventory for the configured starting store should block new-game start
- ABH-21 Invalid sale preconditions should escalate or emit checkout-failed telemetry
- ABH-22 Non-Customer checkout queue payloads should warn

### High risk / hidden failure

No current finding reaches High severity under the observed repository shape. The closest hidden-failure candidates are ABH-08 and ABH-22.

### Security-sensitive suppression

- ABH-25 is security-sensitive because it rejects traversal-like audio registry paths. Current handling is appropriate.
- Settings/config size caps in ABH-18 and ABH-19 are also positive security hardening.

### Data loss / corruption risk

- ABH-07 can continue after state invariants fail.
- ABH-08 can omit or ignore save/load sections.
- ABH-09 is the positive control for save write/migration failures.
- ABH-11 can allow empty Day-1 starter stock if CI/error logs are missed.
- ABH-21 and ABH-22 can drop or complete sales incorrectly if production preconditions drift.

### Observability blind spot

- ABH-02 local/accidental audit skip
- ABH-12 visual catalog/layout load errors
- ABH-13 visual fallback nulls/placeholders
- ABH-22 non-Customer checkout payload completion
- ABH-28 broad lint suppressions hiding complexity signal

## 5. Environment Review

Production is quieter than non-production in these areas:

- Debug overlays and debug camera controls are removed or short-circuited in release builds.
- Debug force-place/force-complete helpers no-op outside debug.
- Some diagnostic prints are guarded by `OS.is_debug_build()`.
- CI filters known engine teardown noise that a local raw Godot run might display.

Production is more permissive than non-production in these areas:

- Several `push_error` paths keep gameplay running because hard-stopping would be worse UX.
- Save/load and content systems often default around optional or malformed sections rather than crashing.
- Visual and audio missing assets usually degrade to placeholders or omission.

Production may fail open in these areas:

- Store-session missing JSON returns `{}` for all missing paths.
- GameWorld validation emits error but continues.
- SaveManager can silently skip optional save/load sections.
- Checkout queue can treat non-Customer payloads as complete.
- Visual catalog/layout loaders can return fallback objects without emitting warnings.

Production may hide actionable errors:

- Release players do not necessarily see `push_warning`/`push_error` unless a UI notification or telemetry path exists.
- Advisory workflow failures can be missed if reviewers do not check artifacts.
- Broad lint suppressions remove maintainability signal from large files with many fallback paths.

These differences are generally reasonable for a game: player continuity matters, debug tooling should not ship, and audiovisual degradation should not crash a run. The risky cases are state, save, and transaction paths where continuing can convert an obvious failure into confusing gameplay or data drift.

## 6. Recommended Remediation Plan

Quick wins:

- Add a warning in `_on_checkout_queue_ready` for non-Customer payloads before emitting `checkout_completed`.
- Emit once-per-load warnings for `ProductVisualCatalog.load_error` and `StoreVisualLayout.load_error`.
- Make `tests/audit_run.sh` hard-fail missing Godot when `CI=true`.
- Add a small allowlist fixture test for `scripts/run_godot_tests.sh` expected-error regex behavior.

Medium effort cleanup:

- Classify save sections as required/optional/retired and warn on missing expected-present systems or wrong section types.
- Split `StoreSessionController._load_json` into required and optional content loaders.
- Add a session warning counter or structured audit event for repeated warning classes.
- Move broad `gdlint:disable` directives toward scoped disables when touching those files.

High-value hardening:

- Block new-game bootstrap if the configured starting store resolves to empty starter inventory.
- Add player-visible recovery for core GameWorld state validation failures.
- Add checkout failure telemetry or events for invalid sale preconditions.
- Make acceptance scenarios fail if navmesh direct-line fallback or visual catalog fallback appears unexpectedly in production scenes.

Documentation gaps:

- Document which workflows are advisory vs blocking.
- Document required vs optional content files and visual catalogs.
- Document which save sections are expected in current schema.

Test gaps:

- Fixture test for visual catalog/layout missing-file warning.
- SaveManager test for expected subsystem omission and wrong-typed section warning.
- Checkout queue test for non-Customer payload warning.
- CI-mode test for `tests/audit_run.sh` missing Godot hard failure after that change.

Telemetry / alerting gaps:

- No aggregate count for repeated warnings in a runtime session.
- `push_error`/`push_warning` are not always paired with player-facing notification or structured `AuditLog`.
- Advisory visual failures rely on human artifact review rather than a blocking signal.

## 7. Remediation Status

Implemented in the audit follow-up:

- ABH-02: `tests/audit_run.sh` now hard-fails missing Godot when `CI=true`, while keeping local developer skips non-blocking.
- ABH-04: `scripts/render_nightly_videos.sh` now hard-fails in CI when neither `timeout` nor `gtimeout` is available.
- ABH-06: required Day-1 store-session content and event content now escalate missing files with `push_error`; optional future-day content remains warning-only.
- ABH-07: GameWorld state validation remains non-blocking, but validation failures now also emit a player-visible notification.
- ABH-08: `SaveManager` now warns once for wrong-typed save sections and for present save sections whose owning optional system was not wired.
- ABH-11: new-game bootstrap now fails with an error and player notification when configured starter inventory resolves empty.
- ABH-12: visual catalog and layout loader failures now emit runtime warnings at load time.
- ABH-21 and ABH-22: checkout invalid-sale and invalid queue payload paths now emit `checkout_failed` telemetry; invalid queue payloads also warn before completing the queue item.
- ABH-01: the GUT gate now has source-level contract coverage that the expected-error allowlist is present and unexpected `ERROR:` lines are rejected.

Remaining follow-up candidates:

- ABH-10, ABH-13, ABH-17, ABH-24, and ABH-30: broader warning aggregation/telemetry remains a future observability improvement.
- ABH-07: add a full recovery route only if core invariants begin appearing outside tests; the current remediation keeps play continuity and adds player-visible notification.
