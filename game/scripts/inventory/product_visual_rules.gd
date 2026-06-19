extends RefCounted
class_name ProductVisualRules

const VARIANT_CASE := "case"
const VARIANT_DISC := "disc"
const VARIANT_CARTRIDGE := "cartridge"
const VARIANT_ACCESSORY := "accessory"
const VARIANT_CONSOLE := "console"
const VARIANT_CONTROLLER := "controller"
const VARIANT_BOX := "box"
const VARIANT_SEALED := "sealed"
const VARIANT_LOOSE := "loose"
const VARIANT_SERVICE_TICKET := "service_ticket"
const CUE_SCRATCHES := "scratches"
const CUE_MISSING_MANUAL := "missing_manual"
const CUE_LOOSE_MEDIA := "loose_media"
const CUE_DAMAGED_LABEL := "damaged_label"
const CUE_RESEALED := "resealed"
const CUE_SERIAL_RISK := "serial_risk"
const GENRE_GENERAL := "general"
const GENRE_SPORTS := "sports"
const GENRE_RPG_ADVENTURE := "rpg_adventure"
const GENRE_RACING := "racing"
const GENRE_ACTION := "action"
const GENRE_FAMILY := "family"
const GENRE_HARDWARE := "hardware"
const GENRE_ACCESSORY := "accessory"
const GENRE_SERVICE := "service"

const REQUIRED_VARIANTS := [
	VARIANT_CASE,
	VARIANT_DISC,
	VARIANT_CARTRIDGE,
	VARIANT_ACCESSORY,
	VARIANT_CONSOLE,
	VARIANT_CONTROLLER,
	VARIANT_BOX,
	VARIANT_SEALED,
	VARIANT_LOOSE,
	VARIANT_SERVICE_TICKET,
]


static func get_supported_variants() -> Array:
	return REQUIRED_VARIANTS.duplicate()


static func build_profile(product: ProductDefinition) -> Dictionary:
	var category := _normalize(product.category if product != null else "")
	var format := _normalize(product.format if product != null else "")
	var completeness := _normalize(product.completeness if product != null else "")
	var platform_family := _normalize(product.get_platform_family() if product != null else "")
	var genre_id := _normalize(product.get_genre_id() if product != null else GENRE_GENERAL)
	var product_id := _normalize(product.product_id if product != null else "")
	var condition_cues := _get_condition_cues(product)

	var container_variant := VARIANT_CASE
	var media_variant := _get_media_variant(category, format)
	var state_variant := VARIANT_BOX

	if category == "hardware" or category == "accessory":
		container_variant = VARIANT_BOX
	elif category == "service" or format == VARIANT_SERVICE_TICKET:
		container_variant = VARIANT_SERVICE_TICKET
		media_variant = VARIANT_SERVICE_TICKET
		state_variant = VARIANT_SERVICE_TICKET
	elif completeness == VARIANT_LOOSE:
		container_variant = VARIANT_LOOSE
		state_variant = VARIANT_LOOSE
	elif completeness == VARIANT_SEALED:
		state_variant = VARIANT_SEALED

	return {
		"container_variant": container_variant,
		"media_variant": media_variant,
		"state_variant": state_variant,
		"product_art_key": _get_product_art_key(product_id, genre_id, media_variant),
		"variant_keys": _unique_variants([container_variant, media_variant, state_variant]),
		"case_size": _get_container_size(container_variant, media_variant),
		"media_size": _get_media_size(media_variant),
		"media_position": _get_media_position(media_variant),
		"box_size": Vector3(0.22, 0.09, 0.025),
		"box_position": Vector3(0.0, 0.062, -0.037),
		"seal_size": Vector3(0.255, 0.355, 0.014),
		"seal_position": Vector3(0.0, 0.17, -0.039),
		"loose_size": Vector3(0.11, 0.05, 0.016),
		"loose_position": Vector3(0.0, 0.068, -0.04),
		"service_ticket_size": Vector3(0.18, 0.24, 0.012),
		"service_ticket_position": Vector3(0.0, 0.18, -0.04),
		"condition_cues": condition_cues,
		"platform_color": get_platform_color(platform_family),
		"platform_accent_color": get_platform_accent_color(platform_family),
		"genre_color": get_genre_color(genre_id),
		"genre_accent_color": get_genre_accent_color(genre_id),
		"case_body_color": _get_case_body_color(category, container_variant),
		"cover_base_color": _get_cover_base_color(category, genre_id),
		"price_sticker_color": _get_price_sticker_color(category, product.condition if product != null else ""),
		"used_sticker_color": Color(0.98, 0.82, 0.36, 1.0),
		"platform_family": platform_family,
		"genre_id": genre_id,
		"show_cover": container_variant != VARIANT_SERVICE_TICKET,
		"show_spine": container_variant == VARIANT_CASE,
		"show_platform_band": container_variant != VARIANT_SERVICE_TICKET,
		"show_genre_accent": container_variant != VARIANT_SERVICE_TICKET,
		"show_price_sticker": category != "service",
		"show_used_sticker": category == "used_game" or _normalize(product.condition if product != null else "") == "used",
	}


