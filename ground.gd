@tool
class_name Ground
extends Node3D

var terrain_height_map := preload("res://textures/terrain_height_map.tres")
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var shape: CollisionShape3D = $CollisionShape3D


@export var reset: bool:
	set(value):
		reset = false
		var src := terrain_height_map.get_image()
		var image := Image.create_from_data(
			src.get_width(),
			src.get_height(),
			src.has_mipmaps(),
			src.get_format(),
			src.get_data()
		)
		image.resize(100, 100)
		image.convert(Image.FORMAT_RF)
		var rdata := image.get_data()
		var data := rdata.to_float32_array()
		for i in data.size():
			data[i] *= 1.0
		var h: HeightMapShape3D = shape.shape
		h.map_data = data.slice(0, 100 * 100)
