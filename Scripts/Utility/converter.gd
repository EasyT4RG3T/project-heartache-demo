@tool
extends EditorScript


var types: Array[String] = ["StaticBody3D", "DynamicObject3D"]
var type: String = ""
var col: bool = true
var scenes: PackedStringArray = []
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
	
	var col_check_box: CheckBox = CheckBox.new()
	col_check_box.text = "collision"
	col_check_box.button_pressed = true
	vbox.add_child(col_check_box)
	
	EditorInterface.get_base_control().add_child(type_select_dialog)
	
	type_select_dialog.popup_centered()
	
	type_select_dialog.confirmed.connect(func():
		type = type_option_button.get_item_text(type_option_button.get_selected_id())
		col = col_check_box.button_pressed
		print("Type: ", type)
		type_select_dialog.queue_free()
		_select_input())


func _select_input() -> void:
	var scenes_select_dialog = FileDialog.new()
	scenes_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	scenes_select_dialog.filters = ["*.res"]
	scenes_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(scenes_select_dialog)
	
	scenes_select_dialog.popup_centered()
	
	scenes_select_dialog.files_selected.connect(func(paths: PackedStringArray):
		scenes = paths.duplicate()
		print("Meshes: ", scenes)
		scenes_select_dialog.queue_free()
		_select_output())


func _select_output() -> void:
	var output_select_dialog = FileDialog.new()
	output_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	output_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(output_select_dialog)
	
	output_select_dialog.popup_centered()
	
	output_select_dialog.dir_selected.connect(func(path: String):
		output = path
		print("Output: ", output)
		output_select_dialog.queue_free()
		_convert())


func _convert() -> void:
	if scenes.size() <= 0:
		print("Error: No scenes selected")
		return
	
	if output == "":
		print("Error: No output path")
		return
	
	for scene in scenes:
		var file_name: String = scene.get_file().get_basename()
		
		var root: Node
		
		match type:
			"StaticBody3D":
				root = StaticBody3D.new()
			"DynamicObject3D":
				root = DynamicObject3D.new()
			_:
				print("ERROR: invalid type")
				return
		
		root.name = file_name
		
		var array_mesh: ArrayMesh = load(scene)
		
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		mesh_instance.mesh = array_mesh
		root.add_child(mesh_instance)
		mesh_instance.owner = root
		
		if col:
			var shape: Shape3D = mesh_instance.mesh.create_convex_shape()
			var collision_shape: CollisionShape3D = CollisionShape3D.new()
			collision_shape.name = "CollisionShape3D"
			collision_shape.shape = shape
			root.add_child(collision_shape)
			collision_shape.owner = root
		
		if DirAccess.dir_exists_absolute(output + "/" + file_name + ".tscn"):
			print("?")
		
		var new_pscene: PackedScene = PackedScene.new()
		new_pscene.pack(root)
		
		var save_error = ResourceSaver.save(new_pscene, output + "/" + file_name + ".tscn")
		if save_error != OK:
			print("ERROR: ", save_error)
		
		root.queue_free()
	
	print("---Complete---")
