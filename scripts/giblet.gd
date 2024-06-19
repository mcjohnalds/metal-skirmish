class_name Giblet
extends RigidBody3D

@export var mesh: MeshInstance3D

static var giblets: Array[Giblet] = []


func _ready() -> void:
	# Deletes giblets if there are too many
	var max_giblets: int
	match g.graphics_preset:
		Global.GraphicsPreset.LOW:
			max_giblets = 20
		Global.GraphicsPreset.MEDIUM:
			max_giblets = 200
		Global.GraphicsPreset.HIGH:
			max_giblets = 400
		Global.GraphicsPreset.INSANE:
			max_giblets = 800
	giblets.append(self)
	for _i in giblets.size() - max_giblets:
		var g := giblets[0]
		if is_instance_valid(g):
			g.queue_free()
		# TODO: pop_front is slow, this should use a linked list instead
		giblets.pop_front()

	rotation += rand_vector3(TAU)
	angular_velocity += rand_vector3(0.3 * TAU)
	linear_velocity += rand_vector3(50.0)
	linear_velocity.y += 5.0
	await get_tree().create_timer(randf_range(5.0, 10.0)).timeout
	if not is_instance_valid(self):
		return
	collision_layer = 0
	collision_mask = 0
	sleeping = false
	# If I don't add some velocity, body is frozen for some reason
	linear_velocity.y -= 0.2
	await get_tree().create_timer(5.0).timeout
	if not is_instance_valid(self):
		return
	queue_free()


func rand_vector3(x: float) -> Vector3:
	return Vector3(randf_range(-x, x), randf_range(-x, x), randf_range(-x, x))
