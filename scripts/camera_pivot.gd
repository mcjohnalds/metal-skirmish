class_name CameraPivot
extends Node3D

const MOUSE_ORBIT_SPEED := 0.004
const PAN_ORBIT_SPEED := MOUSE_ORBIT_SPEED * 5.0
const MOUSE_SENSITIVITY_MULTIPLIER := 0.002
@onready var camera: Camera3D = $Camera
@onready var aim: RayCast3D = $Camera/Aim
var fight_mode := false
var last_error: Vector3
var error_integral: Vector3


var view_pitch := 0.0:
	set(value):
		view_pitch = value
		var max_pitch := TAU / 4.0
		view_pitch = clampf(view_pitch, -max_pitch, max_pitch)
		var s := get_viewport().get_visible_rect().size
		var aspect_ratio := s.x / s.y
		if fight_mode:
			rotation.x = view_pitch / 2.0 * aspect_ratio
			camera.rotation.x = -view_pitch / 4.0
		else:
			rotation.x = view_pitch * aspect_ratio
			camera.rotation.x = 0.0


var view_yaw := 0.0:
	set(value):
		view_yaw = value
		rotation.y = view_yaw


func _ready() -> void:
	aim.target_position = Vector3(0.0, 0.0, -10000.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		var e := event as InputEventMagnifyGesture
		camera.position.z *= e.factor
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		var scroll_speed := 1.1
		if button.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.position.z /= scroll_speed
		elif button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.position.z *= scroll_speed
		autoload.play_scroll_sound()

	if camera.position.z < -100.0:
		camera.position.z = -100.0
	if camera.position.z >= -3.0:
		camera.position.z = -3.0

	if event is InputEventMouseMotion:
		var e := event as InputEventMouseMotion
		var invert := -1.0 if g.invert_mouse else 1.0
		if fight_mode:
			var s := g.mouse_sensitivity * MOUSE_SENSITIVITY_MULTIPLIER
			view_pitch += e.relative.y * s * invert
			view_yaw -= e.relative.x * s
		elif Input.is_action_pressed("orbit"):
			view_pitch += e.relative.y * MOUSE_ORBIT_SPEED * invert
			view_yaw -= e.relative.x * MOUSE_ORBIT_SPEED
	if event is InputEventPanGesture:
		var e := event as InputEventPanGesture
		view_pitch += e.delta.y * PAN_ORBIT_SPEED * -1.0
		view_yaw -= e.delta.x * PAN_ORBIT_SPEED * -1.0
