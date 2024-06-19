@tool
class_name PartButton
extends Control

@export var part: PackedScene:
	set(value):
		part = value
		if is_node_ready():
			while part_viewer.part_container.get_child_count() > 0:
				part_viewer.part_container.remove_child(part_viewer.part_container.get_child(0))
			if part:
				part_viewer.part_container.add_child(part.instantiate())


@onready var border: Control = $Border
@onready var label: Label = $Button/MarginContainer/Label
@onready var button: Button = $Button
@onready var part_viewer: Node3D = %PartViewer


func _ready() -> void:
	part = part
