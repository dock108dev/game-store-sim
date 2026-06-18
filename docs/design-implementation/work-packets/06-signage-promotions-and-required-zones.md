# Work Packet: Signage Promotions And Required Zones

Status: Not started
Owner decision required: No
Target branch: `codex/hard-visual-benchmark-implementation`
Primary doc: `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`
Dependencies: `docs/design-implementation/08-required-zones-slice.md`, `docs/design-implementation/07-product-and-platform-visual-language-spec.md`, `docs/design-implementation/12-validation-and-screenshot-checklist.md`, `docs/design-implementation/work-packets/02-store-shell-mall-entrance-stockroom.md`, `docs/design-implementation/work-packets/05-product-platform-and-price-language.md`
Expected commit scope: editable store identity, shelf labels, required signs, promotion posters, and non-debug zone readability

## Read First

1. `docs/CURRENT_STATE.md`
2. `docs/design-source-of-truth/README.md`
3. `docs/design-implementation/README.md`
4. `docs/design-implementation/work-packets/00-packet-index.md`
5. `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`
6. `docs/design-implementation/08-required-zones-slice.md`
7. `docs/design-implementation/07-product-and-platform-visual-language-spec.md`
8. `docs/design-implementation/12-validation-and-screenshot-checklist.md`

## Context

- Current problem: signage and labels are overused as debug identity while the environment/product shapes are underdeveloped.
- Target player-facing result: `Games4U` reads like a modest 2005 mall store, signs support orientation, shelf labels support player organization, and promotions add flavor without doing all the visual work.
- Existing systems that must keep working: store name/customization, fixture labels, stocking, pricing, demo placement, receiving, screenshot capture.
- Visual/design docs that define success: signage spec, required zones, product language, validation checklist.
- Known prior failures to avoid: random labels everywhere, mirrored/unreadable signs, signage replacing product/fixture identity, over-specific legal-risk branding, fixed zones that remove player organization.

## In Scope

- Editable storefront name sign with `Games4U` default.
- Open/closed sign support.
- Employees-only sign on/near stockroom.
- Demo sign.
- Shelf labels, including default mixed/potpourri-style labels where needed.
- Poster templates for new releases, trade-in deals, upcoming releases, and now-on-sale.
- Neighboring mall sign flavor with light readable detail.
- Required zones readable from fixtures, products, placement, and light signage.

## Out Of Scope

- Full marketing campaign art.
- Fixture purchasing UI redesign.
- Final store-brand/logo lock.
- Large tutorial text.
- Broad decoration-only poster walls.
- Hidden narrative signs.
- Customer-facing promotional systems beyond visual support.

## Do Not Do

- Do not use large debug labels as final object identity.
- Do not hard-lock store name or palette.
- Do not make signage legally close to real stores or game brands.
- Do not let signs carry the whole zone read when fixtures/products should.
- Do not make all labels permanent if player organization should be editable.
- Do not add signage clutter to hide weak product/fixture visuals.
- Do not break screenshot readability with mirrored/backward signs.

## Implementation Plan

1. Inspect current signage, label, and text rendering patterns.
2. Identify editable store-name and label data flow.
3. Implement or replace sign/poster materials and scenes.
4. Integrate storefront, stockroom, demo, shelf, and promotion signs.
5. Remove or replace visible debug labels where primary objects now read visually.
6. Verify required zones are readable without overlabeling.
7. Capture signage and zone screenshots.
8. Run focused tests and full validation.
9. Commit and push.

## Likely Files

Scenes:
- storefront sign scenes
- shelf label scenes
- poster/sign scenes
- active store scene

Scripts:
- sign text/update scripts
- store name customization scripts
- fixture label scripts
- screenshot target scripts if changed

Assets:
- sign materials
- poster textures
- label textures/materials
- font resources if already used by repo

Data:
- store name/default text data
- shelf label metadata
- poster templates

Tests:
- store-name persistence tests if touched
- label tests if fixture labels change
- screenshot sanity tests if target names change

Docs:
- `docs/design-implementation/10-signage-branding-and-store-identity-spec.md`
- `docs/design-implementation/08-required-zones-slice.md`
- `docs/production/13-alpha-bug-list.md` if blockers change

## Validation Required

Implementation packet:

- Capture final game-window screenshots first.
- Review screenshots for sign readability, legal-safe naming, and zone clarity.
- Run focused label/store-name tests if touched.
- Run `scripts/validate_godot.sh`.
- Confirm artifacts under `artifacts/validation/latest/`.

## Screenshot Evidence

Required final screenshots:

- storefront sign from mall approach
- open/closed sign
- employees-only stockroom sign
- demo sign
- shelf label on a fixture
- promotion poster group
- required-zone read from normal walking distance

## Tests To Add Or Update

- Store-name persistence tests if editable name behavior changes.
- Fixture label tests if labels use new data.
- Screenshot target tests if sign screenshots are added or renamed.

## Tests To Run

- focused store-name/label tests if touched
- focused screenshot target tests if touched
- `scripts/validate_godot.sh`

## Documentation Updates

- Update signage spec if final sign text, default label, or editable behavior changes.
- Update visual bug list if debug-label blockers are resolved.
- Log any removed/replaced labels.

## Decision Log

| Decision | Reason | Owner/Lead Needed? | Follow-up |
| --- | --- | --- | --- |
| `Games4U` remains default but editable. | Owner selected the name but wanted signs/customization to remain flexible. | No | Keep store-name persistence tested if implemented. |

## Stop Conditions

- Signage cannot be made readable without debug-scale labels.
- Legal/name/trade-dress risk appears.
- Required zones still require floating debug text to understand.
- Editable store-name behavior breaks.
- Validation exposes a blocker.

## Continue Conditions

- Signs support, not replace, product/fixture/architecture identity.
- Required zones are understandable.
- Store name remains editable.
- Final integration polish can tune lighting/density without redesigning signs.

## Final Handoff Requirements

- Commit hash
- Branch
- Screenshot/contact-sheet paths
- Validation command/result
- Final sign/label defaults
- Known residual issues
- Owner/lead decisions needed
