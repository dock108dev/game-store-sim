# V1a — retail presentation reference choice

Updated 2026-09-07. **Owner selected B — illustrated 2.5D shop overview. Exact reply: “B”.** Only the retail loop carries forward; original artwork, interface and exact camera treatment remain to be developed within that direction. This comparison proposes adaptations for our shop; it does not prescribe copying any game's assets, setting, UI or complete mechanics. Effort is a comparative production judgment, not a measured estimate.

## A — illustrated 2D counter / shop panels: Potion Craft

niceplay games / tinyBuild. [Official retail description, screenshots and trailers](https://store.steampowered.com/app/1210320/Potion_Craft_Alchemist_Simulator/).

![Potion Craft retail counter, official Steam screenshot](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1210320/ss_594f4f435a27c625e0f5c8d3603883c9e293b967.1920x1080.jpg?t=1786023837)

Observed: flat ink-like figures, restrained color, large product silhouettes, visible customer request, product inventory and transaction choices. The counter composition makes faces and the offered item prominent. This is an actual selling reference; it does not demonstrate a freely browsable retail floor or full walking animation.

**Our adaptation:** illustrated shelf and counter panels, with a short side-on customer lane if visible browsing is desired. Retain original game-store products and setting; parchment/medieval styling is optional.

- **Stocking:** receiving tray → visible front-facing shelf slots; price/condition on selection. Large product drawings give strong readability.
- **Browsing customers:** customers move along one shallow lane, pause at displays and look/reach. Alternatively panel-based browsing can abstract location, but that sacrifices the visible floor relationship. These are proposed additions, not Potion Craft features established by this still.
- **Checkout:** counter close-up with an offered item, price and clear handoff. Easy to read individual sales; weaker simultaneous overview of queue and stock.
- **Readable motion:** side walk/stop/turn plus a reach; enlarged head/hand poses support personality. Limited facings save work, but moving cutouts can look like sliding paper portraits.

**Smallest running sample, after selection:** plain horizontal strip, one customer about 140 logical pixels tall, one shelf and counter silhouette. A 10–15-second repeated walk → planted stop → look/reach → turn → counter approach. A single dummy product tests hand alignment; no transaction logic. Hardest requirement: make an expressive illustrated figure move and stop convincingly instead of merely translating a still.

**Krita and retained deliverables:** generated originals and prompts if generation is later chosen; layered `.kra` character/face/hand and shelf masters; hidden-joint repairs; aligned RGBA PNG parts, product icons and/or authored PNG frames. Retain Godot animation resources, pivots, timings and import settings. Krita makes the drawings editable; Godot supplies movement and playback. Use authored frames if a focused cutout repair fails.

**Effort / uncertainty:** low-to-medium for restrained panel animation; medium or higher for expressive full-body walking. Strongest faces/products, weakest floor visibility. A beautiful counter image does not settle the cost of gait or browse animation.

## B — illustrated 2.5D shop overview: Kardboard Kings (owner selected)

Henry's House / Akupara Games. [Publisher page and trailer](https://www.akuparagames.com/game/kardboard-kings/) · [Publisher gameplay gallery](https://akuparagames.itch.io/kardboard-kings).

![Kardboard Kings retail floor, publisher gameplay screenshot](https://img.itch.zone/aW1hZ2UvMTM1OTAyNy84MDM3OTEwLnBuZw==/original/%2BTXv6Y.png)

Observed: angled illustrated room, upright simplified customers, card displays, browsing cues and a foreground counter. Stock, customer positions and sales activity share one composition. Pixel-edged figures and textured furniture are reference qualities, not mandatory art rules.

Here **2.5D describes the proposed visual presentation**: illustrated depth under a fixed oblique camera. We could implement it with layered 2D sprites and feet-based sorting; this is not a claim about the reference game's internal renderer. Camera rotation would multiply asset views and is excluded from the proposed tiny test, not permanently ruled out.

- **Stocking:** select/drag products into highlighted shelf slots; visible gaps show depletion. A detail card supplies title/price/condition when package text becomes too small.
- **Browsing customers:** visible aisle routes, fixture-facing pauses and restrained interest cues. Shelf ends and customer silhouettes must remain distinct.
- **Checkout:** customer leaves the display, joins a visible counter position, hands off a product and exits. Stock removal and a brief total make the sale readable.
- **Readable motion:** matched toward/away/side appearances, planted stops and small reach gestures. Feet determine depth order. Shelves may hide legs while heads and selection cues remain visible.

**Smallest running sample, after selection:** plain floor, one original human around 110 logical pixels tall, one solid shelf silhouette, fixed elevated view. Repeat rightward walk → stop → turn away → behind shelf → return facing toward camera → pass in front → leftward return → stop. Add one brief shelf-facing reach. About 15 seconds, pause/reset only, no retail state. Hardest requirement: consistent identity across turns, clean limbs and correct overlap without foot sliding or sorting pops.

**Krita and retained deliverables:** original identity master and generated direction candidates, prompts/provenance; layered `.kra` direction sheets, limb-only masks and reconstructed hidden surfaces; separate environment/foreground layers; aligned transparent PNG parts or authored frames; product icons; Godot rigs, foot/joint anchors, sorting rules, animation resources and import settings. Keep originals, editable working sources and exports distinct.

**Effort / uncertainty:** medium. Attractive illustrated character and shop composition with useful floor visibility. Main risks are matching human directions, animating browse/reach, maintaining perspective across fixtures and avoiding unreadably small stock. Space-opera supports a bounded test of the method, not a promise of a coherent cast or economical production.

## C — stylized 3D overview: Winkeltje

Sassybot. [Official press kit and trailer](https://winkeltjegame.com/press/) · [Official Steam gallery](https://store.steampowered.com/app/949290/).

![Winkeltje stocked 3D shop, official Steam screenshot](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/949290/ss_bfaebaa29166d44452faf9a7d64f848fef846379.1920x1080.jpg?t=1760619355)

Observed: dimensional displays, recognizable goods, soft lit materials, elevated camera and visible aisles. Dense decoration also demonstrates how shelves and stock can compete for attention. A 3D direction can use an overview; first person is not required.

- **Stocking:** product meshes occupy shelf sockets; optional carrying/placing gestures make handling tactile.
- **Browsing customers:** rigged figures navigate aisles and rotate toward fixtures. Tall shelving and walls require an occlusion strategy.
- **Checkout:** a visible queue and product handoff at the counter; authored prop attachment and hand alignment are needed.
- **Readable motion:** one rig can rotate freely, with walk/idle/turn/reach clips. Foot sliding, skin deformation and shelf intersections still need visual tuning.

**Smallest running sample, after selection:** one rigged original or suitable licensed customer, floor, shelf block and dummy product under representative lighting and a fixed elevated camera. Walk → stop → 90/180-degree turn → reach/place → return, around 15 seconds. Hardest requirement: grounded feet, stable silhouette and hand/prop contact without mesh intersections at roughly 110 logical pixels tall. No shop simulation.

**Krita and retained deliverables:** layered `.kra` concept, palette, label/UI and texture masters; texture PNGs. Also retain editable model/rig/animation source (for example `.blend`), UVs, materials, animation clips, GLB exports and Godot import/animation settings. Krita does not supply mesh topology, skin weights or a 3D rig.

**Effort / uncertainty:** highest initial setup for a cohesive original store/cast; suitable compatible assets could change that. Most flexible viewpoints and dimensional handling. Exact model/rig sourcing and ability to produce matching assets remain unproven; old Blender assets have no automatic preference.

## Recommendation and decision

Recommend **B, illustrated shop overview**, because it combines character appeal with the clearest stock → browsing → counter relationship at moderate expected production effort. A offers stronger close-up illustration but compresses the floor loop. C supports dimensional handling and flexible viewpoints at additional setup cost. These are judgments for this project, not claims about the studios' production budgets.

**Owner selection: B — illustrated 2.5D shop overview, using Kardboard Kings as the primary visual reference. Exact owner reply: “B”.** Selection is now recorded. Original art, palette and exact camera/interface details remain to be developed. No sample was built by this selection task; sample quality and complete-game acceptance remain separate.

## Read-only production evidence: space-opera-rpg

Inspected the actual `source-assets/S02/masters/human-side.kra` archive: Krita 5.3.3 metadata, six named editable part layers and a hidden original reference on a 1254-square RGBA canvas. Inspected the repaired runtime still `evidence/S02/captures/repair-toward.png`, cleanup script, export/rig inventory, recipe, asset register and owner feedback. Existing motion recording: [repaired human clip](../../../space-opera-rpg/evidence/S02/captures/t01-repair.mp4). Clip playback was not reassessed in this pass; walking/stopping/turning and repair feedback are documented evidence, not a fresh motion verdict.

Sources: [working recipe](../../../space-opera-rpg/source-assets/S02/recipe.md), [asset register](../../../space-opera-rpg/docs/asset-register.md), [exact owner feedback](../../../space-opera-rpg/docs/playtests/S02-owner-feedback.md), [workflow lessons](../../../space-opera-rpg/docs/illustrated-workflow-prompt.md).

What actually worked: generated direction masters → scripted cleanup inside Krita → editable limb layers → true RGBA exports → Godot rigid-part animation at about 100 logical pixels. Initial side masks included neighboring limbs and the torso retained arm pixels, producing duplicate limbs during motion. Repair isolated each limb and painted the jacket continuation behind the arm; owner permitted continuation and left the collar non-urgent. Cabinet A/B demonstrate a repeated prop recipe, not a second coherent character or a whole accepted game.

Limits: bright-background threshold cleanup was tailored to a dark costume; do not assume it works for pale clothes or different linework. Mirrored side lighting and absent knee articulation remain limitations. The pet's hovering placeholder is tolerated, not a proven gait. Recorded instrumented stages exclude substantial authoring and owner time, so no total labor estimate follows. Earlier notes still say Krita was proposed; retained KRA files and later evidence establish its actual use. No space-opera files were changed or game launched.

For any future illustrated sample, inspect alpha over light/dark backgrounds, check masks during motion and retain hidden-surface repairs. Verify actual logical/Retina scale. Re-export, reimport and relaunch once; preserve exact asset revisions and real motion capture. Separate technical behavior, visual quality, repeatability and owner feedback. One focused cutout repair, then a bounded authored-frame alternative; unresolved results require a concrete asset/animation dependency, not more scenery.

## Inspection limits and separate repairs

All three displayed official gameplay stills were visually inspected in the browser during this continuation. Source galleries/trailers are linked; no frame-by-frame trailer verification or timecodes are claimed. Proposed production methods are ours, not asserted studio workflows. No art generated, sample built, gameplay expanded, game launched, commit/push or publication performed.

Keep these four reproduced defects unresolved for a separate repair step, with evidence in [recovery review](../03-production/recovery-review-2026-09-07.md):

1. Sale succeeds after close/report phase.
2. Two customers select the same unreserved item.
3. A sold item remains referenced as carried.
4. Forward input moves opposite camera forward.

Repair relevant transaction defects before reusing that code. Repair or retire the old movement adapter after presentation selection, preserving the finding. No gameplay code is required for the visual sample.
