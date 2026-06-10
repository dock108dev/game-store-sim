# Quality Bar Checklist

Use this checklist to approve the opening store and backroom before full catalog/decor/platform implementation.

## Storefront And Spawn

- Store name is readable from the first view.
- Spawn view shows shop identity, register, shelf zone, and backroom hint.
- Ceiling/floor/walls no longer dominate as empty planes.
- Glass, door, threshold, and signage read as a shop entrance.
- Wall trim, ceiling grid, threshold, and rubber mats separate finished surfaces from raw blockout planes.

## Sales Floor

- Used-game shelving has visible product density.
- Preorder, staff-pick, new-release, accessory, bargain, and impulse zones are readable as separate retail beats.
- Category signs are short and readable.
- Entry, register, shelf, receiving, and backroom routes remain clear.
- Products look like inventory, not blocks.
- Fixture density does not hide interaction prompts.

## Register

- Counter reads as a checkout command center.
- Sale, return, trade-in, preorder, and service surfaces are physically visible.
- A customer approach marker, scan pad, payment terminal, receipt printer, cash drawer, and workflow cue rail are visible without adding extra interaction targets.
- Register remains one clear interaction target.
- Transaction UI decision points are readable before confirmation.

## Receiving And Stockroom

- Receiving station shows box, invoice, sorted tray, products, and pickup path.
- Delivery/check/sort workflow cards and pull/restock arrows explain stock movement physically.
- Supplier delivery reads as physical stock arrival.
- Backstock shelves show category lanes and capacity.
- Pull/store flow reads as backroom work, not menu teleporting.

## Backroom Office

- Computer reads as manager workstation.
- Dashboard, ordering, releases, services, storage, settings, and records are scan-friendly.
- Service bench and records/safe/security surfaces are readable but secondary.
- Hidden-thread cues remain optional.

## Catalog Foundation

- Product and platform names are fictional and coherent.
- Starter products support the store identity.
- Categories and condition/risk language fit receipts, tags, and panels.

## Validation

- `scripts/validate_godot.sh` passes.
- `docs/qa/screenshot-review.md` passes.
- No open P0/P1 issue remains in `docs/production/13-alpha-bug-list.md`.
- Human review confirms the first five minutes feel like a deliberate game store.
