class_name MyParticles
extends GPUParticles3D


func _init() -> void:
	if g.graphics_preset == Global.GraphicsPreset.LOW:
		amount /= 2


func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()
