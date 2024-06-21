class_name Autoload
extends Node

const scene_transition_stream: AudioStream = preload("res://sounds/scene_transition.ogg")
const ambient_wind_stream: AudioStream = preload("res://sounds/ambient_wind.ogg")


func play_scene_transition_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = scene_transition_stream
	asp.autoplay = true
	asp.volume_db = -0.0
	add_child(asp)


func play_ambient_wind_sound() -> void:
	var asp := AudioStreamPlayer.new()
	asp.stream = ambient_wind_stream
	asp.autoplay = true
	asp.volume_db = -10.0
	add_child(asp)
