@tool
class_name WheelPart
extends Node3D


@export var wheel_speed := 0.0:
	set(value):
		wheel_speed = value
		if is_node_ready() and Engine.is_editor_hint():
			wheel_model.rotation.x = 0.0


@onready var wheel: Node3D = $Wheel
@onready var wheel_model: Node3D = $Wheel/Model
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var debug_arrow_x: Arrow = $DebugArrowX
@onready var debug_arrow_y: Arrow = $DebugArrowY
@onready var debug_arrow_z: Arrow = $DebugArrowZ
@onready var armor: Node3D = $Armor
@onready var frame: Node3D = $Frame
var radius := 0.6
var last_spring_offset: float
var traction := false
var steering := false
var front := false
var health := 100.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var mesh: MeshInstance3D = armor.get_node("Armor")
	var mat: ShaderMaterial = mesh.material_override
	var uv1 := Vector3(
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0)
	);
	mat.set_shader_parameter("uv1_offset", uv1)


func _process(delta: float) -> void:
	wheel_model.rotation.x += delta * wheel_speed
