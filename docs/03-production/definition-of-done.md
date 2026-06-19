# Definition Of Done

## Global Definition

A feature is done only when:

- it works in the game
- it is represented in docs if it affects design or architecture
- it persists correctly if it affects state
- it has automated validation where practical
- it has manual validation steps if player feel matters
- it does not introduce script/runtime errors
- it respects fictional IP policy
- it runs in a macOS build if the feature is part of playable scope

## First Playable Done

The 0.0%-0.3% first playable is done when:

- player can complete the first day loop
- starter shipment produces physical items
- used items can be priced
- new item price is fixed
- items can be placed on shelves
- at least one fixture can be moved
- customers physically spawn from mall paths
- at least one customer can buy an item
- register records sale
- daily report summarizes sale
- save/load restores state
- Mac build launches
- local validation gate passes
- manual playtest checklist passes

## Documentation Done

A doc is done when:

- purpose is clear
- owner or intended reader is obvious
- decisions are explicit
- open questions are listed
- it links to related docs
- it avoids pretending unresolved choices are final

## Art Asset Done

An asset is done when:

- it is fictionalized
- it matches art direction
- it has clean scale
- collision is appropriate
- import settings are documented or predictable
- it performs acceptably in first playable scene
- it has no copied real-world branding

## Gameplay System Done

A gameplay system is done when:

- state transitions are defined
- invalid states are handled
- save/load behavior is defined
- validation exists
- UI feedback exists if player-facing
- failure behavior is understood

## Validation Done

Validation is done when:

- local gate runs from one command
- logs are stored in predictable location
- failures are visible
- screenshot sanity exists for playable scenes
- script/runtime errors are treated as failures
- manual checklist is updated for player-facing changes

