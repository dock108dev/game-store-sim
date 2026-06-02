## Maps canonical placement reason keys to actionable player-facing text.
class_name PlacementReasonText
extends RefCounted

const TEXT_BY_REASON: Dictionary = {
	"out_of_bounds": "Outside build area",
	"entry_zone_blocked": "Keep the entrance clear",
	"max_fixtures_reached": "Fixture limit reached",
	"wall_required": "Must touch a wall",
	"wrong_facing": "Rotate to face the aisle",
	"occupied_collision": "Space already occupied",
	"aisle_too_narrow": "Leave a wider aisle",
	"not_reachable": "Blocks store pathing",
	"insufficient_funds": "Not enough cash",
	"no_register": "Register required",
	"cannot_remove_register": "Register cannot be removed",
	"removal_breaks_connectivity": "Removal breaks pathing",
}

const PRIORITY: Array[String] = [
	"out_of_bounds",
	"occupied_collision",
	"entry_zone_blocked",
	"max_fixtures_reached",
	"wall_required",
	"wrong_facing",
	"aisle_too_narrow",
	"not_reachable",
	"insufficient_funds",
	"no_register",
	"cannot_remove_register",
	"removal_breaks_connectivity",
]


## Returns display text for a canonical reason key.
static func get_text(reason: String) -> String:
	return TEXT_BY_REASON.get(reason, reason.capitalize()) as String


## Chooses the primary reason by canonical display priority.
static func choose_primary(reasons: Array[String]) -> String:
	for reason: String in PRIORITY:
		if reasons.has(reason):
			return reason
	if reasons.is_empty():
		return ""
	return reasons[0]
