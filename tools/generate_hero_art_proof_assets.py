#!/usr/bin/env python3
"""Generate legal-safe bitmap art for the isolated hero art proof.

These images are intentionally fictional and repo-local. They replace live
Godot text panels in the hero proof so signage and product art are stable,
non-mirrored, and reviewable as authored visual assets.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "game" / "assets" / "art_proof" / "generated"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        "/System/Library/Fonts/Supplemental/Verdana Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Verdana.ttf",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).exists():
            return ImageFont.truetype(candidate, size=size)
    return ImageFont.load_default()


def draw_center(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, fill: tuple[int, int, int], size: int, bold: bool = False) -> None:
    face = font(size, bold)
    bbox = draw.multiline_textbbox((0, 0), text, font=face, spacing=max(2, size // 8), align="center")
    width = bbox[2] - bbox[0]
    height = bbox[3] - bbox[1]
    x = box[0] + ((box[2] - box[0]) - width) // 2
    y = box[1] + ((box[3] - box[1]) - height) // 2
    draw.multiline_text((x, y), text, fill=fill, font=face, spacing=max(2, size // 8), align="center")


def save(img: Image.Image, name: str) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    img.save(OUT / name)


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    width, height = size
    img = Image.new("RGB", size, top)
    px = img.load()
    for y in range(height):
        t = y / max(1, height - 1)
        row = tuple(int(top[i] * (1.0 - t) + bottom[i] * t) for i in range(3))
        for x in range(width):
            px[x, y] = row
    return img


def sign_games4u() -> None:
    img = gradient((1200, 280), (20, 48, 65), (9, 25, 36))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((16, 16, 1184, 264), radius=26, outline=(218, 188, 110), width=8)
    draw.rectangle((42, 218, 1158, 228), fill=(91, 162, 178))
    draw_center(draw, (40, 34, 1160, 206), "GAMES4U", (245, 232, 174), 118, True)
    draw_center(draw, (50, 188, 1150, 260), "BUY  SELL  TRADE  PLAY", (202, 219, 214), 34, False)
    save(img, "games4u_sign.png")


def sign_open() -> None:
    img = Image.new("RGB", (420, 180), (18, 38, 43))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((10, 10, 410, 170), radius=22, outline=(232, 200, 121), width=6)
    draw_center(draw, (20, 22, 400, 126), "OPEN", (245, 232, 174), 64, True)
    draw_center(draw, (20, 116, 400, 168), "SETUP DAY", (164, 210, 214), 25, False)
    save(img, "open_setup_sign.png")


def poster_grand_opening() -> None:
    img = gradient((620, 420), (236, 215, 152), (186, 139, 82))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((18, 18, 602, 402), radius=22, outline=(29, 54, 64), width=8)
    draw_center(draw, (40, 42, 580, 134), "GRAND OPENING", (27, 52, 64), 48, True)
    draw_center(draw, (50, 140, 570, 232), "TRADE BONUS\nTHIS WEEK", (107, 52, 37), 42, True)
    draw.rectangle((86, 262, 534, 314), fill=(26, 57, 69))
    draw_center(draw, (86, 258, 534, 318), "STARTER STOCK ARRIVING", (241, 229, 183), 25, False)
    draw_center(draw, (80, 326, 540, 394), "legal-safe fictional titles only", (62, 65, 57), 19, False)
    save(img, "grand_opening_poster.png")


def cover(name: str, title: str, subtitle: str, top: tuple[int, int, int], bottom: tuple[int, int, int], accent: tuple[int, int, int], icon: str) -> None:
    img = gradient((420, 620), top, bottom)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((16, 16, 404, 604), radius=18, outline=(238, 230, 204), width=5)
    draw.rectangle((16, 16, 404, 82), fill=(16, 38, 52))
    draw_center(draw, (22, 18, 398, 78), "VORTEX 2", (240, 230, 181), 26, True)
    draw_center(draw, (40, 112, 380, 210), title, (248, 239, 207), 42, True)
    draw_center(draw, (46, 220, 374, 270), subtitle, (230, 225, 200), 22, False)
    draw.ellipse((122, 292, 298, 468), fill=accent, outline=(246, 230, 174), width=6)
    draw_center(draw, (122, 292, 298, 468), icon, (23, 43, 55), 84, True)
    draw.rectangle((44, 526, 376, 572), fill=(238, 223, 158))
    draw_center(draw, (44, 524, 376, 574), "NEW  $49.99", (31, 52, 56), 27, True)
    save(img, name)


def console_box() -> None:
    img = gradient((760, 500), (28, 64, 82), (13, 29, 38))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((22, 22, 738, 478), radius=28, outline=(224, 200, 125), width=8)
    draw_center(draw, (48, 42, 712, 126), "VORTEX HOME CONSOLE", (242, 232, 184), 48, True)
    draw.rounded_rectangle((94, 164, 414, 360), radius=38, fill=(36, 46, 52), outline=(110, 170, 181), width=10)
    draw.rectangle((462, 170, 666, 240), fill=(232, 221, 178))
    draw.rectangle((462, 266, 666, 336), fill=(119, 163, 176))
    draw_center(draw, (84, 376, 686, 462), "ONE CONTROLLER INCLUDED", (229, 217, 174), 34, False)
    save(img, "vortex_console_box.png")


def controller_pack() -> None:
    img = gradient((420, 520), (231, 221, 190), (164, 137, 95))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle((18, 18, 402, 502), radius=18, outline=(36, 57, 63), width=7)
    draw_center(draw, (34, 34, 386, 96), "ARCADE PAD", (27, 53, 62), 36, True)
    draw.ellipse((78, 176, 342, 378), fill=(34, 52, 60), outline=(218, 191, 119), width=8)
    draw.ellipse((144, 242, 184, 282), fill=(120, 171, 178))
    draw.ellipse((236, 238, 278, 280), fill=(224, 101, 75))
    draw_center(draw, (40, 410, 380, 486), "VORTEX COMPATIBLE", (58, 66, 58), 25, False)
    save(img, "controller_pack.png")


def shelf_label() -> None:
    img = Image.new("RGB", (760, 140), (22, 48, 58))
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 760, 14), fill=(217, 184, 105))
    draw.rectangle((0, 126, 760, 140), fill=(217, 184, 105))
    draw_center(draw, (20, 18, 740, 122), "NEW THIS WEEK", (239, 230, 190), 48, True)
    save(img, "new_this_week_label.png")


def carpet() -> None:
    img = Image.new("RGB", (512, 512), (70, 74, 65))
    draw = ImageDraw.Draw(img)
    for y in range(0, 512, 8):
        shade = 64 + ((y // 8) % 4) * 4
        draw.line((0, y, 512, y), fill=(shade, shade + 4, shade - 2), width=1)
    for x in range(0, 512, 13):
        draw.line((x, 0, x, 512), fill=(76, 78, 69), width=1)
    save(img, "low_pile_carpet.png")


def mall_tile() -> None:
    img = Image.new("RGB", (512, 512), (128, 126, 112))
    draw = ImageDraw.Draw(img)
    for x in range(0, 512, 128):
        draw.line((x, 0, x, 512), fill=(218, 200, 144), width=4)
    for y in range(0, 512, 128):
        draw.line((0, y, 512, y), fill=(218, 200, 144), width=4)
    for y in range(512):
        if y % 17 == 0:
            draw.line((0, y, 512, y), fill=(118, 116, 104), width=1)
    save(img, "mall_tile_grid.png")


def main() -> None:
    sign_games4u()
    sign_open()
    poster_grand_opening()
    cover("footy_2002_cover.png", "FOOTY 2002", "Saturday League", (28, 94, 99), (22, 52, 68), (91, 176, 111), "02")
    cover("critter_quest_cover.png", "CRITTER\nQUEST II", "Pocket Beasts", (75, 44, 90), (27, 46, 74), (224, 185, 83), "CQ")
    cover("orbit_runner_cover.png", "ORBIT\nRUNNER", "Launch Edition", (47, 60, 105), (21, 36, 54), (107, 177, 221), "OR")
    cover("cobalt_courier_cover.png", "COBALT\nCOURIER", "Adventure RPG", (55, 86, 103), (26, 45, 63), (211, 125, 84), "CC")
    console_box()
    controller_pack()
    poster_grand_opening()
    shelf_label()
    carpet()
    mall_tile()


if __name__ == "__main__":
    main()
