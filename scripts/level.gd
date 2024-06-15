class_name Level
extends Node3D

@onready var player: Vehicle = $Player
@onready var aim_debug_sphere: MeshInstance3D = $AimDebugSphere
@onready var ground: Ground = $Ground


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
