@tool
class_name GunPart
extends Node3D

@export var alpha_curve: Curve


@export var bone_target: Vector3:
	set(value):
		bone_target = value
		if not is_node_ready():
			return
		arm1.look_at(bone_target, Vector3.UP, true)
		arm1.rotation.x = 0.0
		arm2.look_at(bone_target, Vector3.UP, true)


@onready var barrel_end: Node3D = %End
@onready var frame: Node3D = $Frame
@onready var muzzle_flashes: Array[MeshInstance3D] = [
	%End/MuzzleFlash1,
	%End/MuzzleFlash2,
	%End/MuzzleFlash3
]
@onready var smoke: GPUParticles3D = %End/Smoke
@onready var model: Node3D = $Model
@onready var arm1: Node3D = $Model/Arm1
@onready var arm1_anchor: Node3D = $Model/Arm1Anchor
@onready var arm2: Node3D = $Model/Arm2
@onready var arm2_anchor: Node3D = $Model/Arm1/Arm2Anchor
var last_fired_at := -1000.0
var health := 100.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	for child in Global.get_all_children(model):
		if child is MeshInstance3D:
			var mesh: MeshInstance3D = child
			if mesh.material_override is ShaderMaterial:
				var mat: ShaderMaterial = mesh.material_override
				var uv1 := Vector3(
					randf_range(0.0, 1.0),
					randf_range(0.0, 1.0),
					randf_range(0.0, 1.0)
				);
				mat.set_shader_parameter("uv1_offset", uv1)



func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var firing := floori(Global.get_ticks_sec() / 5.0) % 2 == 0
		if firing and can_fire():
			fire()
	arm1.global_position = arm1_anchor.global_position
	arm2.global_position = arm2_anchor.global_position
	smoke.emitting = Global.get_ticks_sec() - last_fired_at < 0.05
	for mesh in muzzle_flashes:
		var material: StandardMaterial3D = mesh.material_override
		var lifetime := 0.1
		var t := Global.get_ticks_sec()
		var d := t - last_fired_at
		material.albedo_color.a = alpha_curve.sample_baked(d / lifetime)


func fire() -> void:
	last_fired_at = Global.get_ticks_sec()


func can_fire() -> bool:
	return Global.get_ticks_sec() - last_fired_at >= 1.0 / Global.FIRE_RATE
