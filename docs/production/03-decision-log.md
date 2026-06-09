# Decision Log

Major decisions go here so production choices stay visible as the game grows.

## 2026-06-05: Engine And Prototype Target

Decision:

- Use Godot 4.6.3 stable.
- Build desktop-first.
- Build the first slices for keyboard/mouse only.
- Use fictional products, fictional retailers, and fictional brands.

Reason:

- Godot fits a solo/indie first-person shop simulator with fast iteration, scene composition, built-in UI, and low licensing friction.
- Keyboard/mouse keeps the first-person interaction, register UI, pricing UI, and fixture placement work focused.
- Fictional brands avoid legal dependency and let the product economy be tuned for gameplay.

Rejected alternatives:

- Unity: viable, but heavier for this project and less attractive for a small data-driven sim.
- Unreal: strong 3D tooling, but too heavyweight for the first production slice.
- Controller from day one: useful later, but it would constrain UI and interaction design before the core loop is proven.
- Real brands: high legal and content maintenance risk.

Follow-up risk:

- If controller support becomes a target later, input mapping and UI focus handling will need a deliberate pass.
- Godot is pinned to 4.6.3 stable for active development. The local app detected during project setup was 4.6.2, so it should be upgraded before substantive game content is generated.

## 2026-06-05: Repository Foundation

Decision:

- Use `dock108dev/game-store-sim` as the GitHub repository.
- Use `main` as the default branch.
- Keep this local checkout at `/Users/michaelfuscoletti/Desktop/game-store-sim`.

Reason:

- The remote already contains the inspiration screenshots and Godot import metadata.
- Keeping the current local folder preserves the planning docs and reference workflow.

Rejected alternatives:

- Start a second local clone and manually move docs later.
- Create a separate planning-only repository.

Follow-up risk:

- The repository currently contains reference images before game code, so asset and Git LFS policy should be revisited before large production assets are added.
- Reference screenshots should influence mechanics and layout principles only. Stream overlays, video UI, visible third-party branding, and non-video-game retail details should not become game requirements.

## 2026-06-08: Production Polish Reset

Decision:

- Treat the validated first-playable counter loop as complete historical scope.
- Start a dedicated production polish phase before adding larger mechanics.
- Use inspiration images as concrete visual, menu, layout, customer, and backroom principles instead of vague reference material.

Reason:

- The current loop is mechanically broad enough that random new features would hide readability problems.
- Backroom, computer, customers, menus, and scene visuals need a coherent pass before adding theft, returns, richer customer archetypes, or expansion.
- A clear polish roadmap keeps future slices small, validated, and shippable.

Rejected alternatives:

- Continue adding mechanics on top of graybox presentation.
- Do one broad "make it pretty" pass without slice boundaries.
- Treat the inspiration screenshots as direct assets or exact UI copies.

Follow-up risk:

- Visual polish can easily break interaction readability. Each slice must keep manual validation and screenshots current.

## 2026-06-08: Game Completion Phase

Decision:

- Treat the current build as a validated prototype foundation, not as a production-looking game.
- Start a dedicated game-completion phase before broad feature expansion.
- Use `11-game-completion-plan.md` as the active source of truth for milestones, slice stops, acceptance criteria, validation, commit, and push cadence.

Reason:

- The June 7 screenshot review shows that the store, backroom, customers, menus, signage, and presentation still read as graybox even though the mechanics are validated.
- Continuing with isolated feature additions would make the game larger without making the first playable experience convincing.
- A comprehensive phase plan gives each future slice a clear player-facing outcome and prevents open-ended "make it pretty" work.

Rejected alternatives:

- Keep adding mechanics on top of the current scene.
- Declare the completed polish pass sufficient because automated validation passes.
- Replace the whole scene in one large unvalidated art pass.

Follow-up risk:

- Direction work can become abstract if it is not quickly converted into production target contracts and scene/UI slices. Milestones 1 through 13 in `11-game-completion-plan.md` converted the target contracts into a mechanically validated alpha handoff, but the June 9 manual screenshot review showed the build is not readable enough for external playtest. The next checkpoint is the playability readability recovery phase in `16-playability-readability-recovery-plan.md`.

## 2026-06-09: Playability Readability Recovery

Decision:

- Pause the external alpha playtest package.
- Treat the current build as mechanically validated but manually blocked for readability.
- Use `16-playability-readability-recovery-plan.md` as the next implementation source of truth.

Reason:

- Manual screenshots from the actual game window show that camera scale, ceiling dominance, oversized signs, foreground props, small UI, and inconsistent customer labels make the game difficult to read even though movement and pickup work.
- External playtest would mostly collect obvious readability complaints instead of useful loop, economy, customer, backroom, and save/load feedback.
- A focused recovery phase keeps the work bounded: fix camera/scale first, then sightlines, prompts, modals, customers, backroom, and finally reopen the playtest package.

Rejected alternatives:

- Continue with external playtest because the automated gate is green.
- Add more content or mechanics before the current loop is readable.
- Do one large unbounded visual pass that mixes camera, UI, customers, and backroom changes without slice stops.

Follow-up risk:

- Recovery work can accidentally become a second broad polish roadmap. Keep each slice tied to the screenshot blocker, full validation, docs sync, commit, and push cadence.
