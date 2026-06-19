# First 0.3% Visual Benchmark

This document defines the visual benchmark for the first 0.3% of Game Store Sim.

The engine proof proved that Godot, macOS export, validation, basic item state, customer state, sale state, and save/load can work. It did not prove the game looks right.

The next production phase is visual-first. Do not expand gameplay breadth until this benchmark is signed off.

## Goal

Build the visual scaffold for the opening store so future systems expand on a strong visual foundation instead of re-solving the look later.

The target player reaction is:

> This already feels like a warm early-2000s mall game shop, even before the full systems exist.

## Scope

This benchmark covers only the 0.0%-0.3% opening experience:

- mall concourse
- storefront
- empty lease/sales floor
- counter/register
- receiving/backroom
- starter shipment
- starter shelves/racks
- physical game cases and boxes
- carried item view
- first stocked shelf view
- first customer entering/browsing view
- first daily report view

## Non-Goals

Do not add:

- trade-ins
- returns
- services
- supplier networks
- full secret web
- employees
- neighboring-unit expansion
- launch calendar
- rare inventory
- new customer archetype complexity

Do not polish:

- final character animation systems
- final UI flows beyond benchmark presentation
- final soundscape, unless simple ambience helps visual read
- full product catalog

## Visual Pillars

### Mall First

The player must immediately understand the shop exists inside a mall.

Required cues:

- concourse outside storefront
- mall path left/right
- storefront glass
- store sign position
- threshold/entrance
- neighboring mall-space hints without requiring full adjacent shops

### Understocked, Not Unfinished

The first store is sparse, but it must look intentionally underfunded.

Required cues:

- clean but cheap starter fixtures
- visible shelf gaps
- boxed starter shipment
- operational counter
- enough product color to promise growth
- no giant empty debug-looking spaces

### Physical Retail Scale

The world must make sense at human scale.

Required cues:

- case size feels handleable
- shelves fit real case rows
- counter height feels usable
- backroom/receiving has plausible clearance
- player camera height does not make fixtures feel toy-like

### Products Create Color

The environment should not carry the whole visual identity. Fictional product boxes, case rows, price stickers, shelf headers, and promo surfaces provide the color.

Required cues:

- several fictional case-cover color families
- visible price sticker language
- platform/category strips
- new/used distinction
- no real IP or close parody

### Fixtures Create Structure

Fixtures must become reusable scaffolding for future expansion.

Required cues:

- wall shelf/rack
- freestanding shelf/gondola
- checkout counter
- receiving table/box area
- shelf capacity states that can scale from empty to dense

### Signage Creates Final Read

Signage should clarify the store without explaining the game.

Required cues:

- fictional storefront sign
- open/closed sign
- shelf category header
- simple price/sale tags
- no walls of meaningless posters

## Required Visual Targets

Each target needs a named screenshot from a macOS build.

### 01 Storefront From Mall

Filename:

```text
01-storefront-from-mall.png
```

Must show:

- mall concourse
- glass storefront
- entrance threshold
- store sign or sign placeholder with final scale
- warm retail lighting through the glass

Pass criteria:

- reads as mall storefront in one glance
- not a generic exterior wall
- no debug-looking blank planes dominate

### 02 Empty Sales Floor

Filename:

```text
02-empty-sales-floor.png
```

Must show:

- starter floor
- counter/register
- starter shelves
- visible empty capacity
- route to backroom or receiving

Pass criteria:

- sparse but intentional
- clear customer/player paths
- counter is identifiable

### 03 Receiving And Backroom

Filename:

```text
03-receiving-backroom.png
```

Must show:

- starter shipment box
- receiving surface or staging area
- backroom computer or office hint
- operational clutter that is retail-specific

Pass criteria:

- looks like goods enter the business here
- not a random storage closet

### 04 Starter Shipment Open

Filename:

```text
04-starter-shipment-open.png
```

Must show:

- open or staged shipment
- multiple physical items
- invoice/manifest surface or visual cue
- one harmless odd-detail surface if present

Pass criteria:

- item scale and quantity read clearly
- the box feels tactile, not a menu-only source

### 05 Picked Up Case

Filename:

```text
05-picked-up-case.png
```

Must show:

- first-person carried case/box view
- readable fictional cover/color block
- store context behind it

Pass criteria:

- carried item does not block too much of the view
- case feels like a physical object

### 06 Stocked Shelf Density

Filename:

```text
06-stocked-shelf-density.png
```

Must show:

- shelf with about ten physical game cases
- price tags/stickers or shelf labels
- empty nearby capacity if applicable

Pass criteria:

- one-to-one stock is visually believable
- ten-ish games reads as ten-ish games
- dense but not noisy

### 07 Counter Register

Filename:

```text
07-counter-register.png
```

Must show:

- register/counter
- customer-facing side
- staff/player side cue
- retail-specific counter clutter

Pass criteria:

- counter reads as the store pressure point
- sale flow location is obvious without tutorial text

### 08 Customer Entering From Mall

Filename:

```text
08-customer-entering-from-mall.png
```

Must show:

- customer crossing from mall into store
- storefront/entrance context
- enough body silhouette to read as a person, even if placeholder

Pass criteria:

- physical customer presence is credible
- customer path starts outside the store

### 09 Daily Report View

Filename:

```text
09-daily-report-view.png
```

Must show:

- report UI or backroom computer report state
- store context or believable computer setting
- readable hierarchy

Pass criteria:

- report feels like a business tool
- not a debug dump

## Visual Review Rubric

Score each target:

- `pass`: ready to build on
- `revise`: clear direction, needs iteration
- `fail`: does not match the game
- `defer`: intentionally postponed with reason

Required sign-off:

- all nine targets are `pass`, or
- any `defer` has a written reason and does not weaken the visual scaffold

## Implementation Rules

- Use simple geometry if needed, but it must have correct scale, lighting, material direction, and composition.
- Favor reusable fixture scaffolding over one-off decorative set dressing.
- Fictional product art can start as graphic blocks, but must already establish the visual grammar.
- Do not add broad gameplay systems to compensate for weak visuals.
- Do not treat the current engine proof scene as production art.

## Validation Rules

Automated validation should capture and sanity-check screenshots. Human review decides visual quality.

The benchmark is not approved just because the local gate passes.

