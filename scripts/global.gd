class_name Global
extends Node

signal graphics_preset_changed

enum PhysicsLayer {
	VEHICLE = 1 << 0,
	GROUND = 1 << 1,
	GIBLET = 1 << 2,
	WALL = 1 << 2,
}

enum GraphicsPreset { LOW, MEDIUM, HIGH, INSANE }

const MAX_AIM_RANGE := 70
const FIRE_RATE := 10.0
const DEFAULT_PHYSICS_TICKS_PER_SECOND = 60.0
const DEFAULT_MAX_PHYSICS_STEPS_PER_FRAME = 8.0
static var cockpit_part_scene: PackedScene = load("res://scenes/cockpit_part.tscn")
static var armor_part_scene: PackedScene = load("res://scenes/armor_part.tscn")
static var wheel_part_scene: PackedScene = load("res://scenes/wheel_part.tscn")
static var gun_part_scene: PackedScene = load("res://scenes/gun_part.tscn")
static var environment: Environment = load("res://misc/environment.tres")
var armor_part_inventory: int
var wheel_part_inventory: int
var gun_part_inventory: int
var round_number: int
var mouse_sensitivity := 0.25
var invert_mouse := false


var graphics_preset := GraphicsPreset.MEDIUM:
	set(value):
		graphics_preset = value
		graphics_preset_changed.emit()
		match graphics_preset:
			GraphicsPreset.LOW:
				Engine.physics_ticks_per_second = int(DEFAULT_PHYSICS_TICKS_PER_SECOND)
				Engine.max_physics_steps_per_frame = int(DEFAULT_MAX_PHYSICS_STEPS_PER_FRAME)
				get_viewport().scaling_3d_scale = 0.5
				get_viewport().msaa_3d = Viewport.MSAA_DISABLED
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
				# environment.fog_enabled = false
				# environment.volumetric_fog_enabled = false
				environment.glow_enabled = false
				environment.ssr_enabled = false
				environment.ssao_enabled = false
				environment.ssil_enabled = false
				environment.sdfgi_enabled = false
			GraphicsPreset.MEDIUM:
				Engine.physics_ticks_per_second = int(DEFAULT_PHYSICS_TICKS_PER_SECOND)
				Engine.max_physics_steps_per_frame = int(DEFAULT_MAX_PHYSICS_STEPS_PER_FRAME)
				get_viewport().scaling_3d_scale = 0.5
				get_viewport().msaa_3d = Viewport.MSAA_2X
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
				# environment.fog_enabled = true
				# environment.volumetric_fog_enabled = false
				environment.glow_enabled = true
				environment.ssr_enabled = false
				environment.ssao_enabled = false
				environment.ssil_enabled = false
				environment.sdfgi_enabled = false
			GraphicsPreset.HIGH:
				Engine.physics_ticks_per_second = int(DEFAULT_PHYSICS_TICKS_PER_SECOND)
				Engine.max_physics_steps_per_frame = int(DEFAULT_MAX_PHYSICS_STEPS_PER_FRAME)
				get_viewport().scaling_3d_scale = 1.0
				get_viewport().msaa_3d = Viewport.MSAA_2X
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
				# environment.fog_enabled = true
				# environment.volumetric_fog_enabled = false
				environment.glow_enabled = true
				environment.ssr_enabled = false
				environment.ssao_enabled = true
				environment.ssil_enabled = false
				environment.sdfgi_enabled = false
			GraphicsPreset.INSANE:
				Engine.physics_ticks_per_second = int(DEFAULT_PHYSICS_TICKS_PER_SECOND * 2.0)
				Engine.max_physics_steps_per_frame = int(DEFAULT_MAX_PHYSICS_STEPS_PER_FRAME * 2.0)
				get_viewport().scaling_3d_scale = 1.0
				get_viewport().msaa_3d = Viewport.MSAA_4X
				get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
				# environment.fog_enabled = true
				# environment.volumetric_fog_enabled = true
				environment.glow_enabled = true
				environment.ssr_enabled = true
				environment.ssao_enabled = true
				environment.ssil_enabled = true
				environment.sdfgi_enabled = true


var arena: Arena:
	get:
		return get_tree().get_first_node_in_group("arena")


var camera_pivot: CameraPivot:
	get:
		return get_tree().get_first_node_in_group("camera pivot")


func _init() -> void:
	reset_progress()


func _ready() -> void:
	g.graphics_preset = g.graphics_preset
	# Disables mouse acceleration on Mac
	Input.use_accumulated_input = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()


func reset_progress() -> void:
	armor_part_inventory = 0
	wheel_part_inventory = 0
	gun_part_inventory = 0
	round_number = 1


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


static func vector_3_floorf(v: Vector3) -> Vector3:
	return Vector3(floorf(v.x), floorf(v.y), floorf(v.z))


static func vector_3_roundi(v: Vector3) -> Vector3i:
	return Vector3i(roundi(v.x), roundi(v.y), roundi(v.z))


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


static func is_graph_connected(pairs: Array) -> bool:
	if pairs.size() == 0:
		return true

	var graph = {}
	for pair in pairs:
		var a = pair[0]
		var b = pair[1]
		if not graph.has(a):
			graph[a] = []
		if not graph.has(b):
			graph[b] = []
		graph[a].append(b)
		graph[b].append(a)

	var visited = {}
	var nodes = graph.keys()
	var stack = [nodes[0]]
	visited[nodes[0]] = true

	while stack.size() > 0:
		var node = stack.pop_back()
		for neighbor in graph[node]:
			if not visited.has(neighbor):
				visited[neighbor] = true
				stack.append(neighbor)

	return visited.size() == nodes.size()


static func is_compatibility_renderer() -> bool:
	var rendering_method: String = (
		ProjectSettings["rendering/renderer/rendering_method"]
	)
	return rendering_method == "gl_compatibility"


static func direction_to_rotation(direction: Vector3) -> Vector3:
	var forward = Vector3(0, 0, -1)
	var dot = forward.dot(direction)
	var cross = forward.cross(direction).normalized()
	var angle = acos(dot)

	if angle == 0:
		return Vector3(0, 0, 0)

	var q = Quaternion(cross, angle)
	var rot = q.get_euler()
	return rot


static func get_all_children(
	node: Node, include_internal := false
) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(include_internal):
		nodes.append(child)
		if child.get_child_count(include_internal) > 0:
			nodes.append_array(get_all_children(child, include_internal))
	return nodes
