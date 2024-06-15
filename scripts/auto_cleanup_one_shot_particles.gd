class_name AutoCleanupOneShotParticles
extends GPUParticles3D

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
