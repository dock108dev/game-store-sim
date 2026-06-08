class_name PresentationMicrofeedback
extends Node3D

const REQUIRED_EFFECT_IDS: Array[String] = [
	"target_highlight",
	"item_settle",
	"sale_confirmation",
	"cash_tick",
	"reputation_tick",
	"day_transition",
	"delivery_arrival",
	"invalid_action",
]

const EFFECT_CATALOG: Array[Dictionary] = [
	{"id": "target_highlight", "label": "Target highlight", "node_path": "TargetHighlightParticles", "tone": "info", "summary": "Subtle pulse for inspected or targetable objects."},
	{"id": "item_settle", "label": "Item settle", "node_path": "ItemSettleParticles", "tone": "neutral", "summary": "Small dust/settle puff after pickup or placement."},
	{"id": "sale_confirmation", "label": "Sale confirmation", "node_path": "SaleConfirmationParticles", "tone": "positive", "summary": "Brief confirmation sparkle for completed checkout."},
	{"id": "cash_tick", "label": "Cash tick", "node_path": "CashTickParticles", "tone": "positive", "summary": "Small money/accounting tick for cash changes."},
	{"id": "reputation_tick", "label": "Reputation tick", "node_path": "ReputationTickParticles", "tone": "warning", "summary": "Compact reputation feedback for social/economy changes."},
	{"id": "day_transition", "label": "Day transition", "node_path": "DayTransitionParticles", "tone": "info", "summary": "Soft screen-space cue for ending or starting a day."},
	{"id": "delivery_arrival", "label": "Delivery arrival", "node_path": "DeliveryArrivalParticles", "tone": "info", "summary": "Receiving-focused cue for supplier deliveries."},
	{"id": "invalid_action", "label": "Invalid action", "node_path": "InvalidActionParticles", "tone": "warning", "summary": "Short blocked-action pulse that matches warning prompts."},
]

@export var playback_enabled: bool = false

var last_effect_id: String = ""
var triggered_effect_history: Array[String] = []


func _ready() -> void:
	configure_effects()


func configure_effects() -> void:
	for effect in EFFECT_CATALOG:
		var particles := get_node_or_null(str(effect.get("node_path", ""))) as CPUParticles3D
		if particles == null:
			continue
		particles.emitting = false
		particles.one_shot = true
		particles.lifetime = 0.35
		particles.amount = 8
		particles.explosiveness = 0.9


func get_effect_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for effect in EFFECT_CATALOG:
		catalog.append(effect.duplicate(true))
	return catalog


func get_effect_ids() -> Array[String]:
	var ids: Array[String] = []
	for effect in EFFECT_CATALOG:
		ids.append(str(effect.get("id", "")))
	return ids


func has_required_effects() -> bool:
	var ids := get_effect_ids()
	for effect_id in REQUIRED_EFFECT_IDS:
		if not ids.has(effect_id):
			return false
	return true


func trigger_effect(effect_id: String) -> bool:
	var effect := _get_effect(effect_id)
	if effect.is_empty():
		return false

	last_effect_id = effect_id
	triggered_effect_history.append(effect_id)
	var particles := get_node_or_null(str(effect.get("node_path", ""))) as CPUParticles3D
	if playback_enabled and particles != null:
		particles.restart()
	return true


func effect_for_result(result: String) -> String:
	var lower_result := result.to_lower()
	if lower_result.contains("unavailable") or lower_result.contains("cannot") or lower_result.contains("no "):
		return "invalid_action"
	if lower_result.contains("sold") or lower_result.contains("checkout") or lower_result.contains("preorder") or lower_result.contains("service complete"):
		return "sale_confirmation"
	if lower_result.contains("cash") or lower_result.contains("profit") or lower_result.contains("paid"):
		return "cash_tick"
	if lower_result.contains("reputation"):
		return "reputation_tick"
	if lower_result.contains("started day") or lower_result.contains("day closed") or lower_result.contains("launch"):
		return "day_transition"
	if lower_result.contains("delivered") or lower_result.contains("delivery") or lower_result.contains("box"):
		return "delivery_arrival"
	if lower_result.contains("placed") or lower_result.contains("stocked") or lower_result.contains("picked up"):
		return "item_settle"
	return "target_highlight"


func get_microfeedback_summary_text() -> String:
	var lines: Array[String] = ["Presentation microfeedback baseline:"]
	for effect in EFFECT_CATALOG:
		lines.append("%s (%s) - %s" % [
			str(effect.get("label", "")),
			str(effect.get("tone", "")),
			str(effect.get("summary", "")),
		])
	return "\n".join(lines)


func _get_effect(effect_id: String) -> Dictionary:
	for effect in EFFECT_CATALOG:
		if str(effect.get("id", "")) == effect_id:
			return effect
	return {}
