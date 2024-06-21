class_name Garage
extends Node3D

signal next_round

static var armor_part_scene: PackedScene = load("res://scenes/armor_part.tscn")
static var wheel_part_scene: PackedScene = load("res://scenes/wheel_part.tscn")
static var gun_part_scene: PackedScene = load("res://scenes/gun_part.tscn")
@onready var body: StaticBody3D = $StaticBody3D
@onready var parts: Node3D = $Parts
@onready var armor_part_button: PartButton = (
	$MarginContainer/VBoxContainer/ArmorPartButton
)
@onready var wheel_part_button: PartButton = (
	$MarginContainer/VBoxContainer/WheelPartButton
)
@onready var gun_part_button: PartButton = (
	$MarginContainer/VBoxContainer/GunPartButton
)
@onready var block_face_indicator: Node3D = $BlockFaceIndicator
@onready var round_counter: RoundCounter = $MarginContainer/RoundCounter
@onready var next_round_button: Button = $MarginContainer/NextRoundButton/Button
@onready var part_placed_asp: AudioStreamPlayer = $PartPlacedASP
@onready var part_removed_asp: AudioStreamPlayer = $PartRemovedASP
var selected_button: PartButton


func _ready() -> void:
	armor_part_button.button.button_down.connect(on_armor_button_down)
	wheel_part_button.button.button_down.connect(on_wheel_button_down)
	gun_part_button.button.button_down.connect(on_gun_button_down)
	next_round_button.button_down.connect(on_next_round_button_down)
	on_armor_button_down(true)
	update_labels()
	round_counter.label.text = (
		"Round %s/%s" % [g.round_number, Arena.rounds.size()]
	)


func _process(_delta: float) -> void:
	var collision := get_mouse_ray_collision()
	if collision:
		var i: int = collision.shape
		var part: Node3D = parts.get_child(i)
		var normal: Vector3 = collision.normal
		block_face_indicator.position = part.position + normal / 2.0
		var target := block_face_indicator.position + normal
		Global.safe_look_at(block_face_indicator, target)
		block_face_indicator.visible = true
	else:
		block_face_indicator.visible = false


func _input(event):
	if event is InputEventKey:
		var key: InputEventKey = event
		if not key.pressed:
			return
		if key.keycode == KEY_1:
			on_armor_button_down()
		elif event.keycode == KEY_2:
			on_wheel_button_down()
		elif event.keycode == KEY_3:
			on_gun_button_down()
	if event is InputEventMouseButton and event.pressed:
		var collision := get_mouse_ray_collision()
		if not collision:
			return
		var shape_index: int = collision.shape
		var picked_part: Node3D = parts.get_child(shape_index)
		if event.button_index == MOUSE_BUTTON_LEFT:
			var part_scene: PackedScene
			if selected_button == armor_part_button:
				part_scene = armor_part_scene
				if g.armor_part_inventory == 0:
					return
			elif selected_button == wheel_part_button:
				part_scene = wheel_part_scene
				if g.wheel_part_inventory == 0:
					return
			elif selected_button == gun_part_button:
				part_scene = gun_part_scene
				if g.gun_part_inventory == 0:
					return

			# TODO: this validation logic is exploitable, need to do a proper
			# solution where i have a is_vehicle_valid(parts) -> bool function
			if picked_part is GunPart:
				return

			var normal: Vector3 = collision.normal

			var normali = Global.vector_3_roundi(collision.normal)
			if (
				selected_button == gun_part_button and normali != Vector3i.UP
			):
				return

			var new_part_position := picked_part.position + normal
			if Garage.get_part_at_position(new_part_position, parts.get_children()):
				return
			var new_part := part_scene.instantiate()
			new_part.position = new_part_position
			new_part.position = Global.vector_3_floorf(new_part.position)
			add_part(new_part)

			part_placed_asp.play()

			if selected_button == armor_part_button:
				g.armor_part_inventory -= 1
			elif selected_button == wheel_part_button:
				g.wheel_part_inventory -= 1
			elif selected_button == gun_part_button:
				g.gun_part_inventory -= 1
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if picked_part is CockpitPart or is_part_bridge(picked_part):
				return
			parts.remove_child(picked_part)
			body.remove_child(body.get_child(shape_index))

			part_removed_asp.play()

			if picked_part is ArmorPart:
				g.armor_part_inventory += 1
			if picked_part is WheelPart:
				g.wheel_part_inventory += 1
			if picked_part is GunPart:
				g.gun_part_inventory += 1
		update_labels()
	if event.is_action_pressed("recenter"):
		var collision := get_mouse_ray_collision()
		if collision:
			var shape_index: int = collision.shape
			var picked_part: Node3D = parts.get_child(shape_index)
			g.camera_pivot.position = picked_part.position


func get_mouse_ray_collision() -> Dictionary:
	var mouse_position := get_viewport().get_mouse_position()
	var from := g.camera_pivot.camera.project_ray_origin(mouse_position)
	var ray_normal := g.camera_pivot.camera.project_ray_normal(mouse_position)
	var to := from + ray_normal * 1000.0

	var query := PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = g.camera_pivot.aim.collision_mask
	return get_world_3d().direct_space_state.intersect_ray(query)


func on_armor_button_down(mute_sound := false) -> void:
	if not mute_sound:
		autoload.play_button_click_sound()
	armor_part_button.border.visible = true
	wheel_part_button.border.visible = false
	gun_part_button.border.visible = false
	selected_button = armor_part_button


func on_wheel_button_down() -> void:
	autoload.play_button_click_sound()
	armor_part_button.border.visible = false
	wheel_part_button.border.visible = true
	gun_part_button.border.visible = false
	selected_button = wheel_part_button


func on_gun_button_down() -> void:
	autoload.play_button_click_sound()
	armor_part_button.border.visible = false
	wheel_part_button.border.visible = false
	gun_part_button.border.visible = true
	selected_button = gun_part_button


func add_part(part: Node3D) -> void:
	var shape := CollisionShape3D.new()
	shape.position = part.position
	shape.shape = BoxShape3D.new()
	body.add_child(shape)
	parts.add_child(part)


func update_labels() -> void:
	armor_part_button.label.text = str(g.armor_part_inventory)
	wheel_part_button.label.text = str(g.wheel_part_inventory)
	gun_part_button.label.text = str(g.gun_part_inventory)


func is_part_bridge(part: Node3D) -> bool:
	var arr: Array[Node3D] = []
	for p in parts.get_children():
		if p != part:
			arr.append(p)
	return not Garage.is_parts_connected(arr)


static func is_parts_connected(arr: Array) -> bool:
	var directions: Array[Vector3] = [
		Vector3.LEFT,
		Vector3.RIGHT,
		Vector3.FORWARD,
		Vector3.BACK,
		Vector3.UP,
		Vector3.DOWN
	]
	var pairs: Array = []
	for p1 in arr:
		pairs.append([p1, p1])
		for d in directions:
			var p2 := Garage.get_part_at_position(p1.position + d, arr)
			if p2:
				pairs.append([p1, p2])
	return Global.is_graph_connected(pairs)


static func get_part_at_position(point: Vector3, arr: Array) -> Node3D:
	for part in arr:
		var p1 := Global.vector_3_roundi(part.position)
		var p2 := Global.vector_3_roundi(point)
		if p1 == p2:
			return part
	return null


func on_next_round_button_down() -> void:
	next_round.emit()
