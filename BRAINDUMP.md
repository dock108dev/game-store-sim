The real standard

The industry standard is not “one magical bot plays the whole game and tells you it’s fun.” That product would be worth billions and somehow still produce a Jira ticket saying “vibes are off.”

The standard is a layered confidence system:

1. Unit tests for pure gameplay rules.
2. Scene/integration tests for UI, NPCs, interactables, shops, inventory, saves.
3. Scripted playthroughs that drive the game like a player.
4. Golden screenshots/video artifacts for visual review.
5. Performance/soak tests for long-running stability.
6. Manual review only where human judgment is actually needed.

For Godot/Mall Core, the practical setup is: GUT + Godot command-line/headless + custom test scenes + replay scripts + screenshot/movie artifacts + CI gates. GUT is a Godot unit-testing framework for GDScript, with Godot 4.x support in current 9.x versions. Godot itself supports command-line/headless workflows useful for CI, and its Movie Maker mode can generate video from command line using --write-movie and fixed FPS settings.  ￼

⸻

Mall Core Automated Playtest Braindump

Goal

Build a repeatable test system that can prove Mall Core is:

* Launchable from a fresh install.
* Playable through the tutorial.
* Stable across core systems.
* Visually sane across major screens, camera angles, characters, stores, products, HUD states, and notification states.
* Resistant to regressions in movement, interaction, economy, inventory, save/load, UI layout, and NPC behavior.
* Able to produce screenshots/videos that a human or AI reviewer can inspect without manually clicking through the whole game every time.

The target is not full automation of taste. The target is full automation of evidence.

⸻

Industry-style test layers

Layer	Purpose	Mall Core examples	PR gate?
Static checks	Catch obvious code/resource breakage	Script parse, missing scenes, missing assets, broken autoloads	Yes
Unit tests	Validate isolated rules	Money math, inventory changes, stock count, quest state, save schema migration	Yes
Scene tests	Validate a scene works alone	HUD, store UI, shelf, product card, customer, stock room, tutorial popup	Yes
Flow tests	Validate multi-step gameplay	Start new game → tutorial → move → interact → stock shelf → sell item	Yes, small set
Visual snapshot tests	Catch layout/visual regressions	HUD overlap, invisible signs, bad camera framing, product boxes clipping	Soft gate first
Video playthroughs	Review real gameplay behavior	3–10 minute scripted play sessions	Nightly/release
Soak tests	Catch long-running sim bugs	30–60 minute accelerated mall day	Nightly
AI/manual review	Evaluate aesthetics and weirdness	“Does this look broken?” “Are objects floating?” “Is tutorial readable?”	Advisory first

Unity and Unreal both have official play-mode/functional testing concepts: Unity’s Test Framework supports Edit Mode and Play Mode tests, including target platforms, while Unreal’s Automation System sits on top of its Functional Testing Framework for gameplay-level tests. That is the broader pattern to copy even if Mall Core stays in Godot.  ￼

⸻

Core principle: make the game testable on purpose

Before writing big tests, Mall Core needs a test harness mode.

Add a TestMode / AutomationMode

This should be a first-class runtime mode, not a pile of hacks.

Capabilities:

--test-mode
--scenario=tutorial_full
--seed=mallcore_001
--record-screenshots
--record-video
--exit-on-complete
--speed=4x

In test mode:

* Randomness is seeded.
* Time can be paused, stepped, or accelerated.
* Save files write to a disposable test path.
* Popups, tutorials, and animations can be advanced deterministically.
* The player can be controlled through scripted commands.
* The test runner can inspect game state.
* The game exits with success/failure code for CI.
* Logs are structured enough to parse.

This is the difference between “I hope the bot can click stuff” and “the game exposes clean handles for automated validation.”

⸻

What to automate first

1. Fresh install launch test

Purpose: Catch catastrophic breakage.

Test:

Start game from clean user data
Load main menu
Start new game
Enter first playable scene
Assert no crash
Assert no blocking error popup
Assert HUD exists
Assert player exists
Assert camera exists
Assert mall scene exists
Take screenshot
Exit cleanly

