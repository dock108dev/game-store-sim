# Decision Log

Major decisions go here so production choices stay visible as the game grows.

## 2026-06-05: Engine And Prototype Target

Decision:

- Use Godot 4.x.
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
- Godot version should be pinned when the `game/` project is initialized.

## 2026-06-05: Repository Foundation

Decision:

- Use `dock108dev/mall-sim` as the GitHub repository.
- Use `main` as the default branch.
- Keep this local checkout at `/Users/michaelfuscoletti/Desktop/mallcore-sim`.

Reason:

- The remote already contains the inspiration screenshots and Godot import metadata.
- Keeping the current local folder preserves the planning docs and reference workflow.

Rejected alternatives:

- Start a second local clone and manually move docs later.
- Create a separate planning-only repository.

Follow-up risk:

- The repository currently contains reference images before game code, so asset and Git LFS policy should be revisited before large production assets are added.
- Reference screenshots should influence mechanics and layout principles only. Stream overlays, video UI, visible third-party branding, and non-video-game retail details should not become game requirements.
