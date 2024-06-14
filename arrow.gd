@tool
class_name Arrow
extends Node3D

@onready var line: MeshInstance3D = $Line
@onready var tip: MeshInstance3D = $Tip
var arrow_material: StandardMaterial3D = preload("res://materials/arrow.tres")


@export var color: Color = Color("ffffff"):
	set(value):
		color = value
		if is_node_ready():
			material.albedo_color = color
			notify_property_list_changed()


@export var vector: Vector3:
	get:
		return vector
	set(value):
		vector = value
		if is_node_ready():
			Global.safe_look_at(self, global_position + value, true)
			scale.z = value.length()


var material: StandardMaterial3D:
	get:
		if not material:
			material = arrow_material.duplicate()
			line.material_override = material
			tip.material_override = material
		return material


func _ready() -> void:
	pass
	color = color
	vector = vector
