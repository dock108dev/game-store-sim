class_name CustomerAudioProfile
extends Node3D

const REQUIRED_CUE_IDS: Array[String] = [
	"footstep",
	"mumble",
	"greeting",
	"approval",
	"annoyance",
	"leaving",
]

const CUE_CATALOG: Array[Dictionary] = [
	{"id": "footstep", "label": "Footstep", "player_path": "FootstepPlayer", "volume_db": -22.0, "summary": "Soft movement tick for walking customers."},
	{"id": "mumble", "label": "Mumble", "player_path": "MumblePlayer", "volume_db": -26.0, "summary": "Nonverbal idle presence without final voice acting."},
	{"id": "greeting", "label": "Greeting", "player_path": "GreetingPlayer", "volume_db": -20.0, "summary": "Short hello cue for customer approach."},
	{"id": "approval", "label": "Approval", "player_path": "ApprovalPlayer", "volume_db": -19.0, "summary": "Positive confirmation after a satisfying outcome."},
	{"id": "annoyance", "label": "Annoyance", "player_path": "AnnoyancePlayer", "volume_db": -19.0, "summary": "Brief negative reaction for refusal or blocked flow."},
	{"id": "leaving", "label": "Leaving", "player_path": "LeavingPlayer", "volume_db": -21.0, "summary": "Exit cue for completed or abandoned customer flow."},
]

@export var role_id: String = "customer"
@export var playback_enabled: bool = false
@export var master_volume_offset_db: float = 0.0

var last_cue_id: String = ""
var played_cue_history: Array[String] = []


func _ready() -> void:
	configure_players()


func configure_players() -> void:
	for cue in CUE_CATALOG:
		var player := get_node_or_null(str(cue.get("player_path", ""))) as AudioStreamPlayer3D
		if player == null:
			continue
		var stream := AudioStreamGenerator.new()
		stream.mix_rate = 22050.0
		stream.buffer_length = 0.12
		player.stream = stream
		player.volume_db = float(cue.get("volume_db", -22.0)) + master_volume_offset_db
		player.max_distance = 4.0
		player.unit_size = 1.6
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
	var player := get_node_or_null(str(cue.get("player_path", ""))) as AudioStreamPlayer3D
	if playback_enabled and player != null:
		player.play()
	return true


func cue_for_feedback_tone(tone: String) -> String:
	match tone:
		"positive":
			return "approval"
		"warning", "suspicious":
			return "annoyance"
		_:
			return "mumble"


func get_customer_audio_summary_text() -> String:
	var lines: Array[String] = ["Customer audio placeholders for %s:" % role_id]
	for cue in CUE_CATALOG:
		lines.append("%s at %0.1f dB - %s" % [
			str(cue.get("label", "")),
			float(cue.get("volume_db", 0.0)) + master_volume_offset_db,
			str(cue.get("summary", "")),
		])
	return "\n".join(lines)


func _get_cue(cue_id: String) -> Dictionary:
	for cue in CUE_CATALOG:
		if str(cue.get("id", "")) == cue_id:
			return cue
	return {}
