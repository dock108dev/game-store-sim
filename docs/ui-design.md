# Game Store Sim UI design

Updated September 21, 2026. Shared Glass UI Starter 01; presentation-only adoption.

## For future contributors

Start with [local design requirements](ui-design-requirements.md), then review the shared [UI Templates gallery](../../UI%20Templates/index.html) and [template guide](../../UI%20Templates/README.md). The source folder on the owner's Mac is `/Users/michaelfuscoletti/Desktop/UI Templates`. It contains dashboard, list/table, form/setup, settings, detail, state/dialog, and native Godot starters.

Use light cool glass, slate text, blue actions, restrained depth, rounded controls, and system typography as the default. Do not reintroduce the generic beige/green/yellow template. Preserve explicit semantic success, caution, error, unavailable, and unknown states. Readability and the task's layout outrank decoration.

The shared folder is a design reference, not a runtime dependency. Project assets are checked in locally and can run without the Desktop folder. If you receive this repository alone, this local requirements copy and the implementation describe the baseline. Request the source template folder when you need the full gallery. Template revisions are adopted deliberately, never silently synchronized.

## This project's adaptation

Working encounter HUD panels, buttons, selectors, numeric fields, and dialogs adopt the native template. Illustrated shop/characters/product art and gameplay are preserved. Godot uses translucent StyleBoxFlat surfaces with opaque-enough fills; it does not claim browser backdrop blur or a native Apple material. Retained samples/evidence are unchanged.

Implementation: encounter/glass_ui.gd; encounter/main.gd.

## Review and status

See [UI adoption verification](ui-verification.md). Source changes and technical/visual checks do not establish owner acceptance, a new release, live-data qualification, or acceptance of an older frozen candidate. Existing project-specific gates remain separate.

## B7 adaptation

B7 retains the local glass theme and illustrated originals. Bills and rack capacity now share stable header positions in base and expanded layouts; actor labels are above bodies with separation. Decorative labels/panels ignore input. Entry, recovery and help dialogs use the same theme and keyboard focus. Normal/Retina technical review is recorded in [B7 delivery](03-production/b7-delivery.md); it does not establish owner acceptance.
