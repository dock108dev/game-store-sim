## Per-store node that exposes customer navigation waypoints as Marker3D children.
class_name CustomerNavConfig
extends Node

const STOCK_CLOSET_MIN_X: float = 3.10
const STOCK_CLOSET_MAX_X: float = 5.95
const STOCK_CLOSET_MIN_Z: float = -9.95
const STOCK_CLOSET_MAX_Z: float = -5.75
const DEFAULT_CUSTOMER_SAFE_POSITION: Vector3 = Vector3(0.0, 0.05, 9.15)

@export var entry_point: Marker3D
@export var browse_waypoints: Array[Marker3D] = []
@export var checkout_approach: Marker3D
@export var exit_point: Marker3D
@export var max_concurrent_customers: int = 4


func _ready() -> void:
	if entry_point == null:
		entry_point = get_node_or_null("EntryPoint") as Marker3D
	if browse_waypoints.is_empty():
		for child_name: String in [
			"BrowseWaypoint01",
			"BrowseWaypoint02",
			"BrowseWaypoint03",
			"BrowseWaypoint04",
		]:
			var waypoint: Marker3D = get_node_or_null(child_name) as Marker3D
			if waypoint:
				browse_waypoints.append(waypoint)
	if checkout_approach == null:
		checkout_approach = get_node_or_null("CheckoutApproach") as Marker3D
	if exit_point == null:
		exit_point = get_node_or_null("ExitPoint") as Marker3D


func get_entry_position() -> Vector3:
	if not entry_point:
		push_warning("CustomerNavConfig: entry_point not assigned")
		return Vector3.ZERO
	return sanitize_customer_target(entry_point.global_position)


func get_browse_positions() -> Array[Vector3]:
	var positions: Array[Vector3] = []
	for marker: Marker3D in browse_waypoints:
		if marker == null:
			continue
		if not is_customer_position_allowed(marker.global_position):
			push_warning(
				"CustomerNavConfig: ignoring staff-only browse waypoint %s"
				% marker.name
			)
			continue
		positions.append(marker.global_position)
	return positions


func get_checkout_position() -> Vector3:
	if not checkout_approach:
		push_warning("CustomerNavConfig: checkout_approach not assigned")
		return Vector3.ZERO
	return sanitize_customer_target(checkout_approach.global_position)


func get_exit_position() -> Vector3:
	if not exit_point:
		push_warning("CustomerNavConfig: exit_point not assigned")
		return Vector3.ZERO
	return sanitize_customer_target(exit_point.global_position)


## Returns all direct Marker3D children that can become customer route targets.
func get_customer_waypoint_markers() -> Array[Marker3D]:
	var markers: Array[Marker3D] = []
	for child: Node in get_children():
		var marker: Marker3D = child as Marker3D
		if marker != null:
			markers.append(marker)
	return markers


## Returns true when the position is inside the staff-only stockroom.
static func is_position_in_staff_only_zone(position: Vector3) -> bool:
	return (
		position.x >= STOCK_CLOSET_MIN_X
		and position.x <= STOCK_CLOSET_MAX_X
		and position.z >= STOCK_CLOSET_MIN_Z
		and position.z <= STOCK_CLOSET_MAX_Z
	)


## Returns true when customer/NPC routing may intentionally target the position.
static func is_customer_position_allowed(position: Vector3) -> bool:
	return not is_position_in_staff_only_zone(position)


## Replaces staff-only customer targets with a safe storefront-side target.
static func sanitize_customer_target(
	position: Vector3,
	fallback_position: Vector3 = DEFAULT_CUSTOMER_SAFE_POSITION,
) -> Vector3:
	if is_customer_position_allowed(position):
		return position
	if is_customer_position_allowed(fallback_position):
		return fallback_position
	return DEFAULT_CUSTOMER_SAFE_POSITION
