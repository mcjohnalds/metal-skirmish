class_name Main
extends Node3D

const vehicle_small_scene := preload("res://scenes/vehicle_small.tscn")
@onready var arena_scene := preload("res://scenes/arena.tscn")
@onready var garage_scene := preload("res://scenes/garage.tscn")
var arena: Arena
var garage: Garage
var transitioning := false


func _ready() -> void:
	go_to_arena()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_scene"):
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
		garage.queue_free()
		await garage.tree_exited
		garage = null
	else:
		player = vehicle_small_scene.instantiate()

	arena = arena_scene.instantiate()
	arena.player = player
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_child(arena)


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
