@tool
extends EditorScript


var textures_to_load: PackedStringArray = []


func _run() -> void:
	_select_input()


func _select_input() -> void:
	var scenes_select_dialog = FileDialog.new()
	scenes_select_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	scenes_select_dialog.filters = ["*.png"]
	scenes_select_dialog.display_mode = FileDialog.DISPLAY_LIST
	
	EditorInterface.get_base_control().add_child(scenes_select_dialog)
	
	scenes_select_dialog.popup_centered(Vector2i(1280, 720))
	
	scenes_select_dialog.files_selected.connect(func(paths: PackedStringArray):
		textures_to_load = paths.duplicate()
		print("Scenes: ", textures_to_load)
		scenes_select_dialog.queue_free()
		_convert())


func _convert() -> void:
	if textures_to_load.size() <= 0:
		print("Error: No scenes selected")
		return
	
	var texture_groups: Dictionary[String, Array] = {}
	for texture_to_load in textures_to_load:
		var file_name: String = texture_to_load.get_file().get_basename()
		file_name = file_name.get_slice("_", 0)
		if !texture_groups.has(file_name):
			texture_groups[file_name] = [texture_to_load]
		else:
			texture_groups[file_name].append(texture_to_load)
	
	for key in texture_groups:
		var texture_group = texture_groups.get(key)
		
		var output: String = texture_group[0].get_slice("_", 0)
		print(texture_group[0].get_slice("_", 0))
		
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
					return
		
		var save_error = ResourceSaver.save(material, output + ".tres")
		if save_error != OK:
			print("ERROR: ", save_error)
	
	print("---Complete---")
