# Stockroom, Receiving, And Office

Status: Active visual bible
Spreadsheet families: Storage, Architecture backroom, Utility, office clutter
Primary IDs: OBJ-010, OBJ-034, OBJ-040, OBJ-246, OBJ-247, plus storage/office rows in Clutter and Utility

## Target Read

The backroom is a clean receiving and office/storage space, not a weird half-wall or catch-all prop pile. It should support the game loop: receive starter inventory, store backstock, manage orders/calendar, and create the sense that the store can grow.

## Locked Decisions

- Stockroom must exist as a real room/function.
- Day-one receiving starts in receiving, not all future inventory sitting around.
- Stockroom is pretty clean.
- Stockroom uses racks.
- Backroom is office + storage.
- Distributor labels/invoice details are not required on day-one boxes.
- Large console boxes may stack; games/accessories should use shelves/racks/tables as appropriate.

## MVP Objects

| ID | Object | Bible Direction |
| --- | --- | --- |
| OBJ-010 | Backroom door | Clear staff doorway from sales floor, real door frame, optional employee-only sign. |
| OBJ-034 | Behind-counter game drawer bank | Can live at back counter or stockroom edge later. |
| OBJ-040 | Customer hold bin | Later reserved-items storage; not day-one priority. |
| OBJ-246 | Shipment cardboard box | Receiving spawn prop for starter goods; clean box, no distributor label fuss required. |
| OBJ-247 | Opened shipment box | Open state with starter products visible. |

## Room Zones

The backroom should contain:

- receiving area
- storage racks
- small office/management desk
- computer/calendar/order-release surface
- clear path between receiving and sales floor

The office computer/calendar is where ordering, release dates, events, expansion options, and backroom work should live. Do not move that backroom management work to the front register.

## Receiving Rules

Receiving should show:

- incoming boxes in a receiving area
- opened box state for setup/tutorial flow
- starter goods that the player can carry/place
- clean floor and clear navigation

Do not show:

- locked/future inventory sitting physically in stockroom
- broad catalog inventory before unlocked/purchased/received
- messy repeated box piles unless player created that state

## Storage Rules

Storage racks should be physical objects with:

- metal frame or utility shelving silhouette
- visible shelves
- capacity for boxed consoles/backstock
- clear empty space
- enough detail to read as real storage from player height

Large console boxes can stack on floor/rack. Games, controllers, handheld consoles, guides, and accessories should generally be on shelves/racks/tables, not loose on floor unless dropped/placed by player.

## Validation Shots

Required:

- sales-floor view toward stockroom door
- stockroom receiving area with starter boxes
- office/desk/calendar/computer view
- storage rack empty/partially stocked view

Pass criteria: the backroom reads as a clean work area that supports receiving and management, not a visual afterthought.
