@tool
class_name GunPart
extends Node3D

@export var alpha_curve: Curve
@onready var barrel: Node3D = $Barrel
@onready var barrel_end: Node3D = $Barrel/End
@onready var base: MeshInstance3D = $Base
@onready var frame: Node3D = $Frame
@onready var muzzle_flashes: Array[MeshInstance3D] = [
	$Barrel/End/MuzzleFlash1,
	$Barrel/End/MuzzleFlash2,
	$Barrel/End/MuzzleFlash3
]
@onready var smoke: GPUParticles3D = $Barrel/End/Smoke
var last_fired_at := -1000.0
var health := 100.0


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var firing := floori(Global.get_ticks_sec() / 5.0) % 2 == 0
		if firing and can_fire():
			fire()
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
