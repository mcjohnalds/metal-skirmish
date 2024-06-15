class_name CameraPivot
extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var aim: RayCast3D = $Camera3D/Aim
var view_pitch := 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		var sensitivity := 0.002
		var motion := event as InputEventMouseMotion
		rotation.y -= motion.relative.x * sensitivity
		view_pitch += motion.relative.y * sensitivity
		var m := TAU / 4.0
		view_pitch = clampf(view_pitch, -m, m)
		rotation.x = view_pitch / 2.0
		camera.rotation.x = -view_pitch / 2.0
