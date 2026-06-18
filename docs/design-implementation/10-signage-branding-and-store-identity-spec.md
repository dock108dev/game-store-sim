# Signage Branding And Store Identity Spec

## Goal

Define the store identity and signage system for the opening visual reset.

The store needs to read like a chill early-2000s mall game shop: readable, functional, a little underfunded, and easy to customize later. Signage should communicate store identity, open/closed state, staff-only boundaries, demo area, prices, conditions, and promotions without becoming tutorial text or visual noise.

## Player-Facing Result

At opening setup, the player sees:

- a temporary editable store name
- a standard early-2000s mall storefront sign
- readable open/closed and employees-only signage
- clean store-made labels for shelves and fixtures where applicable
- case price/condition labels on products
- posters for new releases, trade-in deals, upcoming releases, and new-now-on-sale promotions
- neighboring mall signs that read as background flavor

The store should feel relaxed and practical. The signs should help the world read, not shout mechanics at the player.

## Owner Decisions Captured

- `Games4U` is temporary and editable.
- Storefront sign should feel like a standard 2005 mall sign.
- Sign format can be a strip sign or regular mall sign depending on final design.
- Shelf/fixture labels should be clean, consistent, store-made, standard, and editable.
- Day-one sign categories should include store logo/name, open/closed, employees-only, demo, price/condition, and shelf labels.
- Fixture labels are not a required day-one signage category unless they are needed by player-assigned shelves/labels.
- Posters should focus on new releases, trade-in deals, upcoming releases, and new-now-on-sale messaging.
- Signs should generally use readable text.
- Smaller shelf items should not each need separate large signs.
- A full shelf can have one label, with defaults like `Potpourri` when the player has not chosen a specific category.
- Neighboring mall store signs are flavor, not focus.
- Copy tone should be chill and sim-like, not overly jokey, corporate, modern, or tutorial-heavy.

## Dependencies

Required:

- [Design Implementation Index](README.md)
- [Visual Module System Spec](02-visual-module-system-spec.md)
- [Store Shell And Mall Entrance Slice](03-store-shell-and-mall-entrance-slice.md)
- [Starting Store Layout Spec](04-starting-store-layout-spec.md)
- [Fixture Grid Slice](05-fixture-grid-slice.md)
- [Product And Platform Visual Language Spec](07-product-and-platform-visual-language-spec.md)
- [Required Zones Slice](08-required-zones-slice.md)
- [Density And Clutter Rules](09-density-and-clutter-rules.md)
- [Store Design And World Building](../design-source-of-truth/02-store-design-world-building.md)

Feeds:

- [Lighting Materials And Color Palette Spec](11-lighting-materials-and-color-palette-spec.md)
- [Validation And Screenshot Checklist](12-validation-and-screenshot-checklist.md)
- [Agent Work Packet Template](13-agent-work-packet-template.md)

## In Scope

- Define editable store name behavior.
- Define storefront sign visual target.
- Define core day-one sign categories.
- Define shelf label behavior and defaults.
- Define poster/promotion categories.
- Define neighboring mall sign rules.
- Define copy tone and anti-tutorial rules.
- Define tests and screenshots for later implementation.

## Out Of Scope

- Final logo lock.
- Full poster art catalog.
- Mature-store promotional calendar.
- Deep typography system beyond practical readability.
- Full neighboring mall branding package.
- Real brand or real game parody signs.

## Store Name And Identity

`Games4U` is the working default, not final locked brand.

Rules:

- store name is editable
- `Games4U` may be used as default placeholder
- store name should appear on storefront sign
- store name should be reusable in UI and signs where appropriate
- name changes should propagate to major store identity signs if supported
- final shipping name requires owner review and name-clearance review

Store tone:

- independent game shop
- approachable
- practical
- lightly nostalgic
- not corporate
- not meme-heavy
- not luxury retail

## Storefront Sign

The storefront sign should read as a standard 2005 mall sign.

Acceptable forms:

- strip sign above storefront
- regular rectangular mall sign
- simple backlit plastic sign
- simple mounted sign panel

Rules:

- readable from mall approach
- not a real retailer imitation
- not overdesigned as a modern boutique sign
- should integrate with mall storefront modules
- should leave room for editable name text
- should not rely on floating debug labels

The final choice between strip sign or regular sign can be made during implementation based on what fits the storefront composition best.

## Core Day-One Sign Categories

Required day-one signs:

- store name/logo sign
- open/closed sign
- employees-only sign for stockroom/backroom
- demo sign
- price/condition labels on cases
- shelf labels where the player assigns or accepts defaults

