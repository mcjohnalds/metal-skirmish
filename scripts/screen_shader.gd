class_name ScreenShader
extends ColorRect


func _ready() -> void:
	g.graphics_preset_changed.connect(on_graphics_preset_changed)
	on_graphics_preset_changed()


func on_graphics_preset_changed() -> void:
	match g.graphics_preset:
		Global.GraphicsPreset.LOW:
			visible = false
		Global.GraphicsPreset.MEDIUM:
			visible = true
		Global.GraphicsPreset.HIGH:
			visible = true
		Global.GraphicsPreset.INSANE:
			visible = true