static func get_platform_color(platform_family: String) -> Color:
	match _normalize(platform_family):
		"vortex":
			return Color(0.02, 0.43, 0.42, 1.0)
		"nova_disc":
			return Color(0.12, 0.48, 0.9, 1.0)
		"orbit_classic":
			return Color(0.98, 0.74, 0.22, 1.0)
		"pocket_handheld":
			return Color(0.18, 0.66, 0.48, 1.0)
		"service_bench":
			return Color(0.82, 0.74, 0.58, 1.0)
		_:
			return Color(0.72, 0.78, 0.84, 1.0)


static func get_platform_accent_color(platform_family: String) -> Color:
	match _normalize(platform_family):
		"vortex":
			return Color(0.98, 0.9, 0.72, 1.0)
		"nova_disc":
			return Color(0.78, 0.92, 1.0, 1.0)
		"orbit_classic":
			return Color(0.18, 0.12, 0.08, 1.0)
		"pocket_handheld":
			return Color(0.86, 1.0, 0.78, 1.0)
		"service_bench":
			return Color(0.16, 0.15, 0.13, 1.0)
		_:
			return Color(0.14, 0.18, 0.22, 1.0)


static func get_genre_color(genre_id: String) -> Color:
	match _normalize(genre_id):
		GENRE_SPORTS:
			return Color(0.18, 0.62, 0.28, 1.0)
		GENRE_RPG_ADVENTURE:
			return Color(0.5, 0.3, 0.84, 1.0)
		GENRE_RACING:
			return Color(0.9, 0.2, 0.16, 1.0)
		GENRE_ACTION:
			return Color(0.92, 0.46, 0.18, 1.0)
		GENRE_FAMILY:
			return Color(0.18, 0.74, 0.78, 1.0)
		GENRE_HARDWARE:
			return Color(0.52, 0.56, 0.62, 1.0)
		GENRE_ACCESSORY:
			return Color(0.42, 0.72, 0.5, 1.0)
		GENRE_SERVICE:
			return Color(0.88, 0.7, 0.36, 1.0)
		_:
			return Color(0.72, 0.62, 0.5, 1.0)


static func get_genre_accent_color(genre_id: String) -> Color:
	var base := get_genre_color(genre_id)
	return Color(
		minf(base.r + 0.18, 1.0),
		minf(base.g + 0.16, 1.0),
		minf(base.b + 0.12, 1.0),
		1.0
	)


static func _get_media_variant(category: String, format: String) -> String:
	if category == "hardware":
		if format == VARIANT_CONSOLE:
			return VARIANT_CONSOLE
		if format == VARIANT_CONTROLLER:
			return VARIANT_CONTROLLER
		return VARIANT_ACCESSORY
	if category == "accessory":
		return VARIANT_ACCESSORY

	if format == VARIANT_DISC:
		return VARIANT_DISC
	if format == VARIANT_CARTRIDGE:
		return VARIANT_CARTRIDGE
	if format == VARIANT_ACCESSORY:
		return VARIANT_ACCESSORY
	if format == VARIANT_CONSOLE:
		return VARIANT_CONSOLE
	if format == VARIANT_CONTROLLER:
		return VARIANT_CONTROLLER
	if format == VARIANT_SERVICE_TICKET:
		return VARIANT_SERVICE_TICKET

	return VARIANT_CASE


static func _get_container_size(container_variant: String, media_variant: String) -> Vector3:
	if container_variant == VARIANT_BOX:
		if media_variant == VARIANT_CONSOLE:
			return Vector3(0.52, 0.34, 0.18)
		if media_variant == VARIANT_CONTROLLER:
			return Vector3(0.3, 0.34, 0.08)
		if media_variant == VARIANT_ACCESSORY:
			return Vector3(0.24, 0.3, 0.065)
		return Vector3(0.26, 0.18, 0.07)
	if container_variant == VARIANT_LOOSE:
		if media_variant == VARIANT_DISC:
			return Vector3(0.18, 0.18, 0.016)
		return Vector3(0.16, 0.22, 0.035)
	if container_variant == VARIANT_SERVICE_TICKET:
		return Vector3(0.2, 0.28, 0.014)
	return Vector3(0.24, 0.34, 0.04)


