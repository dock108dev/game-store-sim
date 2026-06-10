class_name StoreAmbience
extends Node3D

const REQUIRED_AMBIENCE_IDS: Array[String] = [
	"room_tone",
	"hvac",
	"street_muffle",
	"door_chime",
	"register_area",
	"backroom",
	"closing_quiet",
]

const AMBIENCE_CATALOG: Array[Dictionary] = [
	{
		"id": "room_tone",
		"label": "Room tone",
		"kind": "loop",
		"zone": "sales_floor",
		"player_path": "RoomTonePlayer",
		"volume_db": -26.0,
		"max_distance": 12.0,
		"summary": "Low retail bed under the sales floor.",
	},
	{
		"id": "hvac",
		"label": "HVAC",
		"kind": "loop",
		"zone": "ceiling",
		"player_path": "HvacPlayer",
		"volume_db": -30.0,
		"max_distance": 11.0,
		"summary": "Soft mechanical air tone for store presence.",
	},
	{
		"id": "street_muffle",
		"label": "Street muffle",
		"kind": "loop",
		"zone": "storefront",
		"player_path": "StreetMufflePlayer",
		"volume_db": -31.0,
		"max_distance": 5.5,
		"summary": "Muted exterior traffic near the front glass.",
	},
	{
		"id": "door_chime",
		"label": "Door chime",
		"kind": "stinger",
		"zone": "front_door",
		"player_path": "DoorChimePlayer",
		"volume_db": -18.0,
		"max_distance": 5.0,
		"summary": "Short entry cue reserved for customer/player transitions.",
	},
	{
		"id": "register_area",
		"label": "Register area ambience",
		"kind": "loop",
		"zone": "register",
		"player_path": "RegisterAmbiencePlayer",
		"volume_db": -29.0,
		"max_distance": 4.5,
		"summary": "Quiet counter electronics and idle register bed.",
	},
	{
		"id": "backroom",
		"label": "Backroom ambience",
		"kind": "loop",
		"zone": "backroom",
		"player_path": "BackroomAmbiencePlayer",
		"volume_db": -28.0,
		"max_distance": 6.5,
		"summary": "Cooler backroom hum around receiving and the computer.",
	},
	{
		"id": "closing_quiet",
		"label": "Closing quiet",
		"kind": "state",
		"zone": "whole_store",
		"player_path": "ClosingQuietPlayer",
		"volume_db": -34.0,
		"max_distance": 12.0,
		"summary": "Reduced end-of-day bed after the register closes.",
	},
]

@export var auto_configure_players: bool = true
@export var master_volume_offset_db: float = 0.0


func _ready() -> void:
	if auto_configure_players:
		configure_players()


func configure_players() -> void:
	for entry in AMBIENCE_CATALOG:
		var player := get_node_or_null(str(entry.get("player_path", ""))) as AudioStreamPlayer3D
		if player == null:
			continue
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = 22050.0
		stream.buffer_length = 0.2
		player.stream = stream
		player.volume_db = float(entry.get("volume_db", -30.0)) + master_volume_offset_db
		player.max_distance = float(entry.get("max_distance", 6.0))
		player.unit_size = 2.0
		player.bus = "Master"
		player.autoplay = false


func get_ambience_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for entry in AMBIENCE_CATALOG:
		catalog.append(entry.duplicate(true))
	return catalog


func get_ambience_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry in AMBIENCE_CATALOG:
		ids.append(str(entry.get("id", "")))
	return ids


func has_required_ambience() -> bool:
	var ids := get_ambience_ids()
	for required_id in REQUIRED_AMBIENCE_IDS:
		if not ids.has(required_id):
			return false
	return true


func get_ambience_summary_text() -> String:
	var lines: Array[String] = ["Store ambience baseline:"]
	for entry in AMBIENCE_CATALOG:
		lines.append("%s (%s, %s) at %0.1f dB - %s" % [
			str(entry.get("label", "")),
			str(entry.get("kind", "")),
			str(entry.get("zone", "")),
			float(entry.get("volume_db", 0.0)) + master_volume_offset_db,
			str(entry.get("summary", "")),
		])
	return "\n".join(lines)
