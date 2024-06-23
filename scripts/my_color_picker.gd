@tool
class_name MyColorPicker
extends Control

signal selected()

const _color_button_scene := preload("res://scenes/color_button.tscn")

var _selected: ColorButton
var color: Color = Color("#5A5A5A")


func deselect() -> void:
	if _selected:
		_selected.selected = false
		_selected = null


func _ready() -> void:
	for child in get_children(true):
		remove_child(child)
	for col in Global.color_palette:
		var color_button := _color_button_scene.instantiate()
		color_button.color = col
		add_child(color_button)
		color_button.button_down.connect(_on_button_pressed.bind(color_button))


func _on_button_pressed(color_button: ColorButton) -> void:
	deselect()
	color_button.selected = true
	_selected = color_button
	color = color_button.color
	selected.emit()


func is_selected() -> bool:
	return _selected != null
