class_name Arena
extends Node3D

signal round_complete

# Using load instead of preload to fix https://github.com/godotengine/godot/issues/79545
var vehicle_cow := load("res://scenes/vehicle_cow.tscn")
var vehicle_tinny_bopper := load("res://scenes/vehicle_tinny_bopper.tscn")
var vehicle_prick := load("res://scenes/vehicle_prick.tscn")
var vehicle_banger := load("res://scenes/vehicle_banger.tscn")
var vehicle_the_block := load("res://scenes/vehicle_the_block.tscn")

var rounds := [
	[
		{ "scene": vehicle_cow, "position": Vector3(0.0, 0.0, 0.0) },
	],
	[
		{ "scene": vehicle_tinny_bopper, "position": Vector3(0.0, 0.0, 0.0) },
	],
	# [
	# 	{ "scene": vehicle_prick, "position": Vector3(0.0, 0.0, 0.0) },
	# ],
	# [
	# 	{ "scene": vehicle_banger, "position": Vector3(0.0, 0.0, 0.0) },
	# ],
	# [
	# 	{ "scene": vehicle_the_block, "position": Vector3(0.0, 0.0, 0.0) },
	# 	{ "scene": vehicle_tinny_bopper, "position": Vector3(10.0, 0.0, -40.0) },
	# 	{ "scene": vehicle_tinny_bopper, "position": Vector3(-10.0, 0.0, -40.0) },
	# ],
]

@onready var player_spawn_point: Node3D = $PlayerSpawnPoint
@onready var enemy_spawn_point: Node3D = $EnemySpawnPoint
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var round_counter: RoundCounter = $MarginContainer/RoundCounter
@onready var round_complete_control: Control = $RoundCompleteControl
@onready var round_complete_label: Label = $RoundCompleteControl/MarginContainer/Label
@onready var ground: Ground = $Ground
@onready var crosshair: Control = $Crosshair
@onready var game_over_control: Control = $GameOverControl
@onready var restart_button: Button = $GameOverControl/NextRoundButton/Button
var player: Vehicle


func _ready() -> void:
	var min_y := 0.0
	for c in player.get_children():
		min_y = minf(min_y, c.position.y)
	player.position = player_spawn_point.position - Vector3.UP * min_y
	add_child(player)

	var enemies: Array = rounds[g.round_number - 1]
	for enemy: Dictionary in enemies:
		var scene = enemy["scene"]
		var pos: Vector3 = enemy["position"]
		var vehicle: Vehicle = scene.instantiate()
		vehicle.position = enemy_spawn_point.position + pos
		vehicle.rotation = enemy_spawn_point.rotation
		add_child(vehicle)

	round_counter.label.text = "Round %s" % g.round_number
	for vehicle: Vehicle in get_tree().get_nodes_in_group("vehicles"):
		vehicle.destroyed.connect(on_vehicle_destroyed)
	restart_button.button_down.connect(on_restart_button_down)


func _process(_delta: float) -> void:
	g.arena.aim_debug_sphere.global_position = g.camera_pivot.aim.get_collision_point()


func on_vehicle_destroyed(is_player: bool) -> void:
	if is_player:
		game_over_control.visible = true
		crosshair.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		g.camera_pivot.process_mode = Node.PROCESS_MODE_DISABLED
		return
	if get_tree().get_nodes_in_group("vehicles").size() == 2:
		round_complete_control.visible = true
		await get_tree().create_timer(3.0).timeout
		if g.round_number == rounds.size():
			round_complete_label.text = "Game Won - Thanks For Playing"
		else:
			g.round_number += 1
			round_complete.emit()


func on_restart_button_down() -> void:
	get_tree().reload_current_scene()
