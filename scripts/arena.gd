class_name Arena
extends Node3D

signal round_complete

@onready var player_spawn_point: Node3D = $PlayerSpawnPoint
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var round_counter: RoundCounter = $MarginContainer/RoundCounter
@onready var round_complete_control: Control = $RoundCompleteControl
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
		g.round_number += 1
		round_complete_control.visible = true
		await get_tree().create_timer(3.0).timeout
		round_complete.emit()


func on_restart_button_down() -> void:
	get_tree().reload_current_scene()
