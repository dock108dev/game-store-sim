## Secondary full-store visual sweep context kept out of phase acceptance.
class_name StoreVisualFullStoreContext
extends RefCounted

const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)


## Returns older broad-store review context kept out of phase acceptance.
static func context(beats: Array[Dictionary]) -> Dictionary:
	return {
		"review_target": "full_store_context",
		"acceptance_role": "secondary_context_only",
		"notes": (
			"Whole-room context may be reviewed separately; "
			+ "this phase passes or fails on the first-ten-seconds route views."
		),
		"beats": beats,
	}


## Returns the older eight-angle full-store sweep for secondary review context.
static func rows() -> Array[Dictionary]:
	return [
		_row(
			1,
			"entrance_looking_in",
			"Entrance looking in",
			"01_entrance_looking_in.png",
			Vector3(2.2, 1.7, 9.15),
			"InteriorSignage/StoreNameBanner",
			["Storefront", "EntranceInterior", "ReadabilityProps/FloorDisplayIsland"]
		),
		_row(
			2,
			"center_to_checkout",
			"Center to checkout",
			"02_center_to_checkout.png",
			Vector3(0.0, 1.75, 0.25),
			"Checkout/Register/CheckoutSign",
			["Checkout", "StoreSessionDayEndTrigger", "ReadabilityProps/CheckoutCounterDressing"]
		),
		_row(
			3,
			"center_to_shelves",
			"Center to shelves",
			"03_center_to_shelves.png",
			Vector3(0.0, 1.75, 0.25),
			"ZoneLabels/ShelvesLabel",
			["StoreSessionRestockShelf", "ReadabilityProps/ShelfSpineRuns", "AccessoriesBin"]
		),
		_row(
			4,
			"center_to_backroom",
			"Center to backroom",
			"04_center_to_backroom.png",
			Vector3(0.0, 1.75, 0.25),
			"StoreSessionBackroomPickup/StockBoxLabel",
			["back_room", "StoreSessionBackroomPickup", "ReadabilityProps/BackroomDressing"]
		),
		_row(
			5,
			"checkout_across_store",
			"Checkout across store",
			"05_checkout_across_store.png",
			Vector3(4.9, 1.75, 6.9),
			"ZoneLabels/StaffPicksLabel",
			["Checkout", "staff_picks_table", "ReadabilityProps/FloorDisplayIsland"]
		),
		_row(
			6,
			"stockroom_looking_out",
			"Stockroom looking out",
			"06_stockroom_looking_out.png",
			Vector3(0.0, 1.75, -8.45),
			"EntranceInterior",
			["back_room", "Checkout", "ReadabilityProps/DayOneRouteMarkers"]
		),
		_row(
			7,
			"try_it_testing_corner",
			"Try-it testing corner",
			"07_try_it_testing_corner.png",
			Vector3(-2.8, 1.75, -4.5),
			"crt_demo_area/ComingSoonLabel",
			["crt_demo_area", "crt_demo_area/SetupBarrierRail"]
		),
		_row(
			8,
			"opposite_corner_full_room_view",
			"Opposite-corner full-room view",
			"08_opposite_corner_full_room_view.png",
			Vector3(-6.4, 3.4, 8.4),
			"ReadabilityProps/DayOneRouteMarkers/TrainingStopShelf",
			["ZoneLabels", "ReadabilityProps/ZoneLighting", "ReadabilityProps/ZoneIdentity"]
		),
	]


static func _row(
	index: int,
	name: String,
	label: String,
	filename: String,
	camera: Vector3,
	focus: String,
	anchors: Array[String]
) -> Dictionary:
	return {
		"index": index,
		"name": name,
		"label": label,
		"filename": filename,
		"camera": camera,
		"focus": focus,
		"anchors": anchors,
		"scope": "full_store",
		"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
		"review_target": "full_store_context",
	}
