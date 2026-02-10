@tool
extends EditorScript


var types: Array[String] = ["MeshInstance3D", "CollisionShape3D"]
var type: String = ""
var use_col: String = ""


var scenes_to_load: PackedStringArray = []
var output: String = ""


func _run() -> void:
	_select_type()


func _select_type() -> void:
	var type_select_dialog: AcceptDialog = AcceptDialog.new()
	
	var vbox: VBoxContainer = VBoxContainer.new()
	type_select_dialog.add_child(vbox)
	
	var type_option_button: OptionButton = OptionButton.new()
	for i in types:
		type_option_button.add_item(i)
	vbox.add_child(type_option_button)
	
	var col_option_button: OptionButton = OptionButton.new()
	col_option_button.add_item("Convex")
	col_option_button.add_item("Trimesh")
	vbox.add_child(col_option_button)
	
	EditorInterface.get_base_control().add_child(type_select_dialog)
	
	type_select_dialog.popup_centered()
	
	type_select_dialog.confirmed.connect(func():
		type = type_option_button.get_item_text(type_option_button.get_selected_id())
		use_col = col_option_button.get_item_text(col_option_button.get_selected_id())
		print("Type: ", type)
		type_select_dialog.queue_free()
		_select_input())


func _select_input() -> void:
	var scenes_select_dialog = FileDialog.new()
	scenes_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	scenes_select_dialog.filters = ["*.obj"]
	scenes_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(scenes_select_dialog)
	
	scenes_select_dialog.popup_centered(Vector2i(1280, 720))
	
	scenes_select_dialog.files_selected.connect(func(paths: PackedStringArray):
		scenes_to_load = paths.duplicate()
		print("Scenes: ", scenes_to_load)
		scenes_select_dialog.queue_free()
		_select_output())


func _select_output() -> void:
	var output_select_dialog = FileDialog.new()
	output_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	output_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(output_select_dialog)
	
	output_select_dialog.popup_centered(Vector2i(1280, 720))
	
	output_select_dialog.dir_selected.connect(func(path: String):
		output = path
		print("Output: ", output)
		output_select_dialog.queue_free()
		_convert())


func _convert() -> void:
	if scenes_to_load.size() <= 0:
		print("Error: No scenes selected")
		return
	
	if output == "":
		print("Error: No output path")
		return
	
	if type == "MeshInstance3D":
		for scene in scenes_to_load:
			var file_name: String = scene.get_file().get_basename()
			
			var root: MeshInstance3D = MeshInstance3D.new()
			root.name = file_name
			
			var mesh: Mesh = load(scene)
			root.mesh = mesh
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/" + file_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
	
	if type == "CollisionShape3D":
		for scene in scenes_to_load:
			var file_name: String = scene.get_file().get_basename()
			
			var root: CollisionShape3D = CollisionShape3D.new()
			root.name = file_name
			
			var mesh: Mesh = load(scene)
			match use_col:
				"Convex":
					root.shape = mesh.create_convex_shape()
				"Trimesh":
					root.shape = mesh.create_trimesh_shape()
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/" + file_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
	
	print("---Complete---")
