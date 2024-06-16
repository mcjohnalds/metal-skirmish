class_name Global
extends Node

const MAX_AIM_RANGE := 100
const FIRE_RATE := 10.0
const cockpit_part_scene: PackedScene = preload("res://scenes/cockpit_part.tscn")
const armor_part_scene: PackedScene = preload("res://scenes/armor_part.tscn")
const wheel_part_scene: PackedScene = preload("res://scenes/wheel_part.tscn")
const gun_part_scene: PackedScene = preload("res://scenes/gun_part.tscn")


var arena: Arena:
	get:
		return get_tree().get_first_node_in_group("arena")


var camera_pivot: CameraPivot:
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


static func vector_3_to_dictionary(v: Vector3) -> Dictionary:
	return { "x": v.x, "y": v.y, "z": v.z }


static func dictionary_to_vector_3(d: Dictionary) -> Vector3:
	return Vector3(d["x"], d["y"], d["z"])


static func parts_to_dictionary(parts: Array[Node3D]) -> Dictionary:
	var ps: Array[Dictionary] = []
	for p in parts:
		var d: Dictionary = { "position": p.position }
		if p is CockpitPart:
			d["type"] = "cockpit"
		elif p is ArmorPart:
			d["type"] = "armor"
		elif p is WheelPart:
			d["type"] = "wheel"
		elif p is GunPart:
			d["type"] = "gun"
		else:
			push_error("Impossible state")
		ps.append(d)
	return { "parts": ps }


static func dictionary_to_parts(dict: Dictionary) -> Array[Node3D]:
	var parts: Array[Node3D] = []
	for p: Dictionary in dict["parts"]:
		var scene: PackedScene
		match p["type"]:
			"cockpit":
				scene = cockpit_part_scene
			"armor":
				scene = armor_part_scene
			"wheel":
				scene = wheel_part_scene
			"gun":
				scene = gun_part_scene
			_:
				push_error("Impossible state")
		var part: Node3D = scene.instantiate()
		part.position = p["position"]
		parts.append(part)
	return parts


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
