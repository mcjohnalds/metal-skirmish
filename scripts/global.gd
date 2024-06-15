class_name Global
extends Node

const MAX_AIM_RANGE := 100
const FIRE_RATE := 10.0


var level: Level:
	get:
		return get_tree().get_first_node_in_group("level")


var camera_pivot: Node3D:
	get:
		return get_tree().get_first_node_in_group("camera pivot")


static func safe_look_at(node: Node3D, target: Vector3, use_model_front: bool = false) -> void:
	var p : Vector3 = node.global_transform.origin
	if p.is_equal_approx(target):
		return
	var v := p.direction_to(target)
	var ws := [Vector3.UP, Vector3.FORWARD, Vector3.LEFT]
	for w: Vector3 in ws:
		var is_parallel := is_equal_approx(absf(v.dot(w)), 1.0)
		if not w.cross(target - p).is_zero_approx() and not is_parallel:
			node.look_at(target, w, use_model_front)


# Point is global
static func get_point_velocity(body: RigidBody3D, point: Vector3) -> Vector3:
	return body.linear_velocity + body.angular_velocity.cross(point - body.global_transform.origin)


static func get_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func get_vector3_xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)
