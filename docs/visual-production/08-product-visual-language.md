# Product Visual Language

## Goal

Define how products look in hand, on shelves, in receiving, and at checkout.

The product language must support progression. The full family list is the eventual vocabulary, not the day-one shelf state.

## Product Families

Required families:

- New game sealed case.
- Used game case.
- Loose disc sleeve.
- Cartridge.
- Boxed accessory.
- Boxed/refurb hardware.
- Strategy guide or magazine.
- Service ticket.

Day-one visible starter set:

- 2 new game sealed cases.
- 1 console or refurb hardware box.
- 1 boxed accessory, preferably a controller.
- Used/trade-in product visuals available through customer intake, not necessarily pre-stocked on shelves.

## Fictional Platform Treatment

Platform identity should come from:

- Shelf-strip color.
- Spine color.
- Small fictional platform mark.
- Case shape/material differences.
- UI/catalog text.

Avoid real-world shapes that are too close to protected console trade dress.

## Case And Tag Rules

Every product family needs:

- Recognizable silhouette.
- Front-facing read.
- Spine read.
- Price tag location.
- Condition cue location.
- Risk/authenticity cue only when relevant.

Tags should be small but readable. They should not become giant labels that replace object art.

Locked or future products should have a clear non-sellable planning presentation if shown at all: unavailable catalog entry, store-design catalog entry, release-board hint, supplier preview, or empty shelf label. They should not appear as physical backroom stock until the player buys, orders, unlocks, receives, or accepts them through trade-in flow.

## Condition Cues

Use visible cues:

- Cracked case corner.
- Missing manual sticker.
- Loose sleeve.
- Scuff mark.
- Reseal strip.
- Inspection sticker.
- Handwritten used-price sticker.

## Implementation Files

Likely affected:

- `game/scripts/inventory/product_item.gd`
- `game/scripts/inventory/product_visual_rules.gd`
- `game/scenes/props/placeholder_used_game.tscn`
- future product mesh/material assets.
- `game/tests/gut/test_product_item.gd`
- `game/tests/gut/test_product_visual_rules.gd`
- `game/tests/gut/test_product_catalog.gd`

## Acceptance Screenshots

- `stocked_aisle.png`
- `carry_stack.png`
- `receiving_area.png`
- `trade_in_offer.png`
- `register_counter.png`

## Pass Criteria

- Products look like game-store merchandise at shelf, hand, and counter scale.
- Used/new/accessory/hardware/service products read differently.
- Fictional platform identity is coherent.
- Product visuals support pricing and condition gameplay.
- Day-one product density leaves room for progression and trade-in growth.

## Fail Criteria

- Products are colored boxes with labels.
- Price/condition cues are unreadable.
- Platform identity implies real brands.
- Locked products look sellable on day one.
- Future products sit physically in the stockroom before purchase/order.