static func _get_media_size(media_variant: String) -> Vector3:
	if media_variant == VARIANT_DISC:
		return Vector3(0.09, 0.09, 0.012)
	if media_variant == VARIANT_CARTRIDGE:
		return Vector3(0.08, 0.11, 0.018)
	if media_variant == VARIANT_CONSOLE:
		return Vector3(0.18, 0.055, 0.035)
	if media_variant == VARIANT_CONTROLLER:
		return Vector3(0.13, 0.055, 0.025)
	if media_variant == VARIANT_ACCESSORY:
		return Vector3(0.105, 0.075, 0.025)
	return Vector3(0.08, 0.08, 0.012)


static func _get_media_position(media_variant: String) -> Vector3:
	if media_variant == VARIANT_CONSOLE:
		return Vector3(0.0, 0.15, -0.048)
	if media_variant == VARIANT_CONTROLLER:
		return Vector3(0.0, 0.145, -0.047)
	if media_variant == VARIANT_ACCESSORY:
		return Vector3(0.0, 0.145, -0.047)
	return Vector3(-0.035, 0.112, -0.044)


static func _get_case_body_color(category: String, container_variant: String) -> Color:
	if container_variant == VARIANT_SERVICE_TICKET:
		return Color(0.9, 0.84, 0.66, 1.0)
	if container_variant == VARIANT_BOX:
		return Color(0.78, 0.73, 0.62, 1.0)
	if category == "new_game":
		return Color(0.94, 0.96, 0.92, 1.0)
	if category == "used_game":
		return Color(0.035, 0.055, 0.07, 1.0)
	return Color(0.18, 0.2, 0.22, 1.0)


static func _get_cover_base_color(category: String, genre_id: String) -> Color:
	var genre_color := get_genre_color(genre_id)
	if category == "used_game":
		return Color(
			maxf(genre_color.r * 0.72, 0.08),
			maxf(genre_color.g * 0.72, 0.08),
			maxf(genre_color.b * 0.72, 0.08),
			1.0
		)
	return genre_color


static func _get_price_sticker_color(category: String, condition: String) -> Color:
	var normalized_condition := _normalize(condition)
	if category == "used_game" or normalized_condition == "fair" or normalized_condition == "poor":
		return Color(0.98, 0.82, 0.36, 1.0)
	if category == "hardware" or category == "accessory":
		return Color(0.8, 0.95, 0.78, 1.0)
	return Color(0.94, 0.96, 0.98, 1.0)


static func _unique_variants(variants: Array) -> Array[String]:
	var keys: Array[String] = []
	for variant in variants:
		var key := str(variant)
		if key.is_empty():
			continue
		if not keys.has(key):
			keys.append(key)
	return keys


static func _get_condition_cues(product: ProductDefinition) -> Array[String]:
	var cues: Array[String] = []
	if product == null:
		return cues

	var condition := _normalize(product.condition)
	var completeness := _normalize(product.completeness)
	var authenticity := _normalize(product.authenticity)
	var risk_tags := product.risk_tags

	if condition == "fair" or condition == "poor":
		cues.append(CUE_SCRATCHES)
	if completeness == "manual_missing":
		cues.append(CUE_MISSING_MANUAL)
	if completeness == VARIANT_LOOSE or risk_tags.has(CUE_LOOSE_MEDIA):
		cues.append(CUE_LOOSE_MEDIA)
	if condition == "poor" or risk_tags.has("label_wear") or risk_tags.has("poor_condition"):
		cues.append(CUE_DAMAGED_LABEL)
	if completeness == VARIANT_SEALED and authenticity != "verified":
		cues.append(CUE_RESEALED)
	if authenticity == "uncertain" or authenticity == "needs_review" or risk_tags.has("serial_check"):
		cues.append(CUE_SERIAL_RISK)

	return _unique_variants(cues)


static func _normalize(value: String) -> String:
	return value.strip_edges().to_lower()


static func _get_product_art_key(product_id: String, genre_id: String, media_variant: String) -> String:
	if product_id == "new_footy_2002":
		return "footy_2002"
	if product_id == "new_critter_quest_ii":
		return "critter_quest_ii"
	if media_variant == VARIANT_CONSOLE:
		return "vortex_console_box"
	if media_variant == VARIANT_CONTROLLER:
		return "vortex_controller_box"
	if media_variant == VARIANT_ACCESSORY:
		return "vortex_accessory_box"
	return genre_id