This should run on every PR.

⸻

2. Tutorial full-path test

This is probably your highest-value test because you keep seeing “technically successful but visually/UX rough.”

Test:

Fresh install
Start tutorial
For each tutorial step:
  assert instruction text is visible
  assert required target exists
  perform action
  assert next step advances
  take screenshot
Finish tutorial
Assert player can move freely
Assert no tutorial overlay remains stuck
Assert save state says tutorial_complete = true

Specific Mall Core checks:

* Intro text does not cover movement area.
* Tutorial prompts do not overlap HUD/sidebar.
* Required objects are visible and reachable.
* Click targets are not blocked.
* Player can move after tutorial.
* No “click through 14 panels before moving” regression unless explicitly designed.
* Fresh install path is tested every time.

⸻

3. HUD and notification layout tests

You already found this pain: sidebar, notice, stock counts, HUD elements, etc.

Create a dedicated HUD visual test scene with fake game states:

State 1: normal HUD
State 2: low money
State 3: many notifications
State 4: stock warning
State 5: tutorial active
State 6: side panel open
State 7: store UI open
State 8: dialogue + notification + HUD
State 9: small resolution
State 10: ultrawide-ish resolution

For each state:

* Render the scene.
* Capture screenshot.
* Compare against baseline.
* Also run simple layout assertions:
    * No major panel outside viewport.
    * No text box with zero/negative size.
    * No critical HUD area overlapping another critical HUD area.
    * No notification stack covering required interaction panel.
    * No unreadable tiny text under target resolution.

This gives you a visual regression wall.

⸻

4. Character / product / object gallery

This is the “standalone products or characters and interact with different views” part.

Create an internal scene:

res://tests/visual/visual_gallery.tscn

It loads every important asset category:

* Player variants.
* NPC/customer variants.
* Storefronts.
* Product boxes.
* Shelves.
* Signs.
* Registers.
* Stock room props.
* Queue markers.
* Tutorial markers.
* Notification styles.
* UI panels.
* Buttons.
* Icons.
* Dialogue bubbles.

Then it cycles cameras:

front view
side view
top-ish gameplay view
close-up
normal gameplay zoom
small viewport
large viewport

Assertions:

* Asset loads.
* Object has expected material/sprite/mesh.
* Object is visible.
* Object is not at origin unless expected.
* Object has collision if interactive.
* Object has label if needed.
* Object does not float unless intentionally decorative.
* Sign text is readable at gameplay camera distance.
* Product box has designed surface, not placeholder geometry.

Outputs:

artifacts/screenshots/gallery/player_variants.png
artifacts/screenshots/gallery/storefronts.png
artifacts/screenshots/gallery/products.png
artifacts/screenshots/gallery/hud_states.png
artifacts/videos/gallery_walkthrough.avi

This becomes your “stop accidentally shipping gray cubes wearing a fake mustache” test.

⸻

5. Interaction contract tests

For every interactable object, define a contract.

Example:

Interactable object contract:
- has visible affordance
- has collision area
- exposes interaction label
- can be focused
- can be activated
- emits expected signal
- does not soft-lock player
- works with keyboard/controller/mouse path if supported

Mall Core interactables:

* Register.
* Shelf.
* Product box.
* Storage/stock area.
* Customer.
* Store entrance.
* Build/buy UI.
* Tutorial target.
* Notification action.
* Menu buttons.
* Save/load terminal if applicable.

Run them in a small test scene where the player is teleported near each object and interacts.

⸻

6. Scripted gameplay flows

You want a small number of high-value deterministic playthroughs, not 500 brittle scripts.

Flow A — smoke playthrough

fresh install
new game
complete first tutorial step
move to store area
interact with first shelf
open stock UI
place/stock item
close UI
wait for customer
customer buys item
money increases
save game
quit
reload
assert money/inventory/state persisted

Flow B — bad state resistance

start game
open/close menus rapidly
trigger notification while UI open
move while notification appears
attempt interaction while side panel open
pause/unpause
save/load
assert no stuck input
assert no duplicated panels
assert no lost cursor/focus

