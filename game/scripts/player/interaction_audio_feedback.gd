class_name InteractionAudioFeedback
extends Node3D

const REQUIRED_CUE_IDS: Array[String] = [
	"pickup",
	"place",
	"stock",
	"scan",
	"register",
	"cash_drawer",
	"computer_click",
	"button_hover",
	"button_click",
	"box_open",
	"shelf_bump",
	"error",
]

const CUE_CATALOG: Array[Dictionary] = [
	{"id": "pickup", "label": "Pickup", "player_path": "PickupPlayer", "volume_db": -16.0, "category": "inventory", "summary": "Short case lift cue."},
	{"id": "place", "label": "Place", "player_path": "PlacePlayer", "volume_db": -17.0, "category": "inventory", "summary": "Soft item place cue."},
	{"id": "stock", "label": "Stock", "player_path": "StockPlayer", "volume_db": -15.0, "category": "inventory", "summary": "Shelf stocking confirmation."},
	{"id": "scan", "label": "Scan", "player_path": "ScanPlayer", "volume_db": -15.0, "category": "register", "summary": "Register item scan beep."},
	{"id": "register", "label": "Register", "player_path": "RegisterPlayer", "volume_db": -16.0, "category": "register", "summary": "Register surface open cue."},
	{"id": "cash_drawer", "label": "Cash drawer", "player_path": "CashDrawerPlayer", "volume_db": -14.0, "category": "register", "summary": "Cash drawer hit for completed tender."},
	{"id": "computer_click", "label": "Computer click", "player_path": "ComputerClickPlayer", "volume_db": -18.0, "category": "computer", "summary": "Backroom terminal click."},
	{"id": "button_hover", "label": "Button hover", "player_path": "ButtonHoverPlayer", "volume_db": -24.0, "category": "ui", "summary": "Subtle hover tick for later UI wiring."},
	{"id": "button_click", "label": "Button click", "player_path": "ButtonClickPlayer", "volume_db": -18.0, "category": "ui", "summary": "Panel button confirmation."},
	{"id": "box_open", "label": "Box open", "player_path": "BoxOpenPlayer", "volume_db": -16.0, "category": "receiving", "summary": "Receiving box cardboard cue."},
	{"id": "shelf_bump", "label": "Shelf bump", "player_path": "ShelfBumpPlayer", "volume_db": -18.0, "category": "fixture", "summary": "Invalid or occupied shelf bump."},
	{"id": "error", "label": "Error", "player_path": "ErrorPlayer", "volume_db": -20.0, "category": "feedback", "summary": "Low blocked-action tick."},
]

@export var playback_enabled: bool = false
@export var master_volume_offset_db: float = 0.0

var last_cue_id: String = ""
var played_cue_history: Array[String] = []


func _ready() -> void:
	configure_players()


func configure_players() -> void:
	for cue in CUE_CATALOG:
		var player := get_node_or_null(str(cue.get("player_path", ""))) as AudioStreamPlayer
		if player == null:
			continue
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = 22050.0
		stream.buffer_length = 0.12
		player.stream = stream
		player.volume_db = float(cue.get("volume_db", -18.0)) + master_volume_offset_db
		player.bus = "Master"
		player.autoplay = false


func get_cue_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for cue in CUE_CATALOG:
		catalog.append(cue.duplicate(true))
	return catalog


func get_cue_ids() -> Array[String]:
	var ids: Array[String] = []
	for cue in CUE_CATALOG:
		ids.append(str(cue.get("id", "")))
	return ids


func has_required_cues() -> bool:
	var ids := get_cue_ids()
	for cue_id in REQUIRED_CUE_IDS:
		if not ids.has(cue_id):
			return false
	return true


func play_cue(cue_id: String) -> bool:
	var cue := _get_cue(cue_id)
	if cue.is_empty():
		return false

	last_cue_id = cue_id
	played_cue_history.append(cue_id)
	var player := get_node_or_null(str(cue.get("player_path", ""))) as AudioStreamPlayer
	if playback_enabled and player != null:
		player.play()
	return true


func get_interaction_audio_summary_text() -> String:
	var lines: Array[String] = ["Interaction audio baseline:"]
	for cue in CUE_CATALOG:
		lines.append("%s (%s) at %0.1f dB - %s" % [
			str(cue.get("label", "")),
			str(cue.get("category", "")),
			float(cue.get("volume_db", 0.0)) + master_volume_offset_db,
			str(cue.get("summary", "")),
		])
	return "\n".join(lines)


func _get_cue(cue_id: String) -> Dictionary:
	for cue in CUE_CATALOG:
		if str(cue.get("id", "")) == cue_id:
			return cue
	return {}
