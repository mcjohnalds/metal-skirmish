class_name Arena
extends Node3D

@onready var player_spawn_point: Node3D = $PlayerSpawnPoint
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var ground: Ground = $Ground
var player: Vehicle


func _ready() -> void:
	var min_y := 0.0
	for c in player.get_children():
		min_y = minf(min_y, c.position.y)
	player.position = player_spawn_point.position - Vector3.UP * min_y
	add_child(player)


func _process(_delta: float) -> void:
	g.arena.aim_debug_sphere.global_position = g.camera_pivot.aim.get_collision_point()
