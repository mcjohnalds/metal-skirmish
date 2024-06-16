class_name Garage
extends Node3D

const armor_part_scene: PackedScene = preload("res://scenes/armor_part.tscn")
const wheel_part_scene: PackedScene = preload("res://scenes/wheel_part.tscn")
const gun_part_scene: PackedScene = preload("res://scenes/gun_part.tscn")
@onready var body: StaticBody3D = $StaticBody3D
@onready var parts: Node3D = $Parts
@onready var armor_part_button: PartButton = $MarginContainer/VBoxContainer/ArmorPartButton
@onready var wheel_part_button: PartButton = $MarginContainer/VBoxContainer/WheelPartButton
@onready var gun_part_button: PartButton = $MarginContainer/VBoxContainer/GunPartButton
@onready var block_face_indicator: Node3D = $BlockFaceIndicator
var selected_button: PartButton


func _ready() -> void:
	armor_part_button.button.button_down.connect(on_armor_button_down)
	wheel_part_button.button.button_down.connect(on_wheel_button_down)
	gun_part_button.button.button_down.connect(on_gun_button_down)
	on_armor_button_down()
	update_labels()


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
		var picked_part := parts.get_child(shape_index)
		if event.button_index == MOUSE_BUTTON_LEFT:
			var part_scene: PackedScene
			if selected_button == armor_part_button:
				part_scene = armor_part_scene
				if g.armor_part_inventory == 0:
					return
				g.armor_part_inventory -= 1
			elif selected_button == wheel_part_button:
				part_scene = wheel_part_scene
				if g.wheel_part_inventory == 0:
					return
				g.wheel_part_inventory -= 1
			elif selected_button == gun_part_button:
				part_scene = gun_part_scene
				if g.gun_part_inventory == 0:
					return
				g.gun_part_inventory -= 1
			var part := part_scene.instantiate()
			part.position = picked_part.position + collision.normal
			add_part(part)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not picked_part is CockpitPart:
				parts.remove_child(picked_part)
				body.remove_child(body.get_child(shape_index))
				if picked_part is ArmorPart:
					g.armor_part_inventory += 1
				if picked_part is WheelPart:
					g.wheel_part_inventory += 1
				if picked_part is GunPart:
					g.gun_part_inventory += 1
		update_labels()


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


func on_armor_button_down() -> void:
	armor_part_button.border.visible = true
	wheel_part_button.border.visible = false
	gun_part_button.border.visible = false
	selected_button = armor_part_button


func on_wheel_button_down() -> void:
	armor_part_button.border.visible = false
	wheel_part_button.border.visible = true
	gun_part_button.border.visible = false
	selected_button = wheel_part_button


func on_gun_button_down() -> void:
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