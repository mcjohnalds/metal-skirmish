class_name CockpitPart
extends Node3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var cockpit: Node3D = $Cockpit
@onready var frame: Node3D = $Frame
var health := 500.0
