class_name Menu
extends Control

@onready var start_button: Button = %StartButton
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton
@onready var mouse_sensitivity_slider: Slider = %MouseSensitivitySlider
@onready var sound_slider: Slider = %SoundVolumeSlider
@onready var music_slider: Slider = %MusicVolumeSlider
@onready var invert_mouse_option_button: OptionButton = %InvertMouseOptionButton
@onready var vsync_option_button: OptionButton = %VsyncOptionButton
@onready var performance_preset_option_button: OptionButton = %PerformancePresetOptionButton


func _ready() -> void:
	performance_preset_option_button.clear()
	performance_preset_option_button.add_item("Low")
	performance_preset_option_button.add_item("Medium")
	performance_preset_option_button.add_item("High")
	if Global.is_compatibility_renderer():
		vsync_option_button.get_parent().visible = false
	else:
		performance_preset_option_button.add_item("Insane")
	mouse_sensitivity_slider.drag_ended.connect(
		on_mouse_sensitivity_slider_drag_ended
	)
	sound_slider.drag_ended.connect(
		on_sound_slider_drag_ended
	)
	music_slider.drag_ended.connect(
		on_music_slider_drag_ended
	)
	invert_mouse_option_button.item_selected.connect(
		on_invert_mouse_item_selected
	)
	vsync_option_button.item_selected.connect(
		on_vsync_item_selected
	)
	performance_preset_option_button.item_selected.connect(
		on_performance_preset_item_selected
	)
	read_settings_from_environment()
	quit_button.get_parent().visible = OS.get_name() != "Web"


func read_settings_from_environment() -> void:
	mouse_sensitivity_slider.value = g.mouse_sensitivity
	sound_slider.value = db_to_slider_value(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("World"))
	)
	music_slider.value = db_to_slider_value(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	)
	invert_mouse_option_button.selected = int(g.invert_mouse)
	vsync_option_button.selected = (
		DisplayServer.window_get_vsync_mode()
	)
	performance_preset_option_button.selected = g.graphics_preset


func on_mouse_sensitivity_slider_drag_ended(
	_value_changed: bool
) -> void:
	autoload.play_button_click_sound()
	g.mouse_sensitivity = mouse_sensitivity_slider.value


func on_sound_slider_drag_ended(
	_value_changed: bool
) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("World"),
		slider_value_to_db(sound_slider.value)
	)
	autoload.play_button_click_sound()


func on_music_slider_drag_ended(
	_value_changed: bool
) -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		slider_value_to_db(music_slider.value)
	)
	autoload.play_button_click_sound()


func on_invert_mouse_item_selected(index: int) -> void:
	autoload.play_button_click_sound()
	g.invert_mouse = bool(index)


func on_vsync_item_selected(index: int) -> void:
	autoload.play_button_click_sound()
	DisplayServer.window_set_vsync_mode(index)


func on_performance_preset_item_selected(index: int) -> void:
	autoload.play_button_click_sound()
	g.graphics_preset = index as Global.GraphicsPreset


func slider_value_to_db(slider_value: float) -> float:
	return -80.0 + 80.0 * pow(slider_value, 1.0 / 4.0)


func db_to_slider_value(db: float) -> float:
	return pow(db / 80.0 + 1.0, 4.0)
