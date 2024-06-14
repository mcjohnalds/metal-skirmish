class_name Tracer
extends Node3D

var start: Vector3
var end: Vector3
var has_rendered := false


func _ready() -> void:
	var duration := 0.02
	await get_tree().create_timer(duration).timeout
	has_rendered = true


func _process(delta: float) -> void:
	if has_rendered:
		var dir1 := start.direction_to(end)
		var speed := 600.0
		start += start.direction_to(end) * speed * delta
		var dir2 := start.direction_to(end)
		if dir1.dot(dir2) < 0.0:
			queue_free()
	global_position = start
	Global.safe_look_at(self, end, true)
	self.scale.z = start.distance_to(end)
