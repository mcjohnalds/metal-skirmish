class_name WheelPart
extends Node3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var wheel: Node3D = $Wheel
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var debug_arrow_x: Arrow = $DebugArrowX
@onready var debug_arrow_y: Arrow = $DebugArrowY
@onready var debug_arrow_z: Arrow = $DebugArrowZ
@onready var armor: MeshInstance3D = $Armor
@onready var frame: Node3D = $Frame
var radius := 0.5
var last_spring_offset: float
var traction := false
var steering := false
var front := false
var health := 100.0
