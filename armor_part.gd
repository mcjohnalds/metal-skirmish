class_name ArmorPart
extends Node3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var armor: MeshInstance3D = $Armor
@onready var frame: Node3D = $Frame
var health := 100.0
