class_name MyParticles
extends GPUParticles3D

@export var auto_clean_up := true


func _init() -> void:
	if g.graphics_preset == Global.GraphicsPreset.LOW:
		amount = maxi(amount / 2, 1)


func _ready() -> void:
	if one_shot:
		await get_tree().create_timer(lifetime).timeout
		queue_free()
