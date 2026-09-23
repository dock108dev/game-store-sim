# Current art direction

**Illustrated 2.5D early-2000s mall game shop.** Kardboard Kings is the primary overview/composition reference. **B-ROWAN-01 / retail-v4** is the current visual baseline following [positive owner feedback](../03-production/retail-v4-owner-feedback.md).

Use ordinary period shop clothing, stocked commercial fixtures, original fictional game packaging/category strips, used-game stickers, shop promotions and bright retail lighting. Preserve the retail-v4 balance of colorful products and practical shop materials. Essential title/price/condition information belongs in readable UI rather than tiny package lettering.

The current implementation uses layered 2D sprites, a fixed oblique overview and feet-based sorting. Rowan is about 110 logical pixels tall in the recorded 1280×720 logical / 2560×1440 Retina framebuffer. New fixtures and interactions must be readable at that gameplay scale.

Keep the character identity, consistent directional views and clean silhouettes. Use Godot AnimationPlayer and editable Krita masters with limb-only layers, reconstructed hidden surfaces, transparent PNG exports and recorded pivots/settings. The space-opera project is a read-only workflow reference for Krita and animation techniques.

For R1 extend only enough of this look to support one retail encounter: shelf, product, counter, customer and legible interaction/report UI. Preserve the current sample and its assets as comparison evidence. Record new source/export identity and check animation/alpha/occlusion after art changes.

Motion continuation has been permitted; named limits remain in the [slice plan](../03-production/milestones-and-backlog.md). Technical passes do not close them. The [retained sample report](../../samples/b-retail-v4/README.md) documents construction and verification; current owner status is recorded separately.
