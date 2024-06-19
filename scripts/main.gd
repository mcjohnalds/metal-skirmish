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
var desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var mouse_mode_mismatch_count := 0


func _ready() -> void:
	start.start_button.button_down.connect(on_start_button_down)
	start.resume_button.get_parent().visible = false
	start.restart_button.get_parent().visible = false
	start.quit_button.button_down.connect(on_quit_button_down)
	settings.start_button.get_parent().visible = false
	settings.resume_button.button_down.connect(on_resume_button_down)
	settings.quit_button.button_down.connect(on_quit_button_down)
	settings.restart_button.button_down.connect(restart)


func _process(_delta: float) -> void:
	# Deal with the bullshit that can happen when the browser takes away the
	# game's pointer lock
	if (
		desired_mouse_mode != Input.mouse_mode
		and desired_mouse_mode == Input.MOUSE_MODE_CAPTURED
	):
		mouse_mode_mismatch_count += 1
	else:
		mouse_mode_mismatch_count = 0
	if mouse_mode_mismatch_count > 10:
		pause()


func _unhandled_input(event: InputEvent) -> void:
	if level and event.is_action_pressed("ui_cancel"):
		if paused:
			# In a browser, we can only capture the mouse on a mouse click
			# event, so we only let the user unpause by clicking the resume
			# buttom
			if OS.get_name() != "Web":
				unpause()
		else:
			pause()
	if (
		OS.is_debug_build()
		and event.is_action_pressed("switch_scene")
		and level
	):
		g.armor_part_inventory = 50
		g.wheel_part_inventory = 50
		g.gun_part_inventory = 50
		if level is Arena:
			go_to_garage()
		else:
			go_to_arena()


func on_start_button_down() -> void:
	start.visible = false
	go_to_arena()


func go_to_arena() -> void:
	if transitioning:
		return
	transitioning = true

	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var player: Vehicle
	if level is Garage:
		var garage: Garage = level
		var in_parts: Array[Node3D] = []
		for p in garage.parts.get_children():
			in_parts.append(p)
		var dict := Global.parts_to_dictionary(in_parts)
		player = Vehicle.from_dictionary(dict)
		garage.queue_free()
		await garage.tree_exited
	elif level is Arena:
		var arena: Arena = level
		var dict := Global.parts_to_dictionary(arena.player.parts)
		player = Vehicle.from_dictionary(dict)
		arena.queue_free()
		await arena.tree_exited
	else:
		player = start_vehicle_scene.instantiate()
	player.is_player = true

	var new_arena: Arena = arena_scene.instantiate()
	new_arena.player = player
	level_container.add_child(new_arena)
	new_arena.round_complete.connect(on_round_complete)
	new_arena.round_lost.connect(restart)
	level = new_arena

	transitioning = false


func go_to_garage() -> void:
	if transitioning:
		return
	transitioning = true

	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var arena: Arena = level
	var dict := Global.parts_to_dictionary(arena.player.parts)

	arena.queue_free()
	await arena.tree_exited

	var garage: Garage = garage_scene.instantiate()
	level_container.add_child(garage)
	for part in Global.dictionary_to_parts(dict):
		garage.add_part(part)
	g.camera_pivot.view_pitch = TAU / 8.0
	g.camera_pivot.view_yaw = 3.0 * TAU / 8.0
	garage.next_round.connect(go_to_arena)
	level = garage

	transitioning = false


func on_quit_button_down() -> void:
	get_tree().quit()


func on_resume_button_down() -> void:
	unpause()


func pause() -> void:
	paused = true
	level.process_mode = Node.PROCESS_MODE_DISABLED
	settings.restart_button.get_parent().visible = level is Arena
	settings.visible = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func unpause() -> void:
	paused = false
	settings.visible = false
	level.process_mode = Node.PROCESS_MODE_INHERIT
	if level is Arena:
		set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func restart() -> void:
	if paused:
		unpause()
	if g.round_number == 1:
		go_to_arena()
	else:
		go_to_garage()


func on_round_complete() -> void:
	if g.round_number < Arena.rounds.size():
		g.round_number += 1
	go_to_garage()


func set_mouse_mode(mode: Input.MouseMode) -> void:
	desired_mouse_mode = mode
	Input.mouse_mode = mode
