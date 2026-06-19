# Product Art And Packaging

Status: Active visual bible
Spreadsheet families: Product, Marketing packaging rows
Primary IDs: OBJ-097 through OBJ-135, OBJ-136 through OBJ-151, OBJ-156, OBJ-157, OBJ-190, OBJ-191, OBJ-202, OBJ-222, OBJ-223, OBJ-265

## Target Read

Products are the most important first-person visual upgrade. A game store cannot sell the fantasy if the games look like colored blocks. The next product pass must make software, console boxes, and accessory packaging readable from normal player distance.

The product art does not need licensed-realistic detail. It does need recognizable cover composition, platform identity, price sticker treatment, duplicate stack behavior, and scale differences between games, handheld goods, console boxes, and accessories.

## Locked Decisions

- Main software packaging is DVD-case language.
- Handheld goods may be carts, small plastic cases, or small cardboard boxes.
- Cover art should make the product obvious in first person.
- Text can exist, but cover art should do most of the work.
- Price stickers are on the case.
- Used games get sticker/wear treatment, but no need for heavy shrinkwrap/new-seal detail.
- Duplicate copies should stack visually.
- Console boxes should be realistic retail boxes with product render/pattern/handle/flaps where useful.
- Accessory packaging can be small boxes; blister packs are optional, not mandatory.
- Loose used controllers/consoles are not day-one high-detail priority.

## Product Packaging Families

| ID Range | Family | Bible Direction |
| --- | --- | --- |
| OBJ-097/102/107/122/127/132 | Standard game cases | DVD-case base mesh, platform spine color, cover art plane, case price sticker. |
| OBJ-098/103/108/123/128/133 | Used game variants | Same case shape with used sticker, light wear, condition cues, price sticker. |
| OBJ-099/104/109/124/129/134 | Console boxes | Large retail boxes, distinctive platform form language, stackable. |
| OBJ-100/105/110/115/120/125/130/135 | Controller/accessory packaging | Small retail boxes or card packs, platform-color identity, shelf/peg compatibility. |
| OBJ-112/117 | Handheld game packaging | Smaller cases/boxes/carts, visibly different scale from DVD cases. |
| OBJ-156/157/219 | Small accessories | Memory card/link cable/AV cable boxes for later density; not day-one focus. |
| OBJ-222/223 | Used hardware loose items | Later resale detail; worn controller/console, not day-one priority. |
| OBJ-265 | Disc-only sleeve | Later cheap-used condition state. |

## DVD Case Requirements

An MVP DVD game case needs:

- case body with bevel/rounded front edge
- spine that reads when shelved
- cover-art face using bitmap/atlas texture
- back side can be simplified but should not be blank if visible
- case price sticker
- optional used sticker/condition sticker
- consistent scale for stacking and shelf placement

Do not build cover art from separate tiny 3D rectangles. Use a texture/material/atlas.

## Cover Art Requirements

Cover art should use simple but readable compositions:

- sports game: field/ball/player silhouette, green/white/black accents
- adventure RPG/creature game: character/creature silhouette, fantasy/adventure color palette
- shooter/action: bold figure/helmet/ship/weapon silhouette if later used
- racing: vehicle/road/neon or speed streaks if later used
- rhythm/music: instrument/stage color blocks if later used

The art can be generated bitmap-style, hand-authored texture, or atlas-based. It should be recognizably "box art" at player distance.

## Starter Products

Day-one starter products:

- one starter platform only
- two starter games
- one console
- one accessory/controller
- enough physical stock for only a handful of day-one sales

Starter game direction:

1. `Footy 2002`
   - funny/legal-safe sports title
   - DVD case
   - obvious sports cover art
   - stackable duplicates if multiple copies exist

2. Adventure RPG sequel-ready title
   - funny/legal-safe, not a real franchise echo that risks copying
   - can support sequels later
   - recognizable fantasy/adventure/creature-style cover art
   - temporary name is allowed and can be changed later

Avoid using `Space Marines 2` or `Blue Alive and Thriving` as starter names; owner rejected them.

## Console Box Requirements

Console boxes should read as real retail boxes:

- larger than game cases by correct scale
- visible front art/product render or silhouette
- side panel/spine identity
- top flap/handle or box seam
- stackable duplicate state
- shelf/floor/backroom compatible

The shape can vary by platform:

- flat horizontal console box
- tall tower-like console box
- rounded/sphere/cylinder-inspired console packaging if legal-safe and stylized

Use real early/mid-2000s console retail packaging as inspiration only. Do not copy real console marks, silhouettes, logos, controller shapes, or box art.

## Price And Condition

Price treatment:

- price sticker on the case/box
- shelf strips optional later
- new and used can share price-sticker framework
- used sticker can show used/complete/disc-only/cleaned condition later

Do not overbuild shrinkwrap or factory seals for MVP.

## Validation Shots

Required:

- close starter DVD case face
- shelved starter DVD cases from player distance
- duplicate stack visual
- console box on floor/shelf/backroom placement
- accessory package on fixture

Pass criteria: a reviewer can identify "new sports game," "adventure RPG," "console box," and "accessory package" without debug text.
