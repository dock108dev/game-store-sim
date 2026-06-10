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

PLATFORM_FAMILY_RULES = {
    "nova_disc": {
        "platforms": {"Nova Cube"},
        "formats": {"disc", "accessory", "controller"},
    },
    "orbit_classic": {
        "platforms": {"Orbit 64"},
        "formats": {"cartridge", "accessory", "console"},
    },
    "pocket_handheld": {
        "platforms": {"Pocket Star"},
        "formats": {"cartridge", "accessory", "console"},
    },
    "service_bench": {
        "platforms": {"Service Bench"},
        "formats": {"service_ticket"},
    },
}

ALLOWED_CATEGORIES = {
    "used_game",
    "new_game",
    "accessory",
    "hardware",
    "service",
}

ALLOWED_CONDITIONS = {
    "new",
    "excellent",
    "good",
    "fair",
    "poor",
    "refurbished",
    "service",
}

ALLOWED_COMPLETENESS = {
    "sealed",
    "complete",
    "box_only",
    "manual_missing",
    "loose",
    "ticket",
}

ALLOWED_AUTHENTICITY = {
    "verified",
    "trusted",
    "uncertain",
    "needs_review",
}

ALLOWED_RARITY = {
    "common",
    "uncommon",
    "rare",
    "collector",
    "standard",
    "launch",
}

ALLOWED_DEMAND_TIERS = {
    "low",
    "medium",
    "high",
}

ALLOWED_RISK_LEVELS = {
    "low",
    "medium",
    "high",
}

ALLOWED_SERVICE_NAMES = {
    "Cartridge Cleaning Ticket",
    "Controller Test Ticket",
    "Disc Resurfacing Ticket",
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

MIN_TOTAL_PRODUCTS = 60
MIN_SELLABLE_PRODUCTS = 57
MIN_USED_GAMES = 36
MIN_NEW_GAMES = 9
MIN_ACCESSORY_HARDWARE = 9
MIN_SERVICE_TICKETS = 3


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
    category_counts = {}

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
        if len(display_name) > 28:
            failures.append(f"{relative_path} display_name is too long for tags and receipts: {display_name}")
        if ":" in display_name:
            failures.append(f"{relative_path} display_name should avoid subtitle punctuation: {display_name}")
        lowered_name = display_name.lower()
        for forbidden in FORBIDDEN_REAL_NAMES:
            if forbidden in lowered_name:
                failures.append(f"{relative_path} uses forbidden real-world name fragment: {forbidden}")

        category = str(product.get("category", "")).strip()
        if category:
            categories.add(category)
            category_counts[category] = int(category_counts.get(category, 0)) + 1
        if category and category not in ALLOWED_CATEGORIES:
            failures.append(f"{relative_path} uses unknown category: {category}")

        platform = str(product.get("platform", "")).strip()
        platform_family = str(product.get("platform_family", "")).strip()
        product_format = str(product.get("format", "")).strip()
        family_rules = PLATFORM_FAMILY_RULES.get(platform_family)
        if family_rules == None:
            failures.append(f"{relative_path} uses unknown platform_family: {platform_family}")
        else:
            if platform not in family_rules["platforms"]:
                failures.append(
                    f"{relative_path} platform {platform} does not match platform_family {platform_family}"
                )
            if product_format not in family_rules["formats"]:
                failures.append(
                    f"{relative_path} format {product_format} does not match platform_family {platform_family}"
                )
        for forbidden in FORBIDDEN_REAL_NAMES:
            if forbidden in platform.lower():
                failures.append(f"{relative_path} uses forbidden real-world platform fragment: {forbidden}")

        condition = str(product.get("condition", "")).strip()
        completeness = str(product.get("completeness", "")).strip()
        authenticity = str(product.get("authenticity", "")).strip()
        rarity = str(product.get("rarity", "")).strip()
        demand_tier = str(product.get("demand_tier", "")).strip()
        risk_level = str(product.get("risk_level", "")).strip()
        if condition and condition not in ALLOWED_CONDITIONS:
            failures.append(f"{relative_path} uses unknown condition: {condition}")
        if completeness and completeness not in ALLOWED_COMPLETENESS:
            failures.append(f"{relative_path} uses unknown completeness: {completeness}")
        if authenticity and authenticity not in ALLOWED_AUTHENTICITY:
            failures.append(f"{relative_path} uses unknown authenticity: {authenticity}")
        if rarity and rarity not in ALLOWED_RARITY:
            failures.append(f"{relative_path} uses unknown rarity: {rarity}")
        if demand_tier and demand_tier not in ALLOWED_DEMAND_TIERS:
            failures.append(f"{relative_path} uses unknown demand_tier: {demand_tier}")
        if risk_level and risk_level not in ALLOWED_RISK_LEVELS:
            failures.append(f"{relative_path} uses unknown risk_level: {risk_level}")
        if category == "service" and display_name not in ALLOWED_SERVICE_NAMES:
            failures.append(f"{relative_path} service name is outside the service naming set: {display_name}")

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

    used_game_count = int(category_counts.get("used_game", 0))
    new_game_count = int(category_counts.get("new_game", 0))
    accessory_hardware_count = int(category_counts.get("accessory", 0)) + int(category_counts.get("hardware", 0))
    service_count = int(category_counts.get("service", 0))

    if len(products) < MIN_TOTAL_PRODUCTS:
        failures.append(f"product catalog has {len(products)} products; expected at least {MIN_TOTAL_PRODUCTS}")
    if sellable_count < MIN_SELLABLE_PRODUCTS:
        failures.append(
            f"product catalog has {sellable_count} sellable products; expected at least {MIN_SELLABLE_PRODUCTS}"
        )
    if used_game_count < MIN_USED_GAMES:
        failures.append(f"product catalog has {used_game_count} used games; expected at least {MIN_USED_GAMES}")
    if new_game_count < MIN_NEW_GAMES:
        failures.append(f"product catalog has {new_game_count} new games; expected at least {MIN_NEW_GAMES}")
    if accessory_hardware_count < MIN_ACCESSORY_HARDWARE:
        failures.append(
            f"product catalog has {accessory_hardware_count} accessories/hardware; expected at least {MIN_ACCESSORY_HARDWARE}"
        )
    if service_count < MIN_SERVICE_TICKETS:
        failures.append(f"product catalog has {service_count} service tickets; expected at least {MIN_SERVICE_TICKETS}")

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
