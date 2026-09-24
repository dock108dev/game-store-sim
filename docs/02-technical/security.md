# Local security model and September 23 hardening

This describes the current source security boundary. The frozen personal Mac app under owner review remains a separate artifact and does not include later source maintenance. See [package identity](../03-production/b9-delivery.md) and [owner-review status](../03-production/b10-owner-review.md); this guide does not establish package qualification or owner acceptance.

The subsequent [SSOT pass](ssot.md) removes the legacy pricing fixture entirely and routes menu compatibility through the loader. Earlier test counts below remain the security-pass record.

## Surfaces and trust boundaries

Replay Junction is a personal, offline Godot 4.6.2 Standard/GDScript application with a local JSON checkpoint. It has no HTTP listener, browser frontend, sidecar, login, roles, sessions, remote API, callback, database, analytics, credential store or background network worker in the inspected application sources. Hosted-web controls such as CORS, CSP, CSRF tokens, rate limiting and authentication middleware do not apply to its current architecture.

The OS account running the app is the principal. Bundled GDScript/art and developer-invoked scripts are trusted executable content. Checkpoint JSON and the active-file locator are mutable local data and must be validated before use. Save data is not executable deserialization: JSON is parsed into a candidate whose business invariants are checked before publishing it. This is not anti-cheat protection or authentication against someone controlling the same account.

Launch arguments cross into development fixtures/capture behavior. Python tools consume retained capture metadata, launch Godot/ffmpeg and create local evidence. Engine paths are explicit; subprocess commands use argument lists rather than a shell. Optional ffmpeg/Node and historical script tools still rely on developer-controlled installations/PATH. Godot export can create an ad-hoc signed app; packaging, source archives and templates are trusted developer inputs, not a public upload service.

The review searched tracked GDScript/Python/shell sources, active launch/export settings, historical game and art tools, and dependency/config filenames. No matching private-key blocks or common AWS/GitHub/OpenAI token patterns were found in the scoped tracked-text scan (excluding retained evidence/artifacts). This was not a complete secret-history scan. No package advisory or engine-CVE assessment was performed; no vulnerability-free dependency claim is made. No owner data was opened.

## Confirmed input-handling issues fixed

| Finding | Category / affected area | Severity / confidence | Evidence and realistic scenario | Fix / status |
| --- | --- | --- | --- | --- |
| Capture metadata controls ffconcat input | File handling / `capture_balance_pacing.py` | Medium / high | Previously `capture_times[].file` was concatenated into a quoted ffconcat directive and ffmpeg ran with `-safe 0`. Edited/imported evidence could escape the pace directory or inject extra directives when an engineer encoded it. This requires the engineer to run the local tool; it is not remote shell execution. | **Fixed.** Accept only generated numeric PNG basenames, day integers 1–7 and finite increasing timestamps; require existing regular frames with no symlink redirection; use relative `results/pace/…` paths and `-safe 1`. Metadata symlinks are rejected and reads capped at 16 MiB. |
| Unbounded checkpoint reads | Parser/resource use / `state.gd` and `main.gd` | Low / high | Load and entry-menu probes previously read the whole file before validation. A replaced or accidentally huge local checkpoint could allocate excessive memory or freeze startup. Same-account file access or manual file placement is required. | **Fixed for unbounded file allocation.** Shared reader checks length, reads at most length plus one byte and rejects files above 8 MiB or changed read length. Entry probes and existing-file checks use that boundary. Save also rejects serialization over 8 MiB before opening the temporary file, preventing creation of a checkpoint this build cannot read. Original bytes and live state remain intact. This does not bound every nested validation operation. |
| Missing phase reached an unchecked field access | Validation / `state.gd` | Low / high | A structurally plausible JSON checkpoint without `phase` reached `data.phase` while calculating content days, before phase validation. Hand-edited malformed input could cause a script error instead of an ordinary load rejection. | **Fixed.** Validate the phase allowlist before downstream access. An isolated malformed-input test verifies rejection without engine errors or live-state changes. This is a targeted fix, not comprehensive schema fuzzing. |

## Hardening opportunities implemented

| Finding | Category / affected area | Severity / confidence | Why it matters / evidence | Outcome |
| --- | --- | --- | --- | --- |
| Development fixtures reachable in personal export | Development surface / `main.gd` | Low / high | Main parsed assortment/pricing/capture switches regardless of export feature; pricing names were interpolated into checkpoint paths with a default for unknown values. Locally supplied arguments could select unintended fixture behavior in the personal save namespace. This was not an elevated privilege boundary. | **Fixed.** `personal_beta` ignores all three development modes. Development accepts only documented mode names; arbitrary path fragments/unknown values are ignored. The active locator no longer overrides a chosen development fixture path. |
| Unbounded locator read | Local file handling / `main.gd` | Low / high | `active-week.txt` was read in full even though only a filename is needed. | **Fixed.** Read at most 256 bytes, and retain the existing `week-*.json`/valid-filename guard. Oversized/invalid locator text falls back to the ordinary checkpoint; it never becomes an arbitrary path. |

