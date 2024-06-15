class_name GunPart
extends Node3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var barrel: Node3D = $Barrel
@onready var barrel_end: Node3D = $Barrel/End
@onready var base: MeshInstance3D = $Base
@onready var frame: Node3D = $Frame
var last_fired_at = -1000.0
var health := 100.0
