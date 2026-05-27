# BRAINDUMP

## Goal

Make the Retro Games first-day store feel spatially believable, readable, and ready for early gameplay.

The core flow is working. This pass should focus on the store’s physical layout, prop readability, and interaction staging. Do not add new gameplay systems unless needed to validate the layout.

## Current Problems

The store is improving, but still reads too small and a little improvised.

Main issues:
- Store floor feels cramped and undersized.
- Stock room feels too small / closet-like.
- Stock room should be at least roughly half the size of the main retail room.
- Register / checkout currently reads as a bunch of separate geometry objects, not one coherent checkout station.
- Door / glass frame is visually dominant and awkward from several angles.
- Some views are mostly blank wall, oversized door geometry, or disconnected props.
- Shelves are readable as shelves, but the product presentation should be more intentional.
- The first-day store should feel sparse, but not empty or broken.

## Important Constraint: Early Inventory Is Small

Shelves and tables should clearly read as store fixtures, but they should stay minimal.

For the first couple days, the store should only have about 3-7 distinct sellable things total. That is okay. The layout should support sparse early inventory without looking unfinished.

Use:
- a few distinct product types
- multiple copies/facings where useful
- empty shelf space that looks intentional
- simple labels/price tags
- small display groupings

Avoid:
- fully stocked big-box-store shelves
- clutter everywhere
- dozens of unique products
- visual noise that implies systems we do not have yet

The target is “small shop before opening, lightly stocked,” not “warehouse full of products.”

## Priority 1: Store Scale And Floor Plan

Expand or rebalance the Retro Games store so it feels like a real small retail unit.

The player should immediately understand:
- where the front/sales floor is
- where the checkout/register is
- where shelves/display tables are
- where the stock room is
- where the mall exit is

The store should have enough open walking space for:
- player
- manager
- future customers
- shelf interaction
- register interaction
- stock room movement

Acceptance:
- From the spawn/entry view, the room layout reads clearly.
- The store no longer feels like a narrow corner with props pushed against walls.
- Movement paths between shelf, register, stock room, and exit are obvious.

## Priority 2: Stock Room

Make the stock room substantial.

It should be at least roughly half the size of the main retail room, or large enough that it clearly reads as a working back room rather than a closet.

The stock room should include:
- storage shelves
- boxes/crates
- a stock table or small sorting surface
- clear floor space
- clear doorway/threshold
- slightly different lighting/material tone from the retail floor

It should feel useful for future gameplay:
- stocking shelves
- receiving inventory
- sorting boxes
- learning the back-room loop

Acceptance:
- A screenshot looking into the stock room clearly reads as “stock room.”
- A screenshot from inside the stock room shows enough space to work.
- Door/threshold does not visually dominate the whole store.

## Priority 3: Register / Checkout Station

Rebuild the register area so it reads as one coherent checkout station.

Current issue: it looks like unrelated geo pieces grouped near a person.

The checkout should include:
- a single clear counter volume
- customer-facing side
- employee/manager side
- POS/register screen
- cash drawer or register body
- card reader / scanner / receipt detail
- small bagging or counter surface
- manager standing position that makes sense

Keep it simple, but make it feel assembled as one object group.

The manager should be visually anchored to the register. They should look like they belong behind or beside the checkout, not like they are standing near random props.

Acceptance:
- From normal gameplay distance, it reads as “checkout/register.”
- The manager prompt appears in a place that makes visual sense.
- The station has a clear interaction side for the player.

## Priority 4: Shelves, Tables, And Product Readability

Shelves/tables should be obvious but minimal.

We only need a small early inventory presentation:
- 3-7 distinct things total
- maybe multiple copies/facings
- enough empty space to imply early-day scarcity
- clear product silhouettes

Possible product reads:
- boxed games
- cartridges
- small console boxes
- accessory boxes
- bargain bin items
- display case items

Fixtures should include:
- one main shelf wall
- one small display table or front shelf
- optional small counter display

Do not overfill the space. The store should feel like it is just starting out.

Acceptance:
- Products are recognizable from normal camera distance.
- Empty shelf/table space feels intentional, not missing.
- Product scale is consistent between shelf, table, register, and stock room.

## Priority 5: Door And Mall Exit Geometry

Fix the front door / glass door / exit area.

Current issue: the door frame is visually heavy and awkward from multiple angles. It sometimes dominates the view or makes the store feel smaller.

Improve:
- door scale
- frame thickness
- glass opacity/readability
- threshold/floor transition
- interaction prompt placement
- sightlines into/out of store

Acceptance:
- Door looks like a mall storefront entrance.
- It does not slice through or occlude important interior views.
- “Exit to Mall” prompt appears only when the player is clearly at/looking at the exit.

## Priority 6: Lighting And Camera Readability

Improve lighting so screenshots communicate the room.

Need:
- warm readable sales floor
- slightly cooler/dimmer stock room
- readable checkout zone
- less flat blank wall dominance
- fewer huge dark shapes swallowing the frame

Do not make it flashy. Keep it simple and mall-store-like.

Acceptance:
- Shelf wall, register, stock room, and exit are all readable in screenshots.
- The store still feels early/pre-opening.
- No key prop is hidden by darkness or silhouette.

## Priority 7: First-Day Training Staging

The first-day training HUD/task flow is working. Now the physical staging should support it.

Training tasks:
- talk to manager
- register
- back room
- shelf stock

The room should make those targets visually discoverable.

Acceptance:
- Player can infer where to go for each task without relying only on HUD text.
- Manager/register/stockroom/shelf are arranged in a sensible onboarding route.
- Interact prompts appear in clean, non-confusing positions.

## Non-Goals

Do not focus on:
- new economy systems
- customer AI
- expanded inventory mechanics
- new UI panels
- save/load
- multiple stores
- complex art pass
- high-detail assets

This is a layout/readability pass.

## Definition Of Done

The pass is successful when the first-day Retro Games store:
- feels larger and spatially believable
- has a meaningful stock room
- has a coherent checkout/register station
- has readable minimal shelves/tables
- supports only a small early inventory of 3-7 distinct things
- has a cleaner mall exit/door area
- makes the first-day training route visually obvious
- produces screenshots where the player can understand the store without explanation
