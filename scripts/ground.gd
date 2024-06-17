@tool
class_name Ground
extends Node3D

const SIZE := 2000
const MESH_RESOLUTION := 500
const HEIGHT := 5.0
const terrain_height_map := preload("res://textures/terrain_height_map.tres")
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var shape: CollisionShape3D = $CollisionShape3D


@export var reset: bool:
	set(value):
		reset = false
		if value:
			mesh.scale = Vector3.ONE * SIZE

			var plane: PlaneMesh = mesh.mesh
			plane.subdivide_width = MESH_RESOLUTION
			plane.subdivide_depth = MESH_RESOLUTION

			var material: ShaderMaterial = plane.material
			material.set_shader_parameter("height_scale", HEIGHT / float(MESH_RESOLUTION))

			shape.scale = Vector3.ONE * float(SIZE) / float(MESH_RESOLUTION)

			var src := terrain_height_map.get_image()
			var image := Image.create_from_data(
				src.get_width(),
				src.get_height(),
				src.has_mipmaps(),
				src.get_format(),
				src.get_data()
			)
			var s := MESH_RESOLUTION + 1
			image.resize(s, s)
			image.convert(Image.FORMAT_RF)
			var rdata := image.get_data()
			var data := rdata.to_float32_array()
			for i in data.size():
				data[i] *= HEIGHT

			var h: HeightMapShape3D = shape.shape
			h.map_width = s
			h.map_depth = s
			h.map_data = data
