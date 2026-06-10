#!/usr/bin/env python3
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
PRODUCT_DIR = REPO_ROOT / "game" / "data" / "products"

FORBIDDEN_REAL_NAMES = {
    "mario",
    "zelda",
    "pokemon",
    "playstation",
    "xbox",
    "nintendo",
    "sega",
}

REQUIRED_FIELDS = {
    "product_id",
    "display_name",
    "category",
    "platform",
    "platform_family",
    "condition",
    "completeness",
    "format",
    "authenticity",
    "rarity",
    "demand_tier",
    "cost_basis_cents",
    "market_value_cents",
    "suggested_price_cents",
    "risk_level",
    "default_location_id",
    "player_priceable",
}

REQUIRED_CATEGORIES = {
    "used_game",
    "new_game",
    "accessory",
    "hardware",
    "service",
}

REQUIRED_VISUAL_VARIANTS = {
    "case",
    "disc",
    "cartridge",
    "accessory",
    "console",
    "controller",
    "box",
    "sealed",
    "loose",
    "service_ticket",
}


def parse_value(raw: str):
    raw = raw.strip()
    if raw.startswith('"') and raw.endswith('"'):
        return raw[1:-1]
    if raw == "true":
        return True
    if raw == "false":
        return False
    if raw.startswith("Array[String]("):
        return re.findall(r'"([^"]*)"', raw)
    if re.fullmatch(r"-?\d+", raw):
        return int(raw)
    return raw


def load_product(path: Path) -> dict:
    data = {}
    for line in path.read_text().splitlines():
        if "=" not in line or line.startswith("["):
            continue
        key, raw_value = line.split("=", 1)
        data[key.strip()] = parse_value(raw_value)
    return data


def visual_variants(product: dict) -> set[str]:
    category = str(product.get("category", ""))
    product_format = str(product.get("format", ""))
    completeness = str(product.get("completeness", ""))
    variants = set()

    if category == "service" or product_format == "service_ticket":
        variants.add("service_ticket")
        return variants

    if category in {"hardware", "accessory"}:
        variants.add("box")
    elif completeness == "loose":
        variants.add("loose")
    else:
        variants.add("case")

    if completeness == "sealed":
        variants.add("sealed")
    if product_format in {"disc", "cartridge", "accessory", "console", "controller"}:
        variants.add(product_format)
    elif category == "accessory":
        variants.add("accessory")

    return variants


def validate_products(products: list[tuple[Path, dict]]) -> list[str]:
    failures = []
    seen_ids = {}
    categories = set()
    variants = set()
    sellable_count = 0

    for path, product in products:
        relative_path = path.relative_to(REPO_ROOT)
        missing_fields = sorted(REQUIRED_FIELDS - product.keys())
        if missing_fields:
            failures.append(f"{relative_path} missing fields: {', '.join(missing_fields)}")

        product_id = str(product.get("product_id", "")).strip()
        if not product_id:
            failures.append(f"{relative_path} has empty product_id")
        elif product_id in seen_ids:
            failures.append(
                f"duplicate product_id {product_id}: {seen_ids[product_id].relative_to(REPO_ROOT)} and {relative_path}"
            )
        else:
            seen_ids[product_id] = path

        display_name = str(product.get("display_name", "")).strip()
        if not display_name:
            failures.append(f"{relative_path} has empty display_name")
        lowered_name = display_name.lower()
        for forbidden in FORBIDDEN_REAL_NAMES:
            if forbidden in lowered_name:
                failures.append(f"{relative_path} uses forbidden real-world name fragment: {forbidden}")

        category = str(product.get("category", "")).strip()
        if category:
            categories.add(category)
        variants.update(visual_variants(product))

        market_value_cents = int(product.get("market_value_cents", 0) or 0)
        suggested_price_cents = int(product.get("suggested_price_cents", 0) or 0)
        cost_basis_cents = int(product.get("cost_basis_cents", 0) or 0)
        if cost_basis_cents < 0:
            failures.append(f"{relative_path} has negative cost_basis_cents")
        if market_value_cents <= 0:
            failures.append(f"{relative_path} must have positive market_value_cents")
        if suggested_price_cents <= 0:
            failures.append(f"{relative_path} must have positive suggested_price_cents")
        if suggested_price_cents > market_value_cents:
            failures.append(f"{relative_path} suggested price exceeds market value")
        if suggested_price_cents < cost_basis_cents:
            failures.append(f"{relative_path} suggested price is below cost basis")

        if bool(product.get("player_priceable", False)):
            sellable_count += 1

    missing_categories = sorted(REQUIRED_CATEGORIES - categories)
    if missing_categories:
        failures.append(f"missing product categories: {', '.join(missing_categories)}")

    missing_variants = sorted(REQUIRED_VISUAL_VARIANTS - variants)
    if missing_variants:
        failures.append(f"missing product visual variants: {', '.join(missing_variants)}")

    if len(products) < 30:
        failures.append(f"product catalog has {len(products)} products; expected at least 30")
    if sellable_count < 24:
        failures.append(f"product catalog has {sellable_count} sellable products; expected at least 24")

    return failures


def main() -> int:
    if not PRODUCT_DIR.exists():
        print(f"ERROR: missing product directory {PRODUCT_DIR.relative_to(REPO_ROOT)}", file=sys.stderr)
        return 1

    paths = sorted(PRODUCT_DIR.glob("*.tres"))
    products = [(path, load_product(path)) for path in paths]
    failures = validate_products(products)

    print(f"Product catalog content check: {len(products)} products")
    if failures:
        for failure in failures:
            print(f"ERROR: {failure}", file=sys.stderr)
        return 1

    print("Product catalog content check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
