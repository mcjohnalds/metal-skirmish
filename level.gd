class_name Level
extends Node3D

@export var wheel_front_friction_curve: Curve
@export var wheel_back_friction_curve: Curve
@export var wheel_acceleration_curve: Curve
@export var wheel_reverse_curve: Curve
@export var tmp: Curve
@onready var player: RigidBody3D = $Player
@onready var camera_pivot: Node3D = $Player/CameraPivot
var wheel_parts: Array[WheelPart] = []
var spring_rest_distance := 0.7


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var part_count := 0
	var part_position_sum := Vector3.ZERO
	for child: Node in player.get_children():
		var is_part := false
		if child is ArmorPart:
			is_part = true
			var part := child as ArmorPart
			var so := player.create_shape_owner(part.collision_shape)
			player.shape_owner_add_shape(so, part.collision_shape.shape)
			player.shape_owner_set_transform(so, part.transform)
		elif child is WheelPart:
			is_part = true
			var part := child as WheelPart
			var so := player.create_shape_owner(part.collision_shape)
			player.shape_owner_add_shape(so, part.collision_shape.shape)
			player.shape_owner_set_transform(so, part.transform)
			wheel_parts.append(part)
			part.ray_cast.add_exception(player)
			part.ray_cast.target_position.y = -spring_rest_distance - part.radius
			
			var is_left := part.position.x > 0.0
			var direction := 1.0 if is_left else -1.0
			var x_offset := 0.5
			part.wheel.position.x += direction * x_offset
			part.ray_cast.position.x += direction * x_offset

			var is_front: bool = child.position.z > 0.0
			part.traction = is_front
			part.steering = is_front
			part.front = is_front
		if is_part:
			part_position_sum += child.position
			part_count += 1
	player.center_of_mass = part_position_sum / part_count
	player.center_of_mass.y -= 0.5


func _physics_process(delta: float) -> void:
	for part: WheelPart in wheel_parts:
		var collider := part.ray_cast.get_collider()
		part.wheel.position.y = part.ray_cast.position.y - spring_rest_distance

		if collider:
			var debug_arrow_scale := 0.002

			var force_offset := part.wheel.global_position - player.global_position

			var breaking := false
			if part.traction:
				var input := Input.get_axis("move_backward", "move_forward")
				var max_torque := 15000.0
				var forward_speed := player.linear_velocity.dot(player.basis.z)
				if forward_speed * input < 0.0:
					breaking = true
				var max_speed := 30.0
				var x := minf(forward_speed / max_speed, 1.0)
				var a_curve := wheel_acceleration_curve if forward_speed > 0.0 else wheel_reverse_curve
				var s := a_curve.sample(x)
				player.apply_force(player.global_basis.z * s * max_torque * input, force_offset)

			if part.steering:
				var input_steering := -Input.get_axis("move_left", "move_right")
				var steer_speed := 4.0
				var steer_max := TAU * 0.1
				var has_input = absf(input_steering) > 0.0
				var steering_outward := has_input and input_steering * part.wheel.rotation.y >= 0.0
				if steering_outward:
					var f := 1.0 - pow(absf(part.wheel.rotation.y / steer_max), 0.4)
					part.wheel.rotation.y += steer_speed * input_steering * f * delta
					part.wheel.rotation.y = clampf(part.wheel.rotation.y, -steer_max, steer_max)
				else:
					var return_direction := 1.0 if part.wheel.rotation.y < 0.0 else -1.0
					var old_rot_y := part.wheel.rotation.y
					part.wheel.rotation.y += steer_speed * return_direction * delta
					var sign_flipped := not is_equal_approx(signf(old_rot_y), signf(part.wheel.rotation.y))
					if sign_flipped:
						part.wheel.rotation.y = 0.0

			var point := part.ray_cast.get_collision_point()
			var distance := part.ray_cast.global_position.distance_to(point)
			var spring_length := distance - part.radius
			var spring_offset := spring_rest_distance - spring_length

			part.wheel.position.y = part.ray_cast.position.y - spring_length
			var spring_velocity := (part.last_spring_offset - spring_offset) / delta
			var spring_strength := 20000.0
			var spring_damping := spring_strength * 0.15
			var spring_force := 1.5 * spring_offset * spring_strength - spring_velocity * spring_damping
			var spring_force_vector := part.global_basis.y * spring_force
			player.apply_force(spring_force_vector, force_offset)

			part.debug_arrow_y.global_position = player.global_position + force_offset
			part.debug_arrow_y.vector = spring_force_vector * debug_arrow_scale

			var wheel_velocity := Global.get_point_velocity(player, part.wheel.global_position)
			var forward_friction := 0.1 if breaking else 0.01
			var wheel_friction_lookup := absf(wheel_velocity.dot(part.wheel.global_basis.x)) / wheel_velocity.length()
			var curve := wheel_front_friction_curve if part.front else wheel_back_friction_curve
			var sideways_friction := curve.sample(wheel_friction_lookup)
			var tire_mass := 100.0

			var sideways_friction_force_vector := -wheel_velocity.project(part.wheel.global_basis.x) * sideways_friction * tire_mass / delta
			var forward_friction_force_vector := -wheel_velocity.project(part.wheel.global_basis.z) * forward_friction * tire_mass / delta

			player.apply_force(sideways_friction_force_vector, force_offset)
			player.apply_force(forward_friction_force_vector, force_offset)
			part.debug_arrow_x.global_position = player.global_position + force_offset
			part.debug_arrow_x.vector = Vector3.ONE * 0.001 + sideways_friction_force_vector * debug_arrow_scale
			part.debug_arrow_z.global_position = player.global_position + force_offset
			part.debug_arrow_z.vector = Vector3.ONE * 0.001 + forward_friction_force_vector * debug_arrow_scale
			part.last_spring_offset = spring_offset


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		var sensitivity := 0.002
		var motion := event as InputEventMouseMotion
		camera_pivot.rotation.y -= motion.relative.x * sensitivity
		camera_pivot.rotation.x += motion.relative.y * sensitivity / 2.0
		var camera := camera_pivot.get_child(0)
		camera.rotation.x -= motion.relative.y * sensitivity / 2.0
