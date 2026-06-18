# Product And Platform Visual Language Spec

## Goal

Define how fictional games, platforms, cases, stickers, and shelf facings become readable without using real brands.

The product wall needs to feel like a 2002-2004 game store at a glance, but it cannot copy real companies, consoles, game covers, logos, publisher marks, packaging layouts, or protected franchise identities. The visual language should use era-aware shapes, colors, materials, and cover-art composition without becoming a direct analog.

## Player-Facing Result

At normal browsing distance, the player should understand:

- this is a wall or shelf of video games
- products belong to different fictional platforms
- products have genre identity through color/shape/art language
- new and used copies are different
- prices are visible on case stickers
- starter games are physically present only when owned/placed
- some product lines can become recognizable franchises over time

Product details do not need to be fully readable from across the store. The important first read is color, case shape, platform grouping, genre tone, and enough cover detail to make the shelf feel like real merchandise instead of flat blocks.

## Owner Decisions Captured

- Platform branding should not be obvious one-to-one copies of real consoles, but it can feel vaguely era-adjacent.
- Legal safety matters. Do not copy real packaging, logos, console names, publisher marks, mascot silhouettes, trade dress, or cover layouts.
- Product visual language should support two-tone organization: one signal for platform and one signal for genre.
- Early store use may not need both platform and genre organization everywhere, but the system should support both.
- Cover art should be a mix of bitmap art and simple graphic design.
- Shelf-distance readability should mostly come from colors and shapes, with enough cover-art detail to feel intentional.
- Day-one can start with two named games plus one console and one accessory.
- Used copies should visibly differ from new copies, including a `USED` sticker or similar store label.
- Used copies will often live on different shelves, but the case itself should still communicate condition.
- Price labels should be on the case, for example `New $49.99` or `Used $5.99`.
- Starter products should include a sports title like `Footy 2002`.
- Starter products should include one anchor franchise that can support multiple sequels over the game.
- The anchor franchise can be inspired by creature RPGs or fantasy RPGs in broad emotional terms, but must be legally distinct.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Checkout And Trade-In Counter Slice](06-checkout-and-trade-in-counter-slice.md)
- [Master Design Source Of Truth](../design-source-of-truth/00-master-design-source-of-truth.md)
- [Vertical Slice Specification](../design-source-of-truth/01-vertical-slice-spec.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)
- [Asset Inventory Roadmap](../design-source-of-truth/03-asset-inventory-roadmap.md)

Feeds:

- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Signage Branding And Store Identity Spec](10-signage-branding-and-store-identity-spec.md)
- [Lighting Materials And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)
- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)

## In Scope

- Define legal-safe fictional platform language.
- Define two-tone platform/genre product color system.
- Define new versus used case treatment.
- Define case sticker and price label behavior.
- Define starter named products.
- Define cover art readability target.
- Define product module requirements for shelves, tables, and future bins.
- Define tests and screenshot targets for later implementation.

## Out Of Scope

- Full catalog naming for every product.
- Final cover art for all 60 catalog products.
- Real-world brand analog mapping.
- Licensed-looking mascot designs.
- Direct parody of specific real games.
- Future era platforms beyond the existing roadmap, except as locked previews.
- Detailed age-rating/legal-label policy beyond fictional parody marks.

## Legal-Safe Fictionalization Rules

All platform and product art must be fictional.

Allowed:

- broad era cues such as colored spines, jewel/plastic cases, small logos, platform badges, genre icons, and bold cover compositions
- fictional shapes and symbols that feel like game packaging without matching real logos
- original bitmap cover art
- simple graphic-design covers using abstract shapes, fake screenshots, silhouettes, fictional characters, or environment art
- fictional publishers, studios, ratings, awards, and platform badges

Not allowed:

- real console names, logos, controller silhouettes, button layouts, or packaging trade dress
- cover layouts that are close enough to a known real game to read as copied
- mascot silhouettes, creature designs, title lettering, or naming patterns that evoke a protected franchise too directly
- screenshots, scans, or edited real product art
- real ratings-board marks
- publisher/developer names similar to real companies

The target is instant genre/platform readability, not direct recognition.

## Platform Set

Primary early-era platforms remain:

- Nova
- Vertex
- Prism
- Pocket

Future roadmap platforms remain:

- Pocket Advance
- Horizon
- Pulse
- Arc

Do not rename the established platform set in this slice. The product-art system should make these names feel like real categories through color, shape, and shelf organization.

## Two-Tone Product System

Products should support two simultaneous visual signals:

1. Platform signal.
2. Genre signal.

Platform signal should be stable and easy to scan:

- spine band color
- top/bottom case stripe
- platform badge
- shelf divider/header
- small repeated symbol

