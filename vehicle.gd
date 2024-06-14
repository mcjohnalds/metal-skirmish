class_name Vehicle
extends RigidBody3D

const SPRING_REST_DISTANCE := 0.7
@onready var camera_pivot: Node3D = $CameraPivot
@onready var aim_ray_cast: RayCast3D = $CameraPivot/Camera3D/Aim
@export var is_player := false
var wheel_friction_front: Curve = preload("res://curves/wheel_friction_front.tres")
var wheel_friction_back: Curve = preload("res://curves/wheel_friction_back.tres")
var throttle_forward: Curve = preload("res://curves/throttle_forward.tres")
var throttle_reverse: Curve = preload("res://curves/throttle_reverse.tres")
var tracer_scene: PackedScene = preload("res://tracer.tscn")
var wheel_parts: Array[WheelPart] = []
var gun_parts: Array[GunPart] = []
var view_pitch := 0.0


func _ready() -> void:
	var part_count := 0
	var part_position_sum := Vector3.ZERO
	var shapes: Array = []
	aim_ray_cast.add_exception(self)
	for child: Node in get_children():
		var is_part := false
		if child is ArmorPart:
			is_part = true
			var part := child as ArmorPart
			shapes.append({ "shape": part.collision_shape, "transform": part.transform })
		elif child is WheelPart:
			is_part = true
			var part := child as WheelPart
			shapes.append({ "shape": part.collision_shape, "transform": part.transform })
			wheel_parts.append(part)
			part.ray_cast.add_exception(self)
			part.ray_cast.target_position.y = -SPRING_REST_DISTANCE - part.radius
			
			var is_left := part.position.x > 0.0
			var direction := 1.0 if is_left else -1.0
			var x_offset := 0.5
			part.wheel.position.x += direction * x_offset
			part.ray_cast.position.x += direction * x_offset

			var is_front: bool = child.position.z > 0.0
			part.traction = is_front
			part.steering = is_front
			part.front = is_front
		elif child is GunPart:
			is_part = true
			var part := child as GunPart
			gun_parts.append(part)
			shapes.append({ "shape": part.collision_shape, "transform": part.transform })
		if is_part:
			part_position_sum += child.position
			part_count += 1
	for d: Dictionary in shapes:
		var shape: CollisionShape3D = d.shape
		var trans: Transform3D = d.transform
		var so := create_shape_owner(shape)
		shape_owner_add_shape(so, shape.shape)
		shape_owner_set_transform(so, trans)
	center_of_mass = part_position_sum / part_count
	center_of_mass.y = -0.5


