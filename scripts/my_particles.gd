class_name MyParticles
extends GPUParticles3D

@export var auto_clean_up := true


func _init() -> void:
	g.graphics_preset_changed.connect(on_graphics_preset_changed)
	on_graphics_preset_changed()


func _ready() -> void:
	if one_shot:
		await get_tree().create_timer(lifetime).timeout
		queue_free()


func on_graphics_preset_changed() -> void:
	if g.graphics_preset == Global.GraphicsPreset.LOW:
		amount = maxi(amount / 2, 1)
	if g.graphics_preset >= Global.GraphicsPreset.HIGH:
		if draw_pass_1 is QuadMesh:
			var mesh: QuadMesh = draw_pass_1
			if mesh.material is StandardMaterial3D:
				var mat: StandardMaterial3D = mesh.material
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if g.graphics_preset == Global.GraphicsPreset.INSANE:
		amount = amount * 2