Genre signal should add variety within platform sections:

- secondary stripe color
- cover-art palette
- icon shape
- sticker accent
- case back/card insert tint

Example implementation pattern:

- platform color lives on the case spine/top stripe
- genre color lives on the cover accent, lower stripe, or corner badge
- price and condition stickers sit above the art language and should remain readable

Early game state may use only platform-first organization, but the art system should already support genre overlays so later inventory can be sorted by platform, genre, condition, or promotion.

## Platform Visual Direction

These are broad directions, not direct mappings to real hardware.

Nova:

- clean, bright, mainstream shelf read
- simple confident shape language
- good for sports, action, racing, and broad releases

Vertex:

- darker, techier shelf read
- angular badge shapes
- good for action, shooters, racing, and mature-leaning titles

Prism:

- colorful, playful shelf read
- rounded badge shapes
- good for adventure, fantasy, family, and RPG titles

Pocket:

- compact portable shelf read
- smaller package proportions or portable badge treatment
- good for puzzle, RPG, sports-lite, and portable-focused titles

Each platform should feel distinct in the store without looking like a real console family.

## Genre Visual Direction

Initial genre colors/icons should support:

- sports
- RPG/adventure
- racing
- action
- family/kids
- horror
- fighting

Starter focus:

- Sports: strong field/ball/motion shapes, green or turf accents, bold jersey-like typography.
- RPG/adventure: character silhouette, crystal/map/sigil shapes, richer fantasy colors, more detailed bitmap art.

Do not overfit genre colors to one platform. Genre is a secondary organization layer that should work across Nova, Vertex, Prism, and Pocket.

## Cover Art Rules

Cover art should be a mix of bitmap illustration and graphic design.

Required:

- original bitmap or repo-generated art for hero covers when visible up close
- simpler graphic covers for filler titles and distant facings
- clear silhouettes, scenes, icons, or patterns
- readable color blocking at 1280x720
- no blank colored rectangles as final product art
- no floating labels in place of cover art

Shelf-distance target:

- title text may be partially readable or mostly implied
- platform and genre should be readable first
- cover art should show enough detail that the product feels designed
- player should not need to read every title to understand the shelf

Close-up/interaction target:

- selected products should expose readable title, platform, condition, and price
- interactive products should match inventory data

## Case Stickers And Price Labels

Each sellable case should support a case price sticker.

Examples:

- `New $49.99`
- `Used $5.99`
- `Used $12.99`
- `New $39.99`

Sticker rules:

- price sticker is on the case, not only shelf strip
- shelf strips can still exist for section pricing or promotions
- sticker should not hide the platform badge
- sticker should not hide the main cover-art read
- sticker should support new and used condition text
- used sticker should be visibly different from new pricing

Used copy sticker:

- add a clear `USED` label or store-branded equivalent
- can include scuff/fade/sticker residue variation
- should remain legible from near shelf distance

New copy treatment:

- cleaner case
- no used sticker
- stronger cover color
- price sticker still present

## Starter Product Set

Day-one named product target:

- `Footy 2002`: starter sports title, likely soccer/football depending final catalog direction.
- `Aether Quest`: starter anchor fantasy/creature-adventure RPG franchise candidate.

`Footy 2002` rules:

- broad sports read
- original cover art
- no real league, team, athlete, badge, kit, tournament, or publisher references
- strong motion/field/ball shape language
- suitable for a common starter product

`Aether Quest` rules:

- anchor franchise that can support sequels and later releases
- broad fantasy or creature-adventure inspiration without copying any specific franchise
- original creatures/characters/sigils only
- title system can expand to sequels, special editions, guides, posters, and later launch events
- should be memorable enough to become a store-recognizable product line

These names are internal working production names until owner review and name-clearance review. They are acceptable for planning and implementation placeholders, but they are not legally cleared ship names.

## Day-One Inventory Relationship

Opening setup remains lean:

- one or two unique games
- one console/hardware item
- one accessory
- no fake full wall of locked products

Vertical-slice shelf density can later use lightweight facings, but day-one setup must not imply the player owns or can sell products that are not available.

Physical placement rules:

- owned/placed products can appear as full interactive items
- visual facings can fill later shelves only when they match available/owned stock or approved non-interactive density rules
- future locked products belong in catalog screens, coming-soon signage, posters, or locked previews, not stocked shelves

## Required Modules

Implementation should produce or standardize modules for:

- standard game case
- used game case variant
- platform spine/badge overlay
- genre accent overlay
- case price sticker
- used sticker
- platform divider
- product-facing shelf anchor
- compact portable case variant if needed for Pocket
- cover-art texture/material slot

Later modules:

- guide/media cover format
- accessory blister/card package
- console box package
- preorder card
- coming-soon product card
- clearance sticker set
- condition/scuff decal set

