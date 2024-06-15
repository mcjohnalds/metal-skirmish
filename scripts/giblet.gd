class_name Giblet
extends RigidBody3D

@export var mesh: MeshInstance3D


func _ready() -> void:
	rotation += rand_vector3(TAU)
	angular_velocity += rand_vector3(0.3 * TAU)
	linear_velocity += rand_vector3(5.0) * Vector3(1.0, 0.0, 1.0)
	linear_velocity.y += randf_range(5.0, 10.0)
	await get_tree().create_timer(5.0).timeout
	collision_layer = 0
	collision_mask = 0
	sleeping = false
	# If I don't add some velocity, body is frozen for some reason
	linear_velocity.y -= 0.2
	await get_tree().create_timer(5.0).timeout
	queue_free()


func rand_vector3(x: float) -> Vector3:
	return Vector3(randf_range(-x, x), randf_range(-x, x), randf_range(-x, x))
