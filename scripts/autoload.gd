class_name Autoload
extends Node

const scene_transition_stream: AudioStream = preload("res://sounds/scene_transition.ogg")


func play_scene_transition_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = scene_transition_stream
	asp.autoplay = true
	asp.volume_db = -0.0
	add_child(asp)