Flow C — economy loop

seed inventory
stock shelf
spawn controlled customers
simulate purchases
assert stock decreases
assert money increases
assert customer exits
assert no negative stock
assert no negative money unless allowed

Flow D — layout torture

run at 1280x720
run at 1920x1080
run at 2560x1440
run at small window
open all major screens
capture screenshots
assert no critical overlap

Flow E — long mall day

start scenario with seeded mall
run 30 minutes accelerated
track NPC count
track pathfinding failures
track interaction failures
track FPS/memory if available
assert no runaway entity growth
assert no stuck global state
assert no crash

⸻

Screenshots and videos

Screenshots

Screenshots should be captured at named checkpoints:

001_main_menu.png
002_new_game_loaded.png
003_tutorial_step_1.png
004_first_movement.png
005_store_ui_open.png
006_stock_shelf.png
007_customer_queue.png
008_sale_complete.png
009_save_reload.png

Each screenshot should have matching metadata:

{
  "scenario": "tutorial_full",
  "seed": "mallcore_001",
  "scene": "MainMall",
  "checkpoint": "store_ui_open",
  "resolution": "1920x1080",
  "commit": "abc123",
  "passed_assertions": 42,
  "failed_assertions": 0
}

Videos

Use videos for review, not usually for hard PR blocking.

Godot Movie Maker can be run from command line with --write-movie, and fixed FPS can be supplied with --fixed-fps, which is useful for deterministic review artifacts.  ￼

Nightly artifact examples:

tutorial_full_1080p.avi
first_10_minutes_seed_001.avi
visual_gallery_walkthrough.avi
npc_customer_flow_seed_002.avi
ui_torture_720p.avi

Convert to mp4 after CI if needed.

⸻

AI review layer

This is where you can use a multimodal LLM, but keep it honest.

AI should review screenshots/videos against a rubric. It should not be the only judge.

AI review rubric

For each screenshot/video, score:

1. Critical blocker
   - crash
   - blank screen
   - stuck tutorial
   - impossible interaction
   - missing player
   - missing main UI
2. Visual breakage
   - overlapping UI
   - floating objects
   - invisible/too-small signs
   - placeholder geometry
   - clipped text
   - weird camera framing
   - unreadable labels
3. UX friction
   - too many popups before control
   - unclear objective
   - hidden interaction target
   - confusing sidebar/notification behavior
   - player cannot tell what changed
4. Polish issues
   - inconsistent styling
   - ugly spacing
   - dead empty space
   - excessive geometric/blocky composition
   - bland prop placement

Output should be structured:

{
  "scenario": "tutorial_full",
  "overall_status": "needs_review",
  "blockers": [],
  "visual_issues": [
    {
      "screenshot": "003_tutorial_step_1.png",
      "issue": "Tutorial panel overlaps HUD stock counter",
      "severity": "medium",
      "suggested_fix": "Reserve top-right HUD safe zone or move tutorial panel lower-left."
    }
  ],
  "ux_issues": [],
  "polish_notes": []
}

Use AI review as a triage assistant, not gospel. Otherwise you end up debugging why the robot thinks your stock room has “liminal sadness.” Helpful, but not a release criterion.

⸻

CI structure

PR pipeline: fast confidence

Runs on every PR.

1. import/parse check
2. GUT unit tests
3. core scene load tests
4. fresh install smoke test
5. tutorial first 2–3 steps
6. HUD layout smoke screenshots
7. upload artifacts on failure

Target runtime: under 5–8 minutes.

Nightly pipeline: broad confidence

Runs once per night.

1. full tutorial playthrough
2. full visual gallery
3. economy loop
4. NPC/customer pathing scenario
5. save/load scenarios
6. resolution matrix screenshots
7. 30-minute accelerated soak
8. video capture artifacts
9. AI screenshot/video review

Release pipeline: hard gate

Runs before tagging/release.

1. clean export
2. install-like launch
3. full tutorial
4. first playable mall day
5. save/load
6. no fatal log errors
7. approved screenshot/video artifact review

