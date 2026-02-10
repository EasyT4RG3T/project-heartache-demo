@tool
extends EditorScript


var types: Array[String] = ["StaticBody3D", "DynamicObject3D", "WettableObject3D"]
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
	
	var col_check_box: CheckBox = CheckBox.new()
	col_check_box.text = "collision"
	col_check_box.button_pressed = true
	vbox.add_child(col_check_box)
	
	var col_option_button: OptionButton = OptionButton.new()
	col_option_button.add_item("Convex")
	col_option_button.add_item("Trimesh")
	vbox.add_child(col_option_button)
	
	EditorInterface.get_base_control().add_child(type_select_dialog)
	
	type_select_dialog.popup_centered()
	
	type_select_dialog.confirmed.connect(func():
		type = type_option_button.get_item_text(type_option_button.get_selected_id())
		if col_check_box.button_pressed:
			use_col = col_option_button.get_item_text(col_option_button.get_selected_id())
		print("Type: ", type)
		type_select_dialog.queue_free()
		_select_input())


func _select_input() -> void:
	var scenes_select_dialog = FileDialog.new()
	scenes_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	scenes_select_dialog.filters = ["*.tscn"]
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
	
	for scene in scenes_to_load:
		var file_name: String = scene.get_file().get_basename()
		
		var root: Node
		
		match type:
			"StaticBody3D":
				root = StaticBody3D.new()
			"DynamicObject3D":
				root = DynamicObject3D.new()
			"WettableObject3D":
				root = WettableObject3D.new()
			_:
				print("ERROR: invalid type")
				return
		
		root.name = file_name
		
		var loaded_scene: PackedScene = load(scene)
		var mesh_instance: MeshInstance3D = loaded_scene.instantiate()
		
		root.add_child(mesh_instance)
		mesh_instance.owner = root
		
		if root.is_class("RigidBody3D"):
			mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
		
		if use_col:
			var shape: Shape3D
			match use_col:
				"Convex":
					shape = mesh_instance.mesh.create_convex_shape()
				"Trimesh":
					shape = mesh_instance.mesh.create_trimesh_shape()
				_:
					print("ERROR: invalid collision")
					return
			var collision_shape: CollisionShape3D = CollisionShape3D.new()
			collision_shape.name = "CollisionShape3D"
			collision_shape.shape = shape
			root.add_child(collision_shape)
			collision_shape.owner = root
		
		mesh_instance.queue_free()
		
		var new_pscene: PackedScene = PackedScene.new()
		new_pscene.pack(root)
		
		var save_error = ResourceSaver.save(new_pscene, output + "/" + file_name + ".tscn")
		if save_error != OK:
			print("ERROR: ", save_error)
		
		root.queue_free()
	
	print("---Complete---")