func _physics_process(delta: float) -> void:
	for part: GunPart in gun_parts:
		_physics_process_gun_part(part)
	for part: WheelPart in wheel_parts:
		_physics_process_wheel_part(part, delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		var sensitivity := 0.002
		var motion := event as InputEventMouseMotion
		camera_pivot.rotation.y -= motion.relative.x * sensitivity
		view_pitch += motion.relative.y * sensitivity
		var m := TAU / 4.0
		view_pitch = clampf(view_pitch, -m, m)
		camera_pivot.rotation.x = view_pitch / 2.0
		var camera := camera_pivot.get_child(0)
		camera.rotation.x = -view_pitch / 2.0


func _physics_process_gun_part(part: GunPart) -> void:
	if not is_player:
		return
	var aim_ray_start := aim_ray_cast.global_position

	var aim_ray_end: Vector3
	if aim_ray_cast.get_collider():
		aim_ray_end = aim_ray_cast.get_collision_point()
	else:
		aim_ray_end = aim_ray_cast.global_transform * aim_ray_cast.target_position
	Global.safe_look_at(part.barrel, aim_ray_end, true)

	var bullet_start := part.barrel_end.global_position
	var bullet_true_dir := bullet_start.direction_to(aim_ray_end)
	var aim_ray_length := aim_ray_start.distance_to(aim_ray_end)
	var m := TAU * 0.002
	var qp := Quaternion(Vector3.LEFT, randf_range(-m, m))
	var qy := Quaternion(Vector3.UP, randf_range(-m, m))
	var bullet_rand_dir := qy * (qp * bullet_true_dir)

	var query := PhysicsRayQueryParameters3D.new()
	query.from = bullet_start
	query.to = bullet_start + bullet_rand_dir * aim_ray_length
	var collision := get_world_3d().direct_space_state.intersect_ray(query)

	var bullet_end: Vector3
	if collision:
		bullet_end = collision.position
	else:
		bullet_end = query.to

	var fire_rate := 10.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Global.get_ticks_sec() - part.last_fired_at >= 1.0 / fire_rate:
		var tracer: Tracer = tracer_scene.instantiate()
		tracer.start = part.barrel_end.global_position
		tracer.end = bullet_end
		part.last_fired_at = Global.get_ticks_sec()
		add_child(tracer)


func _physics_process_wheel_part(part: WheelPart, delta: float) -> void:
	var collider := part.ray_cast.get_collider()
	part.wheel.position.y = part.ray_cast.position.y - SPRING_REST_DISTANCE

	if collider:
		var debug_arrow_scale := 0.002

		var force_offset := part.wheel.global_position - global_position

		var breaking := false
		if part.traction:
			var input := get_throttle_input()
			var max_torque := 15000.0 * absf(input)
			var forward_speed := linear_velocity.dot(basis.z)
			if forward_speed * input < 0.0:
				breaking = true
			var max_speed := 30.0
			var x := minf(forward_speed / max_speed, 1.0)
			var a_curve := throttle_forward if forward_speed > 0.0 else throttle_reverse
			var s := a_curve.sample(x)
			apply_force(global_basis.z * s * max_torque * input, force_offset)

		if part.steering:
			var input_steering := get_steering_input()
			var steer_speed := 4.0
			var steer_max := TAU * 0.1 * absf(input_steering)
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
		var spring_offset := SPRING_REST_DISTANCE - spring_length

		part.wheel.position.y = part.ray_cast.position.y - spring_length
		var spring_velocity := (part.last_spring_offset - spring_offset) / delta
		var spring_strength := 20000.0
		var spring_damping := spring_strength * 0.15
		var spring_force := 1.5 * spring_offset * spring_strength - spring_velocity * spring_damping
		var spring_force_vector := part.global_basis.y * spring_force
		apply_force(spring_force_vector, force_offset)

		part.debug_arrow_y.global_position = global_position + force_offset
		part.debug_arrow_y.vector = spring_force_vector * debug_arrow_scale

		var wheel_velocity := Global.get_point_velocity(self, part.wheel.global_position)
		var forward_friction := 0.1 if breaking else 0.01
		var wheel_friction_lookup := absf(wheel_velocity.dot(part.wheel.global_basis.x)) / wheel_velocity.length()
		var curve := wheel_friction_front if part.front else wheel_friction_back
		var sideways_friction := curve.sample(wheel_friction_lookup)
		var tire_mass := 100.0

		var sideways_friction_force_vector := -wheel_velocity.project(part.wheel.global_basis.x) * sideways_friction * tire_mass / delta
		var forward_friction_force_vector := -wheel_velocity.project(part.wheel.global_basis.z) * forward_friction * tire_mass / delta

		apply_force(sideways_friction_force_vector, force_offset)
		apply_force(forward_friction_force_vector, force_offset)
		part.debug_arrow_x.global_position = global_position + force_offset
		part.debug_arrow_x.vector = Vector3.ONE * 0.001 + sideways_friction_force_vector * debug_arrow_scale
		part.debug_arrow_z.global_position = global_position + force_offset
		part.debug_arrow_z.vector = Vector3.ONE * 0.001 + forward_friction_force_vector * debug_arrow_scale
		part.last_spring_offset = spring_offset


func get_throttle_input() -> float:
	if is_player:
		return Input.get_axis("move_backward", "move_forward")
	return 0.8


func get_steering_input() -> float:
	if is_player:
		return -Input.get_axis("move_left", "move_right")
	var frequency := 0.1
	return -0.7 * sin(Global.get_ticks_sec() * TAU * frequency)
