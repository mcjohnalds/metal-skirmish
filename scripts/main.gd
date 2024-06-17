class_name Main
extends Node3D

const start_scene := preload("res://scenes/start.tscn")
const start_vehicle_scene := preload("res://scenes/vehicle_tinny_bopper.tscn")
@onready var arena_scene := preload("res://scenes/arena.tscn")
@onready var garage_scene := preload("res://scenes/garage.tscn")
@onready var start: Start = $Start
var arena: Arena
var garage: Garage
var transitioning := false


func _ready() -> void:
	start.button.button_down.connect(on_start_button_down)


func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed("switch_scene"):
		g.armor_part_inventory = 50
		g.wheel_part_inventory = 50
		g.gun_part_inventory = 50
		switch_scene()


func on_start_button_down() -> void:
	start.queue_free()
	await start.tree_exited
	go_to_arena()


func switch_scene() -> void:
		if transitioning:
			return
		transitioning = true
		if arena:
			if not is_instance_valid(arena.player):
				return
			await go_to_garage()
		else:
			await go_to_arena()
		transitioning = false


func go_to_arena() -> void:
	var player: Vehicle

	if garage:
		var in_parts: Array[Node3D] = []
		for p in garage.parts.get_children():
			in_parts.append(p)
		var dict := Global.parts_to_dictionary(in_parts)
		player = Vehicle.from_dictionary(dict)
		player.is_player = true
		garage.queue_free()
		await garage.tree_exited
		garage = null
	else:
		player = start_vehicle_scene.instantiate()
		player.is_player = true

	arena = arena_scene.instantiate()
	arena.player = player
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_child(arena)
	arena.round_complete.connect(switch_scene)


func go_to_garage() -> void:
	var dict := Global.parts_to_dictionary(arena.player.parts)

	arena.queue_free()
	await arena.tree_exited
	arena = null

	garage = garage_scene.instantiate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	add_child(garage)
	for part in Global.dictionary_to_parts(dict):
		garage.add_part(part)
	g.camera_pivot.view_pitch = TAU / 8.0
	g.camera_pivot.view_yaw = 3.0 * TAU / 8.0
	garage.next_round.connect(switch_scene)