⸻

Folder structure

tests/
  unit/
    test_inventory.gd
    test_money.gd
    test_save_schema.gd
    test_customer_state.gd
  scenes/
    test_hud_layout.gd
    test_store_ui.gd
    test_interactables.gd
    test_tutorial_steps.gd
  flows/
    smoke_new_game.gd
    tutorial_full.gd
    economy_loop.gd
    save_reload.gd
    ui_torture.gd
    mall_day_soak.gd
  visual/
    visual_gallery.tscn
    hud_states.tscn
    product_gallery.tscn
    character_gallery.tscn
    storefront_gallery.tscn
  automation/
    test_runner.gd
    scenario_loader.gd
    screenshot_service.gd
    video_runner.gd
    input_driver.gd
    assertions.gd
    artifact_writer.gd
  fixtures/
    scenarios/
      fresh_start.json
      tutorial_full.json
      economy_loop_seed_001.json
      visual_gallery.json
  baselines/
    screenshots/
      hud/
      tutorial/
      gallery/

⸻

Test runner design

Scenario definition

Use JSON/YAML-ish scenario files so tests are not buried in procedural code.

{
  "name": "tutorial_full",
  "seed": "mallcore_001",
  "start_scene": "res://scenes/main/Main.tscn",
  "fresh_save": true,
  "resolution": "1920x1080",
  "steps": [
    {
      "action": "wait_for",
      "target": "MainMenu",
      "timeout_ms": 5000
    },
    {
      "action": "click",
      "target": "NewGameButton"
    },
    {
      "action": "wait_for",
      "target": "Player",
      "timeout_ms": 5000
    },
    {
      "action": "screenshot",
      "name": "new_game_loaded"
    },
    {
      "action": "assert_visible",
      "target": "TutorialPanel"
    },
    {
      "action": "move_player",
      "direction": "right",
      "duration_ms": 1000
    },
    {
      "action": "assert_position_changed",
      "target": "Player"
    }
  ]
}

Input driver

The input driver should support:

click target
click coordinates
press key
hold key
release key
move player vector
wait seconds
wait until signal
wait until state
interact
open menu
close menu

Do not overfit to exact pixels unless testing exact pixels. Prefer semantic targets:

NewGameButton
Player
Shelf_001
StockPanel
TutorialPanel
NotificationStack

⸻

Assertions worth adding

Core assertions

assert_scene_loaded(scene_name)
assert_node_exists(path_or_group)
assert_visible(node)
assert_enabled(control)
assert_no_modal_blocker()
assert_player_can_move()
assert_player_not_stuck()
assert_camera_tracks_player()
assert_money_changed(expected_delta)
assert_inventory_count(item, expected)
assert_stock_count(shelf, item, expected)
assert_save_file_created()
assert_save_reloads_state()
assert_no_fatal_errors()

Visual/layout assertions

assert_control_inside_viewport(control)
assert_controls_do_not_overlap(a, b)
assert_text_not_empty(label)
assert_text_fits(label)
assert_click_target_large_enough(button)
assert_no_placeholder_material(node)
assert_object_above_floor(node)
assert_sign_readable_at_camera(node)
assert_safe_zone_clear(zone_name)

Simulation assertions

assert_npc_reaches_destination(npc, timeout)
assert_customer_exits_after_purchase()
assert_queue_does_not_deadlock()
assert_no_negative_inventory()
assert_no_duplicate_customer_ids()
assert_entity_count_below(max)
assert_pathfinding_failures_below(max)

⸻

What “done” should mean

Mall Core is not “fully tested” when it has a lot of tests. It is tested when every major regression category has a tripwire.

Definition of done for the automation system

- A clean checkout can run tests without manually opening Godot.
- CI can launch Godot in test mode.
- Unit tests run in CI.
- At least one fresh-install smoke flow runs in CI.
- Tutorial flow produces screenshots at each step.
- Visual gallery produces screenshots for major assets/UI states.
- Nightly run produces at least one gameplay video.
- Failed runs upload logs, screenshots, and scenario metadata.
- Test failures identify the scenario and checkpoint.
- Release candidate requires passing smoke + tutorial + save/load + gallery.