Not required day one:

- full fixture signage package on every object
- platform aisle headers if the player has not organized that way
- bargain signage before bargain unlock
- guides/media signage before guides/media unlock
- mature sale campaign signage

Signs should emerge from store state and player organization. If there is no bargain bin, there should not be a bargain sign pretending the zone exists.

## Shelf And Fixture Labels

Shelf labels should be clean store-made labels.

Rules:

- labels are consistent and editable
- labels attach to shelves, label rails, or fixture surfaces
- one shelf can have one label for the full shelf
- small individual items do not need large individual signs
- shelf label text should be readable close-up and reasonably readable at normal browsing distance
- labels should not float in space
- labels should not replace product art, case stickers, or fixture shape

Default labels:

- `Potpourri`
- `New Releases`
- `Used Games`
- `Hardware`
- `Demo`
- `Accessories`
- `Custom`

`Potpourri` can be the default mixed-shelf label when a shelf contains uncategorized or mixed products. The player should be able to rename it.

Fixture labels are optional unless the player assigns them or the fixture/system needs them to communicate a role.

## Price And Condition Labels

Product case labels remain part of the product visual language.

Required:

- case sticker includes condition and price
- examples: `New $49.99`, `Used $5.99`
- condition/price labels are readable up close
- shelf labels do not replace case price stickers
- used condition remains visible on used products

Shelf price strips may exist later for promotions or category pricing, but case-level condition/price labeling is the primary day-one requirement.

## Posters And Promotions

Poster categories:

- new releases
- trade-in deals
- upcoming releases
- new-now-on-sale promotions

Poster rules:

- fictional games and platforms only
- no real brand/game trade dress
- readable headline or strong visual hierarchy
- chill sim tone
- posters support store personality but should not crowd the walls day one
- posters should be replaceable/updateable where practical

Example poster copy tone:

- `New Releases`
- `Trade-In Bonus`
- `Coming Soon`
- `Now On Sale`
- `Demo Today`

Avoid:

- heavy tutorial copy
- exaggerated joke slogans
- corporate retail buzzwords
- modern social-media language
- legal-risk parody of real game ads

## Demo Signage

Demo signage should clearly identify the demo area.

Rules:

- demo sign is day-one allowed
- sign can be near the demo kiosk/display
- sign should not hide the demo hardware
- text should be readable
- copy should be simple

Examples:

- `Demo`
- `Try It`
- `Now Playing`

Demo signage should support the out-of-box demo item and make the front-area purpose clear.

## Employees-Only Sign

The stockroom/backroom needs a readable employee boundary.

Rules:

- place on or near stockroom/backroom door
- readable from sales floor
- small enough to feel like a real sign
- not a giant warning billboard

Examples:

- `Employees Only`
- `Stockroom`
- `Staff Only`

The sign supports architecture. It should not be the only thing making the stockroom read as a backroom.

## Open/Closed Sign

Open/closed sign should support the day loop.

Rules:

- visible from storefront/entrance
- state changes with open/closed flow where implementation supports it
- day-one setup starts closed
- opening the store should make the open state readable

Acceptable forms:

- hanging door sign
- small illuminated sign
- window decal/sign

Do not overbuild this into a large UI panel. It is a store prop tied to store state.

## Neighboring Mall Signs

Neighboring mall signs are background flavor.

Rules:

- simple fictional store names
- readable enough to suggest a mall, not important enough to distract
- no real brands
- no detailed promotional systems needed
- muted or lower-contrast compared to the main store sign

Neighbor signs should help the mall feel occupied without stealing focus from the player’s shop.

## Copy Tone

The copy should feel chill and practical.

Use:

- short phrases
- straightforward retail language
- fictional game/platform names
- readable sale/trade-in/release wording
- light personality only where it fits naturally

Avoid:

- too much tutorial language
- jokes on every sign
- corporate voice
- modern app/social language
- lore-heavy signage in the opening store
- oversized text explaining mechanics

This is a sim. The signs should make the shop believable and usable.

## Required Modules

Implementation should produce or standardize modules for:

- editable storefront sign
- open/closed sign
- employees-only sign
- demo sign
- shelf label rail/plate
- case price/condition sticker
- poster frame/template
- mall neighbor sign

Later modules:

- sale campaign sign
- upcoming release poster set
- trade-in promotion poster set
- platform header signs
- bargain sign
- guides/media sign
- decoration catalog poster variants

## Likely Asset Files

Likely created or updated:

- `game/assets/textures/signage/*.png`
- `game/assets/textures/posters/*.png`
- `game/assets/textures/store_brand/*.png`
- `game/assets/materials/signage/*.tres`
- `game/assets/data/signage/*.json`

