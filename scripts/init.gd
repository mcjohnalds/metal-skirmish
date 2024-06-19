class_name Init
extends Node

@onready var container: Node = $Container
@onready var progress_label: Label = %ProgressLabel
@onready var file_label: Label = %FileLabel


func _ready() -> void:
	var file_names := DirAccess.get_files_at("res://scenes")
	for i in file_names.size():
		var file_name := file_names[i].rstrip(".remap")
		# Files in the exported package hava .remap suffix
		var file_path := "res://scenes/%s" % file_name
		var current_file_path := get_tree().current_scene.scene_file_path
		# Don't want to put a duplicate of this scene into the current tree
		# because the canvas layers would clash
		if file_path == current_file_path:
			continue

		var percent := floori(float(i) / float(file_names.size()) * 100.0)
		progress_label.text = "Loading assets (%s%%)" % percent
		file_label.text = file_name
		await get_tree().process_frame

		var scene := load(file_path)
		var node: Node = scene.instantiate()
		node.set_script(null)
		for child: Node in get_all_children(node):
			child.set_script(null)
			if child is GPUParticles3D:
				child.one_shot = true
				child.emitting = true
		container.add_child(node)
		await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func get_all_children(node: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(get_all_children(N))
		else:
			nodes.append(N)
	return nodes
