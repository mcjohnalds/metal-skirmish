class_name Arena
extends Node3D

signal round_complete

# Using load instead of preload to fix https://github.com/godotengine/godot/issues/79545
var vehicle_tinny_bopper := load("res://scenes/vehicle_tinny_bopper.tscn")
var vehicle_tall_boy := load("res://scenes/vehicle_tall_boy.tscn")
var vehicle_broadside := load("res://scenes/vehicle_broadside.tscn")
var vehicle_prick := load("res://scenes/vehicle_prick.tscn")
var vehicle_banger := load("res://scenes/vehicle_banger.tscn")
var vehicle_the_block := load("res://scenes/vehicle_the_block.tscn")
var vehicle_train := load("res://scenes/vehicle_train.tscn")

var rounds := [
	{
		"enemies": [
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 2,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_prick,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_banger,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 2,
	},
	{
		"enemies": [
			{
				"scene": vehicle_broadside,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 2,
	},
	{
		"enemies": [
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, 0.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, 0.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, -700.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, -700.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(400.0, 0.0, 100.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(400.0, 0.0, -100.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-400.0, 0.0, 100.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-400.0, 0.0, -100.0)
			},
		],
		"armor_parts_earned": 2,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_train,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 2,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_tall_boy,
				"position": Vector3(100.0, 0.0, 0.0)
			},
			{
				"scene": vehicle_tall_boy,
				"position": Vector3(-100.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 2,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_the_block,
				"position": Vector3(0.0, 0.0, 0.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(30.0, 0.0, 150.0)
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-30.0, 0.0, 150.0)
			},
		],
		"armor_parts_earned": 0,
		"wheel_parts_earned": 0,
		"gun_parts_earned": 0,
	},
	{
		"enemies": [
			{
				"scene": vehicle_train,
				"position": Vector3(0.0, 0.0, 0.0)
			},
		],
		"armor_parts_earned": 2,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
]

@onready var player_spawn_point: Node3D = $PlayerSpawnPoint
@onready var enemy_spawn_point: Node3D = $EnemySpawnPoint
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var round_counter: RoundCounter = $MarginContainer/RoundCounter
@onready var round_complete_control: Control = $RoundCompleteControl
@onready var round_complete_label: Label = $RoundCompleteControl/MarginContainer/Label
@onready var parts_earned_text: Control = $PartsEarnedText
@onready var parts_earned_buttons: Control = $PartsEarnedButtons
@onready var armor_part_button: PartButton = $PartsEarnedButtons/HBoxContainer/ArmorPartButton
@onready var wheel_part_button: PartButton = $PartsEarnedButtons/HBoxContainer/WheelPartButton
@onready var gun_part_button: PartButton = $PartsEarnedButtons/HBoxContainer/GunPartButton
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

	var round_data: Dictionary = rounds[g.round_number - 1]
	var enemies: Array = round_data.enemies
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
		if g.round_number == rounds.size():
			round_complete_label.text = "Game Won - Thanks For Playing"
		else:
			await get_tree().create_timer(2.0).timeout
			parts_earned_text.visible = true
			parts_earned_buttons.visible = true
			var round_data: Dictionary = rounds[g.round_number - 1]
			var armor_parts_earned: int = round_data["armor_parts_earned"]
			var wheel_parts_earned: int = round_data["wheel_parts_earned"]
			var gun_parts_earned: int = round_data["gun_parts_earned"]
			armor_part_button.label.text = str(armor_parts_earned)
			wheel_part_button.label.text = str(wheel_parts_earned)
			gun_part_button.label.text = str(gun_parts_earned)
			await get_tree().create_timer(5.0).timeout
			g.armor_part_inventory += armor_parts_earned
			g.wheel_part_inventory += wheel_parts_earned
			g.gun_part_inventory += gun_parts_earned
			g.round_number += 1
			round_complete.emit()


func on_restart_button_down() -> void:
	g.reset_progress()
	get_tree().reload_current_scene()
