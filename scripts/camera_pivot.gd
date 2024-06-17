class_name CameraPivot
extends Node3D

const MOUSE_SENSITIVITY := 0.001
@onready var camera: Camera3D = $Camera
@onready var aim: RayCast3D = $Camera/Aim
var fight_mode := false


var view_pitch := 0.0:
	set(value):
		view_pitch = value
		if fight_mode:
			rotation.x = view_pitch / 2.0
			camera.rotation.x = -view_pitch / 2.0
		else:
			rotation.x = view_pitch
			camera.rotation.x = 0.0
		var max_pitch := TAU / 4.0
		view_pitch = clampf(view_pitch, -max_pitch, max_pitch)


var view_yaw := 0.0:
	set(value):
		view_yaw = value
		rotation.y = view_yaw


func _ready() -> void:
	aim.target_position = Vector3(0.0, 0.0, -Global.MAX_AIM_RANGE)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		var scroll_speed := 1.5
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z *= scroll_speed
			if camera.position.z < -100.0:
				camera.position.z = -100.0
		elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z /= scroll_speed
			if camera.position.z > -3.0:
				camera.position.z = -2.0
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if fight_mode:
			view_pitch += motion.relative.y * MOUSE_SENSITIVITY
			view_yaw -= motion.relative.x * MOUSE_SENSITIVITY
		elif Input.is_action_pressed("orbit"):
			view_pitch += motion.relative.y * MOUSE_SENSITIVITY * 2.0
			view_yaw -= motion.relative.x * MOUSE_SENSITIVITY * 2.0
