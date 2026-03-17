class_name ConverterContext
extends EditorContextMenuPlugin


var objs: Array[String] = []
var pngs: Array[String] = []


func _popup_menu(paths: PackedStringArray) -> void:
	for path in paths:
		if !path.ends_with(".obj") and !path.ends_with(".png"):
			return
	add_context_menu_item("Convert", _parse)


func _parse(paths: PackedStringArray) -> void:
	objs = []
	pngs = []
	
	for path in paths:
		if path.ends_with(".obj"):
			objs.append(path)
		elif path.ends_with(".png"):
			pngs.append(path)
	
	if !objs.is_empty():
		_configure_obj()
	if !pngs.is_empty():
		_convert_png()


var only_collision_shape_3d: bool = false
var do_static_body_3d: bool = false
var do_trimesh_collision: bool = false
var do_dynamic_body_3d: bool = false
var do_convex_collision: bool = false
var do_small_body: bool = false

func _configure_obj() -> void:
	only_collision_shape_3d = false
	do_static_body_3d = false
	do_trimesh_collision = false
	do_dynamic_body_3d = false
	do_convex_collision = false
	do_small_body = false
	
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
		_convert_obj())
	vbox.add_child(mesh_instance_button)
	
	var convex_only_button: Button = Button.new()
	convex_only_button.text = "ConvexOnlyCollision3D"
	convex_only_button.pressed.connect(func():
		only_collision_shape_3d = true
		do_trimesh_collision = false
		type_select_dialog.queue_free()
		_convert_obj())
	vbox.add_child(convex_only_button)
	
	var trimesh_only_button: Button = Button.new()
	trimesh_only_button.text = "TrimeshOnlyCollision3D"
	trimesh_only_button.pressed.connect(func():
		only_collision_shape_3d = true
		do_trimesh_collision = true
		type_select_dialog.queue_free()
		_convert_obj())
	vbox.add_child(trimesh_only_button)
	
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
		_convert_obj())


func _convert_obj() -> void:
	for scene in objs:
		var scene_name: String = scene.rsplit("/", false, 1)[1]
		var output: String = scene.trim_suffix("/" + scene_name)
		scene_name = scene_name.trim_suffix(".obj")
		if only_collision_shape_3d:
			var root: CollisionShape3D = CollisionShape3D.new()
			root.name = "Col" + scene_name
			
			var mesh: Mesh = load(scene)
			if do_trimesh_collision:
				root.shape = mesh.create_trimesh_shape()
			else:
				root.shape = mesh.create_convex_shape()
			
			var new_pscene: PackedScene = PackedScene.new()
			new_pscene.pack(root)
			
			var prefix: String = "/Trimesh" if do_trimesh_collision else "/Convex"
			
			var save_error = ResourceSaver.save(new_pscene, output + prefix + scene_name + ".tscn")
			if save_error != OK:
				print("ERROR: ", save_error)
			
			root.queue_free()
			
			print("---Complete---")
		
		else:
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


func _convert_png() -> void:
	var texture_groups: Dictionary[String, Array] = {}
	for texture_to_load in pngs:
		var file_name: String = texture_to_load.get_file().get_basename()
		file_name = file_name.get_slice("_", 0)
		if !texture_groups.has(file_name):
			texture_groups[file_name] = [texture_to_load]
		else:
			texture_groups[file_name].append(texture_to_load)
	
	for key in texture_groups:
		var texture_group = texture_groups.get(key)
		
		var output: String = texture_group[0].get_slice("_", 0)
		if !texture_group[0].contains("_"):
			output = texture_group[0].get_slice(".", 0)
		var material
		var do_orm_texture: bool = false
		for texture in texture_group:
			var texture_name: String = texture.get_file().get_basename()
			if texture_name.get_slice("_", 1) == "orm":
				do_orm_texture = true
		
		if do_orm_texture:
			material = ORMMaterial3D.new()
		else:
			material = StandardMaterial3D.new()
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		
		for texture_path in texture_group:
			var file_name: String = texture_path.get_file().get_basename()
			var file_suffix = file_name.get_slice("_", 1)
			
			var texture: CompressedTexture2D = load(texture_path)
			
			match file_suffix:
				"albedo":
					material.albedo_texture = texture
				"orm":
					material.orm_texture = texture
				"metallic":
					material.metallic_texture = texture
				"roughness":
					material.roughness_texture = texture
				"ao":
					material.ao_texture = texture
				"emission":
					material.emission_enabled = true
					material.emission_texture = texture
				"normal":
					material.normal_enabled = true
					material.normal_texture = texture
				_:
					if !texture_groups[key].size() > 1:
						material.albedo_texture = texture
		
		var save_error = ResourceSaver.save(material, output + ".tres")
		if save_error != OK:
			print("ERROR: ", save_error)