⸻

Suggested implementation phases

Phase 1 — Foundation

Goal: Make Mall Core runnable and inspectable by automation.

Tasks:

* Add AutomationMode.
* Add deterministic seed support.
* Add disposable save path.
* Add structured logging.
* Add scenario runner entry point.
* Add screenshot artifact writer.
* Add CI command to launch Godot headless/test mode.
* Add GUT for basic unit tests.

Exit criteria:

CI can run:
- unit tests
- game launch smoke
- screenshot capture

⸻

Phase 2 — Fresh install + tutorial tests

Goal: Prevent the biggest user-facing regressions.

Tasks:

* Build fresh_install_smoke scenario.
* Build tutorial_full scenario.
* Add tutorial checkpoint screenshots.
* Add assertions for movement, visible objectives, UI non-overlap.
* Add save/load after tutorial.

Exit criteria:

A PR cannot break:
- new game startup
- tutorial progression
- basic movement
- tutorial completion
- save/load after tutorial

⸻

Phase 3 — Visual gallery

Goal: Stop visual regressions from hiding inside normal gameplay.

Tasks:

* Build character gallery.
* Build product gallery.
* Build store/sign gallery.
* Build HUD state gallery.
* Add camera/resolution matrix.
* Add screenshot baseline folder.
* Add soft visual diff reporting.

Exit criteria:

Nightly run outputs a browsable visual artifact pack.

⸻

Phase 4 — Gameplay loop automation

Goal: Prove the core loop works.

Tasks:

* Add economy loop scenario.
* Add stock/shelf/register interaction tests.
* Add customer purchase flow.
* Add queue/pathfinding checks.
* Add menu open/close torture test.
* Add save/load mid-loop.

Exit criteria:

The game can be automatically played through the first meaningful mall loop.

⸻

Phase 5 — Soak and AI review

Goal: Catch slow failures and visual weirdness.

Tasks:

* Add accelerated 30-minute mall day.
* Track entity counts, queue failures, pathfinding failures, memory/FPS if feasible.
* Generate videos using Godot Movie Maker.
* Add AI review script for screenshots/videos.
* Produce review report.

Exit criteria:

Nightly run creates:
- logs
- screenshots
- videos
- structured review report

⸻

Practical tool callout

For Mall Core, I would start with:

Godot command line/headless
GUT
Custom GDScript scenario runner
Custom screenshot/video artifact system
GitHub Actions or local script runner
Optional AI screenshot review

Commercial tools like GameDriver and AltTester exist for game automation, especially in Unity/Unreal ecosystems, with object inspection and simulated input features. GameDriver markets support for Unity, Unreal, XR, and consoles, and has discussed Godot support; AltTester focuses on Unity/Unreal game/app automation and object inspection/control. Useful to know, but probably not the first move for your Godot indie workflow.  ￼

⸻

One-shot agent prompt

