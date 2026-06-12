# Day One Stock And Unlocks

## Purpose

Keep the opening store visually restrained and progression-friendly.

The full catalog can exist in data, but the day-one store should not look like a fully built game shop. It should feel like a new owner setting up the first small selection before opening for business.

## Implementation Status

Mechanically present, but superseded for visual approval by the opening mall/storefront reset. Current scene surfaces separate owned starter stock from future catalog/design/supplier inventory and route paid/order inventory through receiving instead of preloading it into the stockroom; these flow rules remain active while the opening composition is reviewed.

## Day-One Sales Floor Rule

Start with a small sellable assortment:

- 2 new games.
- 1 console or refurb hardware box.
- 1 accessory, such as a controller.
- Trade-in intake enabled so the player can grow inventory from customers.

This is the default visual assumption for the first implementation slice unless owner review changes it.

## Locked Catalog Rule

Locked or future inventory should not physically sit in the stockroom. It can exist as:

- Empty shelf space.
- Upcoming-product catalog entries.
- Store-design or fixture catalog entries.
- Supplier catalog entries that cost money to order.
- Release board hints for later launch stock.
- Empty shelf labels or category signs that imply future expansion.

Locked inventory becomes physical only after the player unlocks or buys it. Once purchased or ordered, it should arrive through receiving, supplier delivery, release shipment, or customer trade-in flow.

Locked inventory should not appear as sellable sales-floor merchandise or as waiting stockroom inventory.

## Opening Flow

Preferred first-session fantasy:

1. Player starts with owned starter stock in the stockroom/backroom.
2. Player carries product to the sales floor.
3. Player prices and places the starter items.
4. Player opens for business for the first time.
5. Trade-ins, paid catalog unlocks, supplier orders, and releases expand the physical store over time.

This flow makes the store setup readable and gives empty shelf space a purpose.

## Visual Implications

- Less is more in the first sales-floor pass.
- Empty shelves should look intentional, not unfinished.
- Backroom starter stock should look owned and ready to be placed.
- Future stock should live in catalogs, release boards, or store-design menus until purchased.
- Shelf/category signage can imply future expansion.
- Product density should increase through progression, supplier orders, trade-ins, releases, and fixture unlocks.

## Implementation Implications

Likely affected:

- Starter inventory data.
- Product unlock rules.
- Catalog/design-store availability.
- Supplier/release availability.
- Stockroom spawn placement.
- Receiving arrival placement after purchase/order.
- First-open tutorial/checklist, if added.
- Screenshot expectations for `main_scene.png`, `stocked_aisle.png`, `receiving_area.png`, and `supplier_delivery.png`.

## Pass Criteria

- Day-one screenshots show a modest new shop, not a fully stocked retail endpoint.
- Starter items are physically understandable before labels.
- Empty sales-floor capacity reads as planned growth.
- Owned stockroom starter items give the player a clear setup task.
- Locked/future items are discoverable in catalogs or planning surfaces, not sitting in storage.
- Trade-ins remain a believable way to grow early inventory.

## Fail Criteria

- The store opens with the full catalog visible on shelves.
- Empty shelves look like missing art rather than early-stage shop capacity.
- Locked products appear sellable.
- Locked products appear as stockroom inventory before purchase/order.
- The first visual slice creates so much merchandise that progression has no visual room left.
