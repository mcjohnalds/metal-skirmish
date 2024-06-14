class_name Level
extends Node3D

@onready var player: Vehicle = $Player


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