# Mall Core Automated Playtest System — Audit + Implementation Plan
## Objective
Design and implement an automated playtest system for Mall Core that can run from a clean checkout, execute deterministic gameplay scenarios, capture screenshots/videos, validate core gameplay state, and produce reviewable artifacts for visual/UX inspection.
The system should follow industry-style layered game QA:
- unit tests for pure logic
- scene/integration tests for UI and interactables
- scripted gameplay flows
- visual gallery snapshots
- video playthrough artifacts
- performance/soak scenarios
- optional AI-assisted visual review
Do not try to replace all human judgment. The goal is to automate evidence collection and catch regressions early.
## Constraints
- Mall Core is a Godot project.
- Tests must run locally and in CI.
- Tests must not depend on manually opening the Godot editor.
- Test runs must use deterministic seeds.
- Test save data must be isolated from developer/player saves.
- Screenshots/videos/logs must be written as artifacts.
- The test system must be simple enough for solo indie development.
- Avoid giant brittle pixel-click scripts where semantic scene targets are possible.
## Phase 1 — Audit Current Testability
Review the current project and identify:
- main launch scene
- tutorial scene/flow
- player controller
- HUD/sidebar/notification systems
- interactable object system
- inventory/stock/economy systems
- save/load system
- NPC/customer/pathfinding systems
- current debug/dev tools
- CI/build scripts if any
Produce a short report:
```text
Current Automation Readiness:
- Can launch from command line: yes/no
- Can run headless: yes/no
- Has test framework: yes/no
- Has deterministic seed: yes/no
- Has isolated save path: yes/no
- Can take screenshots: yes/no
- Can record video: yes/no
- Has scenario runner: yes/no
- Has structured logs: yes/no

Phase 2 — Add Automation Mode

Implement a first-class test mode that can be launched with command-line args.

Required args:

--test-mode
--scenario=<scenario_name>
--seed=<seed>
--fresh-save
--record-screenshots
--record-video
--exit-on-complete
--speed=<multiplier>

Automation mode must:

* set deterministic seed
* use isolated test save path
* expose clean failure/exit status
* write structured logs
* allow scenario scripts to drive gameplay
* allow scenario scripts to assert game state
* allow screenshot capture at named checkpoints

Phase 3 — Add Test Runner Architecture

Create:

tests/
  unit/
  scenes/
  flows/
  visual/
  automation/
  fixtures/
  baselines/

Core automation files:

tests/automation/test_runner.gd
tests/automation/scenario_loader.gd
tests/automation/input_driver.gd
tests/automation/assertions.gd
tests/automation/screenshot_service.gd
tests/automation/artifact_writer.gd

The runner should support:

* wait_for target
* click target
* press/hold/release input
* move player
* interact
* wait until signal/state
* assert node exists
* assert visible
* assert player moved
* assert inventory/stock/money state
* screenshot checkpoint
* fail with scenario + step + reason

Phase 4 — Add Unit Tests

Install/configure GUT or equivalent Godot test framework.

Add unit tests for:

* money changes
* inventory add/remove
* stock count changes
* customer purchase state
* save schema read/write
* tutorial state machine
* notification queue rules
* interaction eligibility

These should run in CI on every PR.

Phase 5 — Fresh Install Smoke Test

Add scenario:

fresh_install_smoke

Steps:

1. clear test save path
2. launch game
3. assert main menu visible
4. start new game
5. assert player exists
6. assert camera exists
7. assert HUD exists
8. assert mall scene loaded
9. assert player can move
10. take screenshot
11. exit cleanly

This is a hard PR gate.

Phase 6 — Tutorial Full Playthrough

Add scenario:

tutorial_full

For each tutorial step:

* assert tutorial panel visible
* assert instruction text non-empty
* assert required target exists
* assert target is visible/reachable
* perform required action
* assert tutorial advances
* take screenshot

Final assertions:

* tutorial_complete = true
* player can move freely
* no blocking overlay remains
* save/load preserves tutorial_complete
* no fatal errors in logs

This is a hard PR gate once stable.

Phase 7 — HUD and UI Layout Tests

Create dedicated HUD state scene.

States:

* normal HUD
* tutorial active
* notification active
* many notifications
* side panel open
* store UI open
* dialogue open
* low stock warning
* small resolution
* large resolution

Assertions:

* controls inside viewport
* critical panels do not overlap
* text is non-empty
* click targets have reasonable size
* notification stack does not cover required UI
* tutorial panel does not block core controls unless intended

Capture screenshots for each state.

Phase 8 — Visual Gallery

Create gallery scenes:

tests/visual/character_gallery.tscn
tests/visual/product_gallery.tscn
tests/visual/storefront_gallery.tscn
tests/visual/hud_gallery.tscn
tests/visual/interactable_gallery.tscn

Each gallery should:

* load every relevant asset
* arrange objects with spacing
* include labels where useful
* cycle camera views
* capture screenshots
* assert objects are visible
* assert objects are not placeholders
* assert interactables have collision/focus/labels
* assert signs/products are readable at gameplay camera distance

This should run nightly and before release.

Phase 9 — Core Gameplay Loop

Add scenario:

economy_loop_seed_001

Steps:

1. fresh save
2. enter mall
3. stock shelf
4. spawn controlled customer
5. customer finds item
6. customer buys item
7. stock decreases
8. money increases
9. customer exits
10. save/load
11. assert state persisted

Add assertions:

* no negative stock
* no negative money unless explicitly allowed
* no duplicate customer IDs
* no stuck customer
* no broken queue
* no missing UI state

Phase 10 — UI Torture Scenario

Add scenario:

ui_torture

Actions:

* rapidly open/close menus
* trigger notification while panel is open
* open store UI while tutorial hint exists
* pause/unpause
* click outside panels
* use keyboard/controller/mouse path if supported
* resize or run multiple resolutions

Assertions:

* no stuck input
* no duplicate panels
* no invisible modal blocker
* no broken cursor/focus state
* no fatal errors

Phase 11 — Soak Test

Add nightly scenario:

mall_day_soak_30min

Run accelerated simulation for 30 minutes.

Track:

* FPS if feasible
* memory if feasible
* active NPC count
* customer count
* pathfinding failures
* queue deadlocks
* purchase failures
* warning/error counts
* entity growth over time

Fail on:

* crash
* deadlock
* runaway entity count
* fatal errors
* repeated pathfinding failures above threshold
* economy impossible state

Phase 12 — Video Artifacts

Add command/script for video run.

Example intent:

godot --path . --write-movie artifacts/videos/tutorial_full.avi --fixed-fps 30 --test-mode --scenario=tutorial_full --seed=mallcore_001 --exit-on-complete

If exact syntax needs adjustment for the project/runtime, implement the equivalent Godot-supported command-line movie workflow.

Nightly videos:

* tutorial_full
* visual_gallery_walkthrough
* first_10_minutes_seed_001
* economy_loop_seed_001
* ui_torture

Phase 13 — Artifact Pack

Every failed test should upload:

artifacts/
  logs/
  screenshots/
  videos/
  scenario_reports/
  junit/

Scenario report format:

{
  "scenario": "tutorial_full",
  "seed": "mallcore_001",
  "status": "failed",
  "failed_step": 8,
  "reason": "Tutorial target Shelf_001 not visible",
  "last_screenshot": "artifacts/screenshots/tutorial_full/008_failure.png",
  "errors": [],
  "warnings": []
}

Phase 14 — AI-Assisted Review

Add optional script that reviews screenshots/videos and produces structured notes.

Rubric:

* blocker
* visual breakage
* UX friction
* polish issue

The AI report must be advisory at first, not a hard CI blocker.

Output:

{
  "overall_status": "needs_review",
  "blockers": [],
  "visual_issues": [],
  "ux_issues": [],
  "polish_notes": []
}

Phase 15 — CI Gates

PR gate:

* import/parse check
* unit tests
* fresh install smoke
* tutorial first path
* HUD smoke screenshots

Nightly:

* full tutorial
* visual gallery
* economy loop
* UI torture
* 30-minute soak
* videos
* AI review report

Release:

* full PR gate
* full tutorial
* economy loop
* save/load
* visual gallery approved
* no fatal logs
* release artifact pack generated

Exit Criteria

The playtest system is complete enough when:

* a fresh checkout can run the test suite
* CI can launch Godot without manual editor steps
* a broken tutorial fails automatically
* broken movement fails automatically
* broken save/load fails automatically
* obvious HUD overlap is captured in screenshots
* major characters/products/stores are visible in gallery screenshots
* nightly run produces gameplay videos
* failed scenarios produce useful artifacts
* release candidate has a reviewable evidence pack

Important Design Rule

Do not build a fragile fake player that only clicks pixels.

Build a testable game:

* semantic node targets
* deterministic scenarios
* controlled seeds
* isolated save state
* test-specific hooks
* real gameplay assertions
* screenshots/videos for human review

The point is not to prove the game is fun automatically.

The point is to make every regression leave fingerprints.