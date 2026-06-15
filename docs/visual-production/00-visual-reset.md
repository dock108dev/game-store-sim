# Visual Reset

## Purpose

Reset expectations for the game's visuals before more implementation work.

The project has a broad, validated first-person retail loop. That is a strong mechanical foundation. The current store visuals, however, are still a prototype/blockout. They rely heavily on CSG primitives, floating labels, flat material planes, and validation screenshots that prove readability more than art direction.

June 12 owner review rejected the first broad phase 0-4 visual pass. The immediate reset target is now the opening approach: the player starts on a quiet second-floor mall concourse, faces the new store, walks through a branded glass storefront, and enters before customers or employees are present. The mall-entry premise is better, but the next pass must replace visible blockout boxes and label-driven props before broader store expansion.

## New Visual Truth

Current scene status:

- Mechanically playable.
- Useful as layout and interaction proof.
- Useful as collision and route reference.
- Useful for screenshot subject coverage.
- Not a final-art alpha.
- Not close enough to compare favorably with polished indie shop sims.
- Not the visual baseline for future production.
- Current active review surface is only the second-floor mall storefront opening slice.
- Next implementation cycle is the opening visual asset pass, not another broad layout pass.

## Deprecated Expectations

Stop treating these as sufficient visual progress:

- More CSG boxes as final props.
- More label panels as visual identity.
- More one-off placeholder signs.
- "Tests pass" as proof that the store looks good.
- Screenshot nonblank/sanity checks as art approval.
- Full-store broadening before one final-quality slice exists.
- Treating mall-entry composition approval as final art approval.
- Production-blockout language as a release-facing visual target.

## What Stays Useful

Keep these from the current implementation:

- Store footprint and route learnings.
- Register, shelf, receiving, backroom, and office interaction responsibilities.
- Customer queue and special-customer separation rules.
- Fixture-placement collision and validation logic.
- Product catalog and fictional naming constraints.
- Validation gate, screenshot capture, and status-contract discipline.

## What Changes

Visual production now starts from authored visual slices:

1. Pick a specific mid-00s independent game shop look in a small mall/retail strip context.
2. Build a small final-quality scene slice.
3. Validate screenshots against art direction, not only mechanical readability.
4. Replace blockout visuals zone by zone.
5. Keep gameplay/collision stable while visual meshes improve.

## Source Of Truth

Use this folder for active visual direction. Older visual plans remain useful as implementation history, but they do not define the new art bar.