## Likely Asset Files

Likely created or updated:

- `game/assets/textures/products/*.png`
- `game/assets/textures/products/covers/*.png`
- `game/assets/textures/products/stickers/*.png`
- `game/assets/textures/platforms/*.png`
- `game/assets/materials/products/*.tres`
- `game/assets/data/products/*.json`

Exact paths may change if implementation creates a cleaner asset folder structure.

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/modules/products/*.tscn`
- `game/scenes/world/modules/signage/*.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`

## Likely Script Files

Likely touched during implementation:

- product catalog definitions
- product visual factory or module registry
- stocking/product placement scripts
- fixture slot rendering scripts
- price/condition label generation
- save/load for stocked product visual state

Implementation should preserve existing catalog, pricing, stocking, and sale mechanics. This slice is about giving those products a coherent visual identity.

## Data Requirements

Each product should eventually define:

- product id
- title
- franchise id, if applicable
- platform id
- genre id
- condition support
- new price
- used price range or used price
- cover art id
- spine art id or platform badge
- genre accent id
- case model type
- unlock state
- stockable fixture types

Each platform should define:

- platform id
- display name
- primary color
- secondary/accent color
- badge shape
- shelf header treatment
- case type
- supported era window

Each genre should define:

- genre id
- display name
- accent color
- icon/symbol direction
- cover-art composition notes

## Tests To Add Or Update

Later implementation should add or update tests for:

- early platform ids remain Nova, Vertex, Prism, and Pocket
- product definitions do not use banned real-world names or known platform labels
- starter working names are flagged as not legally cleared ship names until reviewed
- starter catalog includes `Footy 2002`
- starter catalog includes the anchor franchise starter product
- cases can render platform and genre visual signals
- used variants include used sticker/condition marker
- price stickers include condition and price
- non-interactive facings do not imply locked inventory is owned
- stocked products appear on fixture slots with visible case art

Doc/status tests should include this slice as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `product_case_new_closeup.png`: new case with platform/genre language and price sticker.
- `product_case_used_closeup.png`: used case with `USED` sticker and used price.
- `product_shelf_platform_read.png`: shelf section where platform group is readable before title text.
- `product_shelf_genre_variation.png`: products within one platform showing genre variation.
- `product_starter_footy_2002.png`: starter sports cover visible on fixture.
- `product_starter_anchor_franchise.png`: starter anchor RPG/adventure cover visible on fixture.
- `product_1280_shelf_read.png`: 1280x720 view where product wall reads as game inventory without licensed marks.

## Acceptance Checklist

- [ ] Product language is fictional and legally distinct.
- [ ] Nova, Vertex, Prism, and Pocket remain the primary early platform set.
- [ ] Platform signal and genre signal can coexist on cases.
- [ ] Cover art uses bitmap/simple graphic mix, not blank blocks.
- [ ] Product shelves read through color, shapes, and cover composition before text.
- [ ] New and used condition are visually distinct.
- [ ] Used cases include a visible `USED` label or equivalent.
- [ ] Case price stickers include condition and price.
- [ ] `Footy 2002` exists as a starter sports product.
- [ ] An anchor RPG/adventure franchise starter product exists and can support sequels.
- [ ] Day-one inventory remains limited and does not fake a full future catalog.
- [ ] Product visuals work on shelves, tables, and future bins.

## Fail Conditions

This slice fails if:

- products look like flat colored cubes
- real platform/game trade dress is copied
- cases rely on floating labels instead of art/stickers
- platform sections are indistinguishable
- genre variation makes platform grouping unreadable
- used products do not visibly differ from new products
- price/condition is only on hidden UI and not on the physical case
- day-one shelves show unavailable future products as stocked inventory
- starter anchor franchise is too close to a real protected franchise

## Stop/Ask-Owner Conditions

Stop and ask before:

- using a product name, logo, character, or layout that resembles a real game or platform
- replacing the established Nova/Vertex/Prism/Pocket platform set
- making title text the only way to distinguish products
- adding a full starter catalog wall that conflicts with minimal opening inventory
- choosing final anchor franchise branding if it starts to resemble a known franchise
- treating `Footy 2002`, `Aether Quest`, or any other working title as a cleared final ship name without name review

Do not stop for normal cover-art, color, or title iteration if the system keeps the legal-safe fictionalization rules and two-tone organization intact.

## Commit Expectation

Commit the product/platform visual-language implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from required-zone layout, density polish, signage, and lighting unless those are needed to prove product shelf readability.

## Next Document

After this doc, write `08-required-zones-slice.md` to define new releases, used games, demo, bargain, guides/media, hardware, receiving support, and how those zones emerge from player-placed fixtures.
