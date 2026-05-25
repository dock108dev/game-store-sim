## Canonical manifest data for the internal visual gallery.
class_name VisualGalleryManifest
extends RefCounted

const AutomationArtifactsScript: GDScript = preload(
	"res://game/scripts/core/automation_artifacts.gd"
)
const StoreVisualScopeProfileScript: GDScript = preload(
	"res://game/scripts/store_session/store_visual_scope_profile.gd"
)

const GALLERY_ID: String = "visual_gallery"
const REVIEW_MANIFEST_FILENAME: String = "review_manifest.json"
const MOVIE_SCENARIO_ID: String = "gallery_walkthrough_smoke"
const GROUP_ORDER: Array[String] = [
	"characters",
	"products",
	"storefronts",
	"fixtures",
	"registers",
	"stock_room",
	"signage",
	"hud",
	"buttons",
	"icons",
	"dialogue",
]
const REQUIRED_ITEM_FIELDS: Array[String] = [
	"id",
	"display_name",
	"group",
	"source",
	"spawn_mode",
	"states",
	"tags",
	"camera_config",
	"grid_placement",
]
const REVIEW_FLAG_TYPES: Array[String] = [
	"scale_outlier",
	"inconsistent_material_family",
	"placeholder_like_geometry",
	"floating_prop",
	"unreadable_signage",
	"mismatched_ui_component_styling",
]


## Returns the gallery manifest rows in review order.
static func items() -> Array[Dictionary]:
	var camera_config: Dictionary = {"views": camera_views().keys(), "cycle_seconds": 3.0}
	return [
		_item("player_floor_clerk", "Floor Clerk", "characters",
			"StoreSessionCharacterVisualFactory", "character_factory",
			["idle", "walk", "talk"], ["player", "mesh", "material"], camera_config, 0, 0),
		_item("retro_game_case", "Retro Game Case", "products",
			"ProductVisualFactory", "product_factory",
			["loose", "boxed", "highlighted"], ["product_box", "designed_surface"],
			camera_config, 0, 1),
		_item("retro_storefront", "Retro Games Storefront", "storefronts",
			"res://game/scenes/stores/retro_games.tscn", "storefront_reference",
			["authored_full", "runtime_hidden", "reference_visible"],
			["authored_scope", "readable_text"], camera_config, 0, 2),
		_item("wall_shelf", "Wall Shelf", "fixtures", "StoreVisualKit.wall_shelf",
			"store_visual_kit", ["empty", "filled", "highlighted"],
			["fixture", "interactive"], camera_config, 1, 0),
		_item("register_terminal", "Register Terminal", "registers",
			"StoreVisualKit.register", "store_visual_kit",
			["idle", "scanning", "payment"], ["register", "interactive"],
			camera_config, 1, 1),
		_item("stockroom_delivery", "Stock Room Delivery", "stock_room",
			"StoreVisualKit.stock_box", "stock_room_cluster",
			["sealed", "open", "loaded"], ["stock_room", "collision"],
			camera_config, 1, 2),
		_item("queue_sign", "Queue Sign", "signage", "Label3D", "sign_label",
			["normal", "highlighted"], ["signage", "readable_text"], camera_config, 2, 0),
		_item("hud_status_strip", "HUD Status Strip", "hud", "Control",
			"hud_panel", ["normal", "warning", "success"],
			["ui", "readable_text"], camera_config, 2, 1),
		_item("primary_button", "Primary Button", "buttons", "Button",
			"button_control", ["normal", "hover", "pressed", "disabled"],
			["ui", "button", "readable_text"], camera_config, 2, 2),
		_item("money_icon", "Money Icon", "icons", "TextureRect", "icon_control",
			["normal", "gain", "loss"], ["ui", "icon"], camera_config, 3, 0),
		_item("dialogue_choice", "Dialogue Choice", "dialogue", "PanelContainer",
			"dialogue_panel", ["speaker", "choice", "selected"],
			["ui", "dialogue", "readable_text"], camera_config, 3, 1),
	]


## Returns camera views used by screenshot and video review passes.
static func camera_views() -> Dictionary:
	return {
		"front": {"position": [0.0, 2.0, 6.0], "fov": 58.0},
		"side": {"position": [5.8, 2.0, 0.2], "fov": 58.0},
		"topish_gameplay": {"position": [0.0, 6.8, 5.0], "fov": 62.0},
		"close_up": {"position": [0.0, 1.3, 1.9], "fov": 46.0},
		"normal_gameplay_zoom": {"position": [0.0, 2.7, 7.6], "fov": 64.0},
		"small_viewport": {"viewport": [1024, 576], "fov": 62.0},
		"large_viewport": {"viewport": [1920, 1080], "fov": 62.0},
	}


## Returns the expected advisory Movie Maker output for gallery walkthroughs.
static func movie_artifact_path() -> String:
	return AutomationArtifactsScript.artifact_path(
		"videos/scenario/nightly/%s.avi" % MOVIE_SCENARIO_ID
	)


## Returns the screenshot beats expected from gallery artifact generation.
static func screenshot_beats() -> Array[Dictionary]:
	return [
		{"id": "player_variants", "filename": "01_player_variants.png", "state": "idle"},
		{"id": "storefronts", "filename": "02_storefronts.png", "state": "authored_full"},
		{"id": "products", "filename": "03_products.png", "state": "boxed"},
		{"id": "hud_states", "filename": "04_hud_states.png", "state": "warning"},
	]


static func _item(
	id: String,
	display_name: String,
	group: String,
	source: String,
	spawn_mode: String,
	states: Array[String],
	tags: Array[String],
	camera_config: Dictionary,
	row: int,
	column: int
) -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"group": group,
		"source": source,
		"spawn_mode": spawn_mode,
		"states": states,
		"tags": tags,
		"camera_config": camera_config,
		"grid_placement": {"row": row, "column": column},
		"visual_scope_mode": StoreVisualScopeProfileScript.MODE_AUTHORED_FULL_LABEL,
	}
