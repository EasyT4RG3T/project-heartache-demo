@tool
extends EditorScript


var scenes_to_load: PackedStringArray = []

var only_collision_shape_3d: bool = false
var do_static_body_3d: bool = false
var do_trimesh_collision: bool = false
var do_dynamic_body_3d: bool = false
var do_convex_collision: bool = false
var do_small_body: bool = false

func _run() -> void:
	_select_input()


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
		_select_types())


func _select_types() -> void:
	var type_select_dialog: AcceptDialog = AcceptDialog.new()
	type_select_dialog.title = "Choose"
	
	var vbox: VBoxContainer = VBoxContainer.new()
	type_select_dialog.add_child(vbox)
	
	var mesh_instance_button: Button = Button.new()
	mesh_instance_button.text = "MeshInstance3D"
	mesh_instance_button.pressed.connect(func():
		do_static_body_3d = false
		do_trimesh_collision = false
		do_dynamic_body_3d = false
		do_convex_collision = false
		do_small_body = false
		type_select_dialog.queue_free()
		_convert())
	vbox.add_child(mesh_instance_button)
	
	var collision_button: Button = Button.new()
	collision_button.text = "CollisionShape3D"
	collision_button.pressed.connect(func():
		only_collision_shape_3d = true
		type_select_dialog.queue_free()
		_convert())
	vbox.add_child(collision_button)
	
	var trimesh_collision_button: CheckBox = CheckBox.new()
	
	var static_body_button: CheckBox = CheckBox.new()
	static_body_button.text = "StaticBody3D"
	static_body_button.pressed.connect(func():
		do_static_body_3d = static_body_button.button_pressed
		if static_body_button.button_pressed:
			trimesh_collision_button.show()
		else:
			trimesh_collision_button.hide())
	vbox.add_child(static_body_button)
	
	trimesh_collision_button.text = "Collision"
	trimesh_collision_button.pressed.connect(func():
		do_trimesh_collision = trimesh_collision_button.button_pressed)
	vbox.add_child(trimesh_collision_button)
	trimesh_collision_button.hide()
	
	var dynamic_body_hbox: HBoxContainer = HBoxContainer.new()
	
	var dynamic_body_button: CheckBox = CheckBox.new()
	dynamic_body_button.text = "DynamicBody3D"
	dynamic_body_button.pressed.connect(func():
		do_dynamic_body_3d = dynamic_body_button.button_pressed
		if dynamic_body_button.button_pressed:
			dynamic_body_hbox.show()
		else:
			dynamic_body_hbox.hide())
	vbox.add_child(dynamic_body_button)
	
	vbox.add_child(dynamic_body_hbox)
	dynamic_body_hbox.hide()
	
	var convex_collision_button: CheckBox = CheckBox.new()
	convex_collision_button.text = "Collision"
	convex_collision_button.pressed.connect(func():
		do_convex_collision = convex_collision_button.button_pressed)
	dynamic_body_hbox.add_child(convex_collision_button)
	
	var small_body_button: CheckBox = CheckBox.new()
	small_body_button.text = "Small"
	small_body_button.pressed.connect(func():
		do_small_body = small_body_button.button_pressed)
	dynamic_body_hbox.add_child(small_body_button)
	
	EditorInterface.get_base_control().add_child(type_select_dialog)
	
	type_select_dialog.popup_centered()
	
	type_select_dialog.confirmed.connect(func():
		type_select_dialog.queue_free()
		_convert())





func _convert() -> void:
	if scenes_to_load.size() <= 0:
		print("Error: No scenes selected")
		return
	
	for scene in scenes_to_load:
		var scene_name: String = scene.rsplit("/", false, 1)[1]
		var output: String = scene.trim_suffix("/" + scene_name)
		scene_name = scene_name.trim_suffix(".obj")
		if only_collision_shape_3d:
			var root: CollisionShape3D = CollisionShape3D.new()
			root.name = "Col" + scene_name
			
			var mesh: Mesh = load(scene)
			root.shape = mesh.create_trimesh_shape()
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/Col" + scene_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
			
			print("---Complete---")
			return
		
		if !FileAccess.file_exists(output + "/Mesh" + scene_name + ".tscn"):
			var root: MeshInstance3D = MeshInstance3D.new()
			root.name = "Mesh" + scene_name
			
			var mesh: Mesh = load(scene)
			root.mesh = mesh
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/Mesh" + scene_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
		
		if do_static_body_3d:
			var root: StaticBody3D = StaticBody3D.new()
			root.name = "Static" + scene_name
			
			var pscene: PackedScene = load(output + "/Mesh" + scene_name + ".tscn")
			var mesh_instance: MeshInstance3D = pscene.instantiate()
			
			root.add_child(mesh_instance)
			mesh_instance.owner = root
			
			if do_trimesh_collision:
				var collision: CollisionShape3D = CollisionShape3D.new()
				collision.shape = mesh_instance.mesh.create_trimesh_shape()
				root.add_child(collision)
				collision.owner = root
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/Static" + scene_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
		
		if do_dynamic_body_3d:
			var root: DynamicObject3D = DynamicObject3D.new()
			root.name = "Dynamic" + scene_name
			
			var pscene: PackedScene = load(output + "/Mesh" + scene_name + ".tscn")
			var mesh_instance: MeshInstance3D = pscene.instantiate()
			
			root.add_child(mesh_instance)
			mesh_instance.owner = root
			
			mesh_instance.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
			
			if do_small_body:
				root.ignore_player = true
				root.max_distance = 1.2
				root.min_distance = 0.4
				root.mass = 0.4
				root.continuous_cd = true
			
			if do_convex_collision:
				var collision: CollisionShape3D = CollisionShape3D.new()
				collision.shape = mesh_instance.mesh.create_convex_shape()
				root.add_child(collision)
				collision.owner = root
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var save_error = ResourceSaver.save(new_pscene, output + "/Dynamic" + scene_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
	
	print("---Complete---")
