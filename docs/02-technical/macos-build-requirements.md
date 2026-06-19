# macOS Build Requirements

## Platform Target

Primary platform for the first playable: macOS.

The game should run well on modern Apple Silicon Macs. Intel Mac support is desirable if the engine/export path provides it without major extra work.

## Build Types

### Local Developer Build

Purpose:

- internal iteration
- validation
- local playtests

Requirements:

- runs from local machine
- can be unsigned or ad-hoc signed if needed
- writes saves to a predictable user path
- can produce screenshots/logs for validation

### External Playtest Build

Purpose:

- testers outside the development machine

Requirements:

- signed with Apple Developer identity if distributed broadly
- notarized if distributed outside controlled local context
- clear version number
- bundled crash/log location documented

### Store Distribution Build

Purpose:

- Steam, itch, or other eventual distribution

Requirements:

- final distribution path to be decided
- signing/notarization workflow documented
- update strategy documented

## Input Requirements

macOS first playable must support:

- keyboard and mouse
- trackpad tolerance for UI
- remappable core controls eventually
- windowed mode
- fullscreen mode
- borderless fullscreen if engine supports it cleanly

## Display Requirements

Must support:

- Mac laptop resolutions
- Retina scaling
- readable UI at 13-16 inch laptop sizes
- no clipped text in management panels

## Save Path

Save path should use the engine/platform-standard user data location.

Requirement:

- document exact path once engine is chosen
- avoid writing saves into the app bundle
- support multiple save slots later

## Performance Targets

First playable target:

- stable 60 FPS preferred on development Mac
- stable 30 FPS minimum on reasonable Mac hardware
- no major hitches during customer spawn
- no major hitches while placing shelf items
- save/load completes without visible failure

## Mac-Specific Risks

- Gatekeeper warnings for unsigned builds
- notarization setup time
- Retina UI scaling bugs
- trackpad/mouse differences
- file path and sandbox assumptions if Mac App Store is ever considered

## Apple Developer Account

An Apple Developer account is available. Use it when external Mac distribution requires signing/notarization.

Do not block the first local prototype on full notarization unless distribution requires it.

