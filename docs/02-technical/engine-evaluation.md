# Engine Evaluation

## Current Recommendation

Default to Godot 4 for the first prototype unless a focused spike proves it cannot support the required physical item density, Mac build workflow, or validation needs.

The engine proof has passed for the current technical path: Godot 4.6.2 runs the project, local validation passes, macOS export succeeds, and the exported app launches headlessly.

The project is still not permanently married to Godot for the full game. The next risk is visual quality, not basic engine viability.

## Requirements

The engine must support:

- first-person 3D movement
- one-to-one physical stock items
- shelf slot placement
- fixture movement
- physically present customers
- simple NPC navigation
- management UI overlays
- save/load of many object states
- macOS builds
- local automated validation
- screenshot capture for validation

## Godot 4 Pros

- lightweight repo structure
- readable scenes and scripts
- good fit for indie desktop sim
- exports to macOS
- fast iteration
- open-source toolchain
- built-in UI system
- simple resource-driven data
- manageable for a documentation-heavy repo

## Godot 4 Risks

- dense physical item simulation must be carefully optimized
- navigation around movable fixtures needs design discipline
- large 3D asset workflows need consistent import rules
- first-person object handling requires polish
- GDScript typing and test harnesses need standards from day one
- macOS signing/notarization still needs external Apple tooling

## Unity Pros

- mature 3D workflows
- strong asset ecosystem
- robust navigation options
- broad desktop distribution familiarity

## Unity Risks

- heavier project and tooling overhead
- licensing and version churn concerns
- more complex repo hygiene
- less transparent for a small source-doc-driven project

## Unreal Pros

- strong 3D rendering
- robust editor tooling
- high-end visuals

## Unreal Risks

- overkill for this first playable
- heavier Mac development and build footprint
- more complex source control and asset management
- slower iteration for small-system sim work

## Decision Criteria

The completed engine proof demonstrates:

1. first-person movement inside a mall store shell
2. pick up one physical game case
3. place it into a shelf slot
4. move one shelf fixture
5. spawn one customer from mall path
6. customer browses shelf and queues
7. register sale updates state
8. save/load restores item and fixture positions
9. export to macOS
10. run local validation script

If Godot passes this proof cleanly, continue with Godot.

If it fails only due to fixable implementation details, fix the implementation.

If it fails because the engine/tooling fights the core game repeatedly, revisit Unity.

## Recommended Initial Engine Stack

If Godot is selected:

- Godot 4.x stable
- GDScript for gameplay systems
- typed GDScript required for first-party scripts
- resource files for product definitions
- JSON or Godot resource serialization for saves, to be decided during prototype
- GUT or equivalent for tests
- shell validation wrapper for local gate
