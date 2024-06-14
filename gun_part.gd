class_name GunPart
extends Node3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var barrel: Node3D = $Barrel
@onready var barrel_end: Node3D = $Barrel/End
var last_fired_at = -1000.0
