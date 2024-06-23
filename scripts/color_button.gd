@tool
class_name ColorButton
extends BaseButton


@export var color := Color.BLUE:
	set(value):
		color = value
		if not is_node_ready():
			return
		color_rect.color = color
		var box: StyleBoxFlat = border_panel.get_theme_stylebox("panel")
		box.border_color = (
			Color("d2dde0") if color.get_luminance() < 0.5 else Color("33322c")
		)


@export var selected := false:
	set(value):
		selected = value
		if not is_node_ready():
			return
		border_panel.visible = selected


@onready var color_rect: ColorRect = $ColorRect
@onready var border_panel: Panel = $BorderPanel


func _ready() -> void:
	color = color
	selected = selected
