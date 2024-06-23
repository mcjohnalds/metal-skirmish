@tool
class_name CockpitPart
extends Node3D


@export var color := Color("#5A5A5A"):
	set(value):
		color = value
		if not is_node_ready():
			return
		var outside: MeshInstance3D = cockpit.get_node("Outside")
		var outside_mat: ShaderMaterial = outside.material_override
		outside_mat.set_shader_parameter("new_paint_color", color)
		var inside: MeshInstance3D = cockpit.get_node("Inside")
		var inside_mat: StandardMaterial3D = inside.material_override
		var light_color = Color.from_hsv(color.h, color.s, 1.0)
		inside_mat.emission = light_color
		light.light_color = light_color


@onready var cockpit: Node3D = $Cockpit
@onready var frame: Node3D = $Frame
@onready var light: OmniLight3D = $Light
var health := 200.0


func _ready() -> void:
	color = color