## Intentional acceptable patterns

- **Informational / high confidence / accepted:** no auth layer or web headers, because there is no service/browser trust boundary. Adding them would not protect these local files.
- **Informational / high confidence / accepted:** local JSON remains editable; invariant validation is for safe restoration and consistent accounting, not tamper-proof entitlements. Existing run IDs and active-file locator names already reject path separators; traversal tests retain that protection.
- **Informational / high confidence / accepted:** event/claim/phase checks and persistence-only retries remain intact, preventing accidental transaction replay within a history. Loading an earlier successful history intentionally discards later unsaved progress.
- **Informational / high confidence / accepted:** safe `STORAGE_FAILURE` diagnostics expose operation/stage/code without checkpoint contents. Existing development action/report and capture logs include local game state; they are not secret-free public uploads. Do not publish evidence wholesale without reviewing it.
- **Informational / high confidence / accepted:** trusted developer scripts use argument-list subprocess calls and filtered archive extraction (`filter='data'` in packaged qualification). This is not permission to execute arbitrary downloaded source archives or art scripts.

## Prioritized remaining work

1. **Local filesystem races and permissions — low severity, high confidence, deferred.** Save and locator writes use predictable `.tmp` names and ordinary FileAccess opens, which do not establish exclusive/no-follow ownership. A process already able to modify the same user's save directory can redirect a preexisting temporary symlink or race a check. Atomic rename preserves ordinary failed-write behavior but is not a hostile same-account boundary. If shared accounts, imported save directories or stronger local isolation become requirements, implement exclusive no-follow temporary creation in a private directory through a suitable native boundary, verify directory/file permissions, and add symlink/race tests. Avoid a cosmetic existence check that claims to solve the race. Owner directory permissions were not inspected.
2. **Malformed-input validation breadth — low severity, high confidence, deferred.** The new byte cap and early phase guard do not prove every nested schema path total or time-bounded. Before supporting imported saves, add a bounded structural schema pass, limits for history collections/nesting, and mutation-based tests covering every nested field. Current seven-day ordinary histories and focused malformed cases pass; arbitrary adversarial JSON is not qualified.
3. **Public distribution and toolchain — informational, high confidence, needs decision/manual verification.** The personal app uses ad-hoc signing with no notarization and retains its recorded build-9 identity. Before public distribution, define the supported OS/engine update policy, review current Godot/tool advisories, use appropriate signing/notarization and qualify the final artifact. No advisory results are inferred from a passing import. Resolve optional tools from trusted installations and review downloaded archives before executing them. No signing, packaging, live scans or dependency installs ran here.

Same-account attackers can also replace the application or its scripts; these changes do not claim to defend a compromised OS account. The capture tool assumes its output directory remains under the invoking engineer's control while it runs; validation is not race-proof against concurrent hostile filesystem mutation.

## Validation and operation

[Security evidence](../../encounter/evidence/security-20260923T135056220637Z/context.json) records exact executable hashes, engine version and the unique synthetic save namespace. `incoming/` preserves the four modified executable inputs from the preceding pass; `incoming-manifest.json` binds them. Prior error-handling evidence remains unchanged.

- Headless editor import/compile passed.
- Nine security checks passed: oversized load/overwrite/menu probe, missing phase, run-ID traversal rejection, personal/development launch modes and normal round trip.
- Nine storage, 706 week-state, 86 shared-regression, 32 presentation and 10 restart checks passed.
- Three Python capture-security tests passed, covering traversal/directive injection, external-looking paths, symlinks, invalid day/timing, and safe relative concat paths from an output directory containing spaces and an apostrophe. ffmpeg was mocked; no new video encoding qualification is claimed.
- Five retained validation-wrapper tests passed. Python syntax, edited guide links and whitespace checks passed.

All seven Godot processes exited zero without engine/script errors or warnings. Injected `STORAGE_FAILURE` records are expected test results. The default validator includes `test_security.gd`; run Python checks with:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p 'test_*security.py' -v
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s encounter/scripts -p test_validation_runner.py -v
```

An oversized checkpoint is preserved and cannot Continue; use a separate New week or an explicitly authorized recovery after retaining the original. Do not silently raise the cap or truncate owner saves. Existing release artwork, schemas and business values are unchanged. No full-week scene campaign, rendered/Retina run, packaged-feature execution, real owner-save test or owner acceptance was performed. Feature-gating tests exercise the same helper with the personal-feature input; a future export still needs its own qualification.
