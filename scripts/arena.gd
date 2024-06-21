class_name Arena
extends Node3D

signal round_complete
signal round_lost

const round_won_stream: AudioStream = preload("res://sounds/round_won.ogg")
const round_lost_stream: AudioStream = preload("res://sounds/round_lost.ogg")
const parts_earned_stream: AudioStream = preload("res://sounds/parts_earned.ogg")

# Using load instead of preload to fix https://github.com/godotengine/godot/issues/79545
static var vehicle_tinny_bopper := load("res://scenes/vehicle_tinny_bopper.tscn")
static var vehicle_tall_boy := load("res://scenes/vehicle_tall_boy.tscn")
static var vehicle_broadside := load("res://scenes/vehicle_broadside.tscn")
static var vehicle_prick := load("res://scenes/vehicle_prick.tscn")
static var vehicle_banger := load("res://scenes/vehicle_banger.tscn")
static var vehicle_the_block := load("res://scenes/vehicle_the_block.tscn")
static var vehicle_train := load("res://scenes/vehicle_train.tscn")

static var rounds := [
	# {
	# 	"enemies": [],
	# 	"armor_parts_earned": 2,
	# 	"wheel_parts_earned": 1,
	# 	"gun_parts_earned": 1,
	# },
	{
		"enemies": [
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 0.2,
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
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
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
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_broadside,
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, -300.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, -300.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, 100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, -100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, 100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-100.0, 0.0, -100.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_the_block,
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(30.0, 0.0, 150.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(-30.0, 0.0, 150.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_tall_boy,
				"position": Vector3(100.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tall_boy,
				"position": Vector3(-100.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 3,
		"wheel_parts_earned": 1,
		"gun_parts_earned": 1,
	},
	{
		"enemies": [
			{
				"scene": vehicle_train,
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 6,
		"wheel_parts_earned": 6,
		"gun_parts_earned": 4,
	},
	{
		"enemies": [
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(0.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(100.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tinny_bopper,
				"position": Vector3(200.0, 0.0, 0.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_prick,
				"position": Vector3(0.0, 0.0, 100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_banger,
				"position": Vector3(100.0, 0.0, 100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_broadside,
				"position": Vector3(200.0, 0.0, 100.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_tall_boy,
				"position": Vector3(0.0, 0.0, 200.0),
				"accuracy": 1.0,
			},
			{
				"scene": vehicle_train,
				"position": Vector3(100.0, 0.0, 200.0),
				"accuracy": 1.0,
			},
		],
		"armor_parts_earned": 50,
		"wheel_parts_earned": 50,
		"gun_parts_earned": 50,
	},
]

@onready var player_spawn_point: Node3D = $PlayerSpawnPoint
@onready var enemy_spawn_point: Node3D = $EnemySpawnPoint
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var round_counter: RoundCounter = $MarginContainer/RoundCounter
@onready var round_complete_control: Control = $RoundCompleteControl
@onready var round_complete_label: Label = $RoundCompleteControl/MarginContainer/Label
@onready var parts_earned: Control = $PartsEarned
@onready var armor_part_button: PartButton = %ArmorPartButton
@onready var wheel_part_button: PartButton = %WheelPartButton
@onready var gun_part_button: PartButton = %GunPartButton
@onready var ground: Ground = $Ground
@onready var crosshair: Control = $Crosshair
@onready var death_tip: Control = $DeathTip
@onready var engine_ignition_asp: AudioStreamPlayer = $EngineIgnitionASP
var player: Vehicle


func _ready() -> void:
	engine_ignition_asp.play()

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
		var accuracy: float = enemy["accuracy"]
		var vehicle: Vehicle = scene.instantiate()
		vehicle.accuracy = accuracy

		vehicle.position = enemy_spawn_point.position + pos

		# Face player
		var p1 := Global.get_vector3_xz(vehicle.position) 
		var p2 := Global.get_vector3_xz(player_spawn_point.position)
		vehicle.rotation.y = p1.angle_to_point(p2) - TAU / 4.0

		add_child(vehicle)

	round_counter.label.text = (
		"Round %s/%s" % [g.round_number, Arena.rounds.size()]
	)
	for vehicle: Vehicle in get_tree().get_nodes_in_group("vehicles"):
		vehicle.destroyed.connect(on_vehicle_destroyed)


func _process(_delta: float) -> void:
	g.arena.aim_debug_sphere.global_position = g.camera_pivot.aim.get_collision_point()


func on_vehicle_destroyed(is_player: bool) -> void:
	if is_player:
		await get_tree().create_timer(1.2).timeout
		play_round_lost_sound()
		round_complete_control.visible = true
		round_complete_label.text = "Round Lost"
		crosshair.visible = false
		await get_tree().create_timer(0.7).timeout
		death_tip.visible = true
		await get_tree().create_timer(3.0).timeout
		round_lost.emit()
	elif all_enemies_destroyed():
		await get_tree().create_timer(1.2).timeout
		play_round_won_sound()
		# Wait a moment for the round won sound to reach its crescendo
		await get_tree().create_timer(0.28).timeout
		round_complete_control.visible = true
		if g.round_number == rounds.size():
			round_complete_label.text = "Game Won - Thanks For Playing"
		await get_tree().create_timer(0.7).timeout
		play_parts_earned_sound()
		parts_earned.visible = true
		var round_data: Dictionary = rounds[g.round_number - 1]
		var armor_parts_earned: int = round_data["armor_parts_earned"]
		var wheel_parts_earned: int = round_data["wheel_parts_earned"]
		var gun_parts_earned: int = round_data["gun_parts_earned"]
		armor_part_button.label.text = str(armor_parts_earned)
		wheel_part_button.label.text = str(wheel_parts_earned)
		gun_part_button.label.text = str(gun_parts_earned)
		await get_tree().create_timer(3.0).timeout
		g.armor_part_inventory += armor_parts_earned
		g.wheel_part_inventory += wheel_parts_earned
		g.gun_part_inventory += gun_parts_earned
		if g.armor_part_inventory > 50:
			g.armor_part_inventory = 50
		if g.wheel_part_inventory > 50:
			g.wheel_part_inventory = 50
		if g.gun_part_inventory > 50:
			g.gun_part_inventory = 50
		round_complete.emit()


func all_enemies_destroyed() -> bool:
	for vehicle: Vehicle in get_tree().get_nodes_in_group("vehicles"):
		if not vehicle.is_player and vehicle.cockpit_part.health > 0.0:
			return false
	return true


func play_round_won_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = round_won_stream
	asp.autoplay = true
	asp.volume_db = -0.0
	add_child(asp)


func play_round_lost_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = round_lost_stream
	asp.autoplay = true
	asp.volume_db = -0.0
	add_child(asp)


func play_parts_earned_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = parts_earned_stream
	asp.autoplay = true
	asp.volume_db = -0.0
	add_child(asp)
