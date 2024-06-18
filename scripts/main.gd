class_name Main
extends Node3D

const start_vehicle_scene := preload("res://scenes/vehicle_tinny_bopper.tscn")
@onready var arena_scene := preload("res://scenes/arena.tscn")
@onready var garage_scene := preload("res://scenes/garage.tscn")
@onready var start: Menu = $Start
@onready var settings: Menu = $Settings
@onready var level_container: Node3D = $LevelContainer
var level: Node
var transitioning := false
var paused := false
var mouse_mode_before_pausing: Input.MouseMode


func _ready() -> void:
	start.start_button.button_down.connect(on_start_button_down)
	start.resume_button.get_parent().visible = false
	start.quit_button.button_down.connect(on_quit_button_down)
	settings.start_button.get_parent().visible = false
	settings.resume_button.button_down.connect(on_resume_button_down)
	settings.quit_button.button_down.connect(on_quit_button_down)


func _unhandled_input(event: InputEvent) -> void:
	if level and event.is_action_pressed("ui_cancel"):
		if paused:
			unpause()
		else:
			pause()
	if OS.is_debug_build() and event.is_action_pressed("switch_scene") and level:
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
		if level is Arena:
			var arena: Arena = level
			if not is_instance_valid(arena.player):
				return
			await go_to_garage()
		else:
			await go_to_arena()
		transitioning = false


func go_to_arena() -> void:
	var player: Vehicle

	if level is Garage:
		var garage: Garage = level
		var in_parts: Array[Node3D] = []
		for p in garage.parts.get_children():
			in_parts.append(p)
		var dict := Global.parts_to_dictionary(in_parts)
		player = Vehicle.from_dictionary(dict)
		player.is_player = true
		garage.queue_free()
		await garage.tree_exited
	else:
		player = start_vehicle_scene.instantiate()
		player.is_player = true

	var arena: Arena = arena_scene.instantiate()
	arena.player = player
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	level_container.add_child(arena)
	arena.round_complete.connect(switch_scene)
	level = arena


func go_to_garage() -> void:
	var arena: Arena = level
	var dict := Global.parts_to_dictionary(arena.player.parts)

	arena.queue_free()
	await arena.tree_exited

	var garage: Garage = garage_scene.instantiate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	level_container.add_child(garage)
	for part in Global.dictionary_to_parts(dict):
		garage.add_part(part)
	g.camera_pivot.view_pitch = TAU / 8.0
	g.camera_pivot.view_yaw = 3.0 * TAU / 8.0
	garage.next_round.connect(switch_scene)
	level = garage


func on_quit_button_down() -> void:
	get_tree().quit()


func on_resume_button_down() -> void:
	unpause()


func pause() -> void:
	paused = true
	mouse_mode_before_pausing = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	level.process_mode = Node.PROCESS_MODE_DISABLED
	settings.visible = true


func unpause() -> void:
	paused = false
	Input.mouse_mode = mouse_mode_before_pausing
	settings.visible = false
	level.process_mode = Node.PROCESS_MODE_INHERIT
