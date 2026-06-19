#!/usr/bin/env python3
"""Render the owner-facing hero art proof board from repo-local assets.

The local Codex sandbox cannot always create a Godot GUI viewport, so this
script creates a deterministic visual review artifact from the same bitmap
assets used by the Godot hero scene. It is not a gameplay capture; it is an
art-direction proof board for owner validation.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "game" / "assets" / "art_proof" / "generated"
ARTIFACT_OUT = ROOT / "artifacts" / "validation" / "latest" / "screenshots" / "hero_art_slice_review_board.png"
DOC_OUT = ROOT / "docs" / "production" / "images" / "hero_art_slice_review_board.png"


def load(name: str) -> Image.Image:
    return Image.open(ASSETS / name).convert("RGBA")


def paste_fit(canvas: Image.Image, img: Image.Image, box: tuple[int, int, int, int]) -> None:
    width = max(1, box[2] - box[0])
    height = max(1, box[3] - box[1])
    fitted = img.resize((width, height), Image.Resampling.LANCZOS)
    canvas.alpha_composite(fitted, (box[0], box[1]))


def shadow(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int = 20) -> None:
    x0, y0, x1, y1 = box
    draw.rounded_rectangle((x0 + 10, y0 + 12, x1 + 10, y1 + 12), radius=radius, fill=(0, 0, 0, 52))


def polygon_shadow(draw: ImageDraw.ImageDraw, points: list[tuple[int, int]], offset: tuple[int, int] = (12, 16)) -> None:
    shifted = [(x + offset[0], y + offset[1]) for x, y in points]
    draw.polygon(shifted, fill=(0, 0, 0, 40))


def draw_floor(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 0, 1600, 900), fill=(78, 80, 76, 255))
    draw.polygon([(0, 624), (1600, 532), (1600, 900), (0, 900)], fill=(113, 112, 101, 255))
    for x in range(-260, 1820, 170):
        draw.line((x, 900, 790 + (x - 800) // 7, 530), fill=(218, 198, 138, 190), width=3)
    for y in range(582, 900, 78):
        draw.line((0, y + 30, 1600, y - 25), fill=(212, 192, 132, 155), width=3)
    draw.polygon([(110, 662), (470, 644), (520, 900), (0, 900)], fill=(69, 82, 88, 255))
    draw.line((110, 662, 470, 644), fill=(211, 181, 104, 255), width=7)


def draw_store_shell(canvas: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    # Mall/store shell with a clean, small-chain storefront read.
    draw.polygon([(390, 144), (1325, 118), (1468, 238), (498, 250)], fill=(166, 176, 173, 255))
    draw.polygon([(458, 246), (1448, 236), (1452, 646), (444, 650)], fill=(73, 86, 89, 255))
    draw.polygon([(500, 267), (1410, 254), (1405, 624), (500, 628)], fill=(163, 177, 174, 255))
    draw.polygon([(530, 356), (1370, 326), (1345, 620), (540, 620)], fill=(186, 198, 194, 255))
    draw.polygon([(540, 622), (1345, 620), (1268, 734), (493, 702)], fill=(86, 87, 76, 255))
    draw.rectangle((435, 156, 1464, 234), fill=(12, 39, 53, 255))
    draw.rectangle((448, 221, 1450, 238), fill=(13, 20, 23, 255))
    draw.rectangle((454, 146, 1442, 153), fill=(72, 178, 191, 255))
    paste_fit(canvas, load("games4u_sign.png"), (640, 156, 970, 232))

    # Glass mullions and open door.
    for x in [520, 665, 810, 980, 1130, 1285, 1405]:
        draw.rectangle((x, 244, x + 11, 646), fill=(20, 34, 40, 255))
    for y in [358, 494]:
        draw.rectangle((510, y, 1424, y + 9), fill=(22, 39, 45, 255))
    for x0, x1 in [(536, 657), (682, 802), (995, 1122), (1145, 1276), (1300, 1396)]:
        draw.rectangle((x0, 270, x1, 628), fill=(112, 166, 181, 70), outline=(151, 211, 220, 115), width=2)
    draw.polygon([(830, 286), (946, 312), (944, 626), (826, 642)], fill=(120, 181, 196, 94), outline=(166, 225, 232, 170))
    draw.line((904, 398, 904, 557), fill=(226, 194, 115, 255), width=8)
    paste_fit(canvas, load("open_setup_sign.png"), (1010, 382, 1085, 414))


def draw_interior(canvas: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    # Warm lit interior, intentionally empty-ish for pre-day-one setup.
    draw.polygon([(562, 620), (1325, 615), (1218, 716), (520, 690)], fill=(83, 87, 76, 255))
    draw.polygon([(610, 352), (855, 342), (855, 618), (600, 620)], fill=(132, 151, 150, 255))
    for y in range(390, 584, 28):
        draw.line((622, y, 842, y - 6), fill=(64, 84, 86, 255), width=3)
    draw.rectangle((1115, 330, 1220, 618), fill=(45, 66, 69, 255))
    draw.rectangle((1138, 378, 1196, 432), fill=(128, 177, 190, 110))
    draw.rectangle((1165, 474, 1200, 488), fill=(210, 184, 111, 255))
    for x in [730, 925, 1140]:
        draw.polygon([(x, 292), (x + 130, 286), (x + 120, 305), (x - 8, 312)], fill=(250, 219, 143, 190))

    # Poster is a wall cue, not random clutter.
    paste_fit(canvas, load("grand_opening_poster.png"), (642, 394, 740, 462))


def draw_counter(canvas: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    polygon_shadow(draw, [(895, 540), (1300, 530), (1350, 676), (920, 706)])
    draw.polygon([(895, 540), (1300, 530), (1350, 676), (920, 706)], fill=(23, 20, 17, 255))
    draw.polygon([(875, 500), (1275, 490), (1300, 532), (895, 544)], fill=(212, 203, 175, 255))
    draw.polygon([(940, 566), (1235, 556), (1242, 637), (955, 656)], fill=(104, 151, 158, 95), outline=(178, 217, 221, 150))
    draw.rectangle((1018, 468, 1105, 506), fill=(88, 94, 91, 255))
    draw.rectangle((1035, 436, 1090, 470), fill=(22, 31, 35, 255))
    draw.rectangle((1140, 472, 1195, 492), fill=(39, 51, 54, 255))
    draw.rectangle((1220, 478, 1274, 492), fill=(204, 171, 105, 255))
    for i in range(4):
        paste_fit(canvas, load(["footy_2002_cover.png", "critter_quest_cover.png", "orbit_runner_cover.png", "cobalt_courier_cover.png"][i]), (970 + i * 55, 580, 1012 + i * 55, 642))


def draw_fixture(canvas: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    shadow(draw, (596, 430, 850, 666), 10)
    draw.rectangle((590, 418, 854, 664), fill=(83, 103, 102, 255))
    draw.rectangle((574, 642, 870, 692), fill=(43, 36, 28, 255))
    paste_fit(canvas, load("new_this_week_label.png"), (610, 388, 835, 430))
    for y in [470, 520, 570, 620]:
        draw.rectangle((604, y, 840, y + 7), fill=(21, 35, 39, 255))
        draw.line((620, y + 20, 815, y + 16), fill=(38, 54, 55, 170), width=4)
    covers = ["footy_2002_cover.png"] * 5 + ["critter_quest_cover.png"] * 4
    for i, name in enumerate(covers):
        x = 612 + i * 24
        paste_fit(canvas, load(name), (x, 483, x + 38, 541))
    paste_fit(canvas, load("vortex_console_box.png"), (618, 600, 718, 665))
    paste_fit(canvas, load("controller_pack.png"), (755, 588, 818, 666))


def draw_window_display(canvas: Image.Image, draw: ImageDraw.ImageDraw) -> None:
    draw.ellipse((445, 585, 610, 635), fill=(0, 0, 0, 50))
    draw.rounded_rectangle((480, 480, 575, 612), radius=24, fill=(196, 189, 160, 255), outline=(44, 60, 60, 255), width=4)
    paste_fit(canvas, load("vortex_console_box.png"), (466, 430, 595, 510))
    paste_fit(canvas, load("footy_2002_cover.png"), (430, 505, 483, 586))
    paste_fit(canvas, load("critter_quest_cover.png"), (592, 506, 645, 586))


def draw_delivery(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((1230, 654, 1370, 676), fill=(35, 42, 42, 255))
    draw.rectangle((1250, 600, 1308, 654), fill=(119, 78, 39, 255))
    draw.rectangle((1315, 610, 1360, 654), fill=(139, 91, 45, 255))
    draw.line((1260, 626, 1300, 626), fill=(216, 184, 111, 255), width=3)
    draw.line((1322, 633, 1352, 633), fill=(216, 184, 111, 255), width=3)


def main() -> None:
    ARTIFACT_OUT.parent.mkdir(parents=True, exist_ok=True)
    DOC_OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas = Image.new("RGBA", (1600, 900), (0, 0, 0, 255))
    draw = ImageDraw.Draw(canvas)
    draw_floor(draw)
    draw_store_shell(canvas, draw)
    draw_interior(canvas, draw)
    draw_fixture(canvas, draw)
    draw_counter(canvas, draw)
    draw_window_display(canvas, draw)
    draw_delivery(draw)

    # Thin vignette makes the proof read as one composed screenshot.
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    o = ImageDraw.Draw(overlay)
    o.rectangle((0, 0, 1600, 900), outline=(0, 0, 0, 55), width=18)
    canvas = Image.alpha_composite(canvas, overlay).filter(ImageFilter.UnsharpMask(radius=1.0, percent=110, threshold=3))
    output = canvas.convert("RGB")
    output.save(ARTIFACT_OUT)
    output.save(DOC_OUT)
    print(DOC_OUT)
    print(ARTIFACT_OUT)


if __name__ == "__main__":
    main()