Exact paths may change if implementation creates a cleaner asset folder structure.

## Likely Scene Files

Likely touched during implementation:

- `game/scenes/world/modules/signage/*.tscn`
- `game/scenes/world/modules/storefront/*.tscn`
- `game/scenes/world/modules/fixtures/*.tscn`
- `game/scenes/world/modules/mall/*.tscn`
- `game/scenes/world/store_world.tscn`
- `game/scenes/world/graybox_store.tscn`

## Likely Script Files

Likely touched during implementation:

- store identity/settings scripts
- sign text binding scripts
- shelf label scripts
- open/closed state scripts
- poster/catalog scripts
- save/load for custom labels/store name

Implementation should preserve the working retail loop while replacing visible debug labels with believable signage.

## Data Requirements

Store identity state should include:

- store display name
- editable flag
- default name
- sign text binding ids

Sign definitions should include:

- sign id
- sign category
- text source
- editable flag
- placement role
- visibility/unlock state
- material/texture style
- readability tier

Shelf label definitions should include:

- fixture id
- label text
- default label
- custom label flag
- assigned category if any

Poster definitions should include:

- poster id
- promotion type
- related product/platform if any
- unlock/availability state
- replaceable flag

## Tests To Add Or Update

Later implementation should add or update tests for:

- store name defaults to `Games4U` or current working default
- store name is editable and persists
- storefront sign reads from store name state
- open/closed sign reflects store state
- employees-only sign exists at stockroom/backroom boundary
- demo sign exists near demo area
- shelf labels support default and custom text
- fixture labels are not required on every fixture
- case price/condition labels remain on product cases
- poster categories use fictional content only
- neighboring mall signs are fictional flavor
- no final signage relies on floating debug labels

Doc/status tests should include this doc as an active planning document once written.

## Screenshot Targets

Capture these once the implementation exists:

- `signage_storefront_name.png`: editable storefront name sign from mall approach.
- `signage_open_closed.png`: open/closed sign visible near entrance.
- `signage_employees_only.png`: stockroom/backroom boundary sign.
- `signage_demo_area.png`: demo sign near day-one demo setup.
- `signage_shelf_label.png`: clean editable shelf label with one full-shelf label.
- `signage_case_price_condition.png`: product case sticker with condition and price.
- `signage_posters_promos.png`: release/trade-in/upcoming/sale poster examples.
- `signage_mall_neighbor_flavor.png`: neighboring mall signs as background flavor.

## Acceptance Checklist

- [ ] Store name is temporary/editable.
- [ ] `Games4U` remains a working default, not locked final brand.
- [ ] Storefront sign reads as a standard early-2000s mall sign.
- [ ] Day-one signs include store name, open/closed, employees-only, demo, price/condition, and shelf labels.
- [ ] Shelf labels are clean, consistent, store-made, editable, and attached to real fixtures.
- [ ] `Potpourri` or equivalent mixed/default shelf label is supported.
- [ ] Posters focus on new releases, trade-in deals, upcoming releases, and new-now-on-sale promotions.
- [ ] Neighboring mall signage reads as fictional background flavor.
- [ ] Copy tone is chill, practical, and sim-like.
- [ ] Signs do not become tutorial walls or debug labels.

## Fail Conditions

This slice fails if:

- the store name is hard-locked without editability
- storefront sign looks modern/luxury/corporate instead of mall-retail practical
- signage uses real brands, real games, or copied trade dress
- shelf labels float in space
- every small shelf item gets noisy individual signage
- posters crowd the store before there is density to support them
- mall neighbor signs steal attention from the player store
- copy reads like tutorial instructions instead of store signage
- signs replace visual object design instead of supporting it

## Stop/Ask-Owner Conditions

Stop and ask before:

- finalizing a non-editable store brand
- shipping a final store name without owner/name-clearance review
- copying real store/game/platform sign language
- making fixture labels mandatory on every fixture
- adding heavy joke/corporate/tutorial copy
- making neighboring mall signs more important than the player store

Do not stop for normal sign format, font, or poster-layout iteration if the signs stay readable, fictional, chill, and editable where required.

## Commit Expectation

Commit the signage/branding implementation as its own slice after docs, tests, and screenshots are updated.

The commit should be reviewable independently from lighting, validation checklist, and roadmap work unless those are required to prove sign readability.

## Next Document

After this doc, write `11-lighting-materials-and-color-palette-spec.md` to define mall/store lighting, material palette, contrast, flooring, fixtures, and color restraint.
