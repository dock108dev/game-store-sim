## Originality and pattern-reference closeout metadata for visual-slice review.
class_name InspirationCloseoutContract
extends RefCounted

const ORIGINALITY_COMMANDS: Array[String] = [
	"bash scripts/validate_originality.sh",
	"bash tests/validate_original_content.sh",
]
const ORIGINALITY_REQUIRED_CHANGE_TYPES: Array[String] = [
	"visual_art",
	"store_name",
	"product_label",
	"poster_text",
	"sign_text",
	"ui_label",
]
const _SOURCE_POLICY: Dictionary = {
	"allowed_use": "pattern_reference_only",
	"forbidden_use": [
		"import",
		"trace",
		"paint_over",
		"clone_logo",
		"copy_ui",
		"duplicate_proprietary_product_store_or_character_design",
	],
	"text_policy": "new visual copy must be original Mallcore text or already present in repo content",
}
const _CLUSTERS: Dictionary = {
	"storefront_and_mall_identity": {
		"label": "Storefront and mall identity",
		"reference_files": [
			"IMG_1033.PNG",
			"IMG_1034.PNG",
			"IMG_1035.PNG",
			"IMG_1037.PNG",
			"IMG_1038.PNG",
			"IMG_1048.PNG",
		],
		"pattern": "threshold readability, shop sign, glass frontage, mall context",
	},
	"store_construction_and_expansion": {
		"label": "Store construction and expansion",
		"reference_files": [
			"IMG_1040.PNG",
			"IMG_1041.PNG",
			"IMG_1042.PNG",
			"IMG_1043.PNG",
			"IMG_1044.PNG",
			"IMG_1045.PNG",
			"IMG_1046.PNG",
			"IMG_1047.PNG",
			"IMG_1050.PNG",
			"IMG_1051.PNG",
		],
		"pattern": "fixture capacity, upgrade rhythm, valid placement language",
	},
	"shelf_economics_and_product_readability": {
		"label": "Shelf economics and product readability",
		"reference_files": [],
		"pattern": "dense stock, readable gaps, category zones, price tags, value tells",
	},
	"checkout_and_transaction_work": {
		"label": "Checkout and transaction work",
		"reference_files": [],
		"pattern": "counter as work surface, handoff space, register state, receipt state",
	},
	"customers_and_queue": {
		"label": "Customers and queue",
		"reference_files": [],
		"pattern": "stateful browsing, held items, queue lane, employee cues",
	},
	"ui_and_sim_feedback": {
		"label": "UI and sim feedback",
		"reference_files": [],
		"pattern": "compact practical panels that support local decisions without obstruction",
	},
}


## Returns the source-use rules attached to every visual closeout artifact.
static func source_policy() -> Dictionary:
	return _SOURCE_POLICY.duplicate(true)


## Returns the originality commands required for visual-art closeout.
static func required_originality_commands() -> Array[String]:
	return ORIGINALITY_COMMANDS.duplicate()


## Returns change types that require explicit originality validation.
static func originality_required_change_types() -> Array[String]:
	return ORIGINALITY_REQUIRED_CHANGE_TYPES.duplicate()


## Returns the pattern-reference cluster catalog serialized in review manifests.
static func cluster_catalog() -> Array[Dictionary]:
	var catalog: Array[Dictionary] = []
	for cluster_id: String in _CLUSTERS.keys():
		var cluster: Dictionary = (_CLUSTERS[cluster_id] as Dictionary).duplicate(true)
		cluster["id"] = cluster_id
		catalog.append(cluster)
	catalog.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["id"]) < str(b["id"]))
	return catalog


## Returns one closeout record for a visual sweep beat or capture.
static func closeout_for(
	cluster_ids: Array[String],
	mallcore_original_adaptation: String,
	intended_pattern_validation: String
) -> Dictionary:
	var clusters: Array[Dictionary] = []
	for cluster_id: String in cluster_ids:
		var cluster: Dictionary = _cluster_for_id(cluster_id)
		if not cluster.is_empty():
			clusters.append(cluster)
	return {
		"reference_clusters": clusters,
		"mallcore_original_adaptation": mallcore_original_adaptation,
		"intended_pattern_validation": intended_pattern_validation,
		"source_policy": source_policy(),
		"required_originality_commands": required_originality_commands(),
	}


static func _cluster_for_id(cluster_id: String) -> Dictionary:
	if not _CLUSTERS.has(cluster_id):
		return {}
	var cluster: Dictionary = (_CLUSTERS[cluster_id] as Dictionary).duplicate(true)
	cluster["id"] = cluster_id
	return cluster
