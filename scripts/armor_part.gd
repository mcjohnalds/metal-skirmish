@tool
class_name ArmorPart
extends Node3D


@export var color := Color("#5A5A5A"):
	set(value):
		color = value
		if not is_node_ready():
			return
		var mesh: MeshInstance3D = armor.get_node("Armor")
		var mat: ShaderMaterial = mesh.material_override
		mat.set_shader_parameter("new_paint_color", color)


@onready var armor: Node3D = $Armor
@onready var frame: Node3D = $Frame
var health := 100.0


func _ready() -> void:
	var mesh: MeshInstance3D = armor.get_node("Armor")
	var mat: ShaderMaterial = mesh.material_override
	var uv1 := Vector3(
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0)
	);
	mat.set_shader_parameter("uv1_offset", uv1)
	color = color
