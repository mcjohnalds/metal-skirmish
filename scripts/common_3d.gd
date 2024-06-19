class_name Common3D
extends Node3D

@onready var light: DirectionalLight3D = $DirectionalLight3D


func _ready() -> void:
	update()
	g.graphics_preset_changed.connect(update)


func update() -> void:
	light.shadow_enabled = (
		g.graphics_preset > Global.GraphicsPreset.LOW
		and not Global.is_compatibility_renderer()
	)
