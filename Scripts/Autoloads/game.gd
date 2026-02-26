extends Node3D


var story_description: String = "I had that nightmare again."


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	child_entered_tree.connect(func(node: Node):
		node.process_mode = Node.PROCESS_MODE_PAUSABLE)


func character_say(character: PlayerHUD.Characters, text: String, time: float = 0) -> RichTextLabel:
	return GameManager.player_character.player_hud.add_dialogue(character, text, time)


func get_chunks() -> Array:
	var chunks: Array[Node]
	for child: Node in get_children():
		if child is PlayerCharacter: continue
		chunks.append(child)
	return chunks


func clear() -> void:
	for child in get_children():
		child.queue_free()


func save() -> Dictionary:
	var data: Dictionary = {}
	
	data["data"] = {
		"story_description": story_description,
	}
	
	var current_chunks: Array[String] = []
	for current_chunk: Node in get_chunks():
		current_chunks.append(ResourceUID.path_to_uid(current_chunk.scene_file_path))
	data["current_chunks_uid"] = current_chunks
	
	var chunks_dic: Dictionary = {}
	for chunk: Node in get_chunks():
		chunks_dic[ResourceUID.path_to_uid(chunk.scene_file_path)] = save_deep(chunk)
	
	data["chunks"] = chunks_dic
	
	return data


func load_save(data: Dictionary) -> void:
	story_description = data["data"]["story_description"]
	
	for current_chunk_uid in data["current_chunks_uid"]:
		await load_chunk(current_chunk_uid, data["chunks"][current_chunk_uid])


func save_chunk(chunk: Node) -> Dictionary:
	var data: Dictionary = {}
	
	data[ResourceUID.path_to_uid(chunk.scene_file_path)] = save_deep(chunk)
	
	return data


func load_chunk(chunk_uid: String, data: Dictionary = {}) -> void:
	var chunk_pscene: PackedScene = await SaverLoader.thread_load(chunk_uid)
	assert(chunk_pscene != null, "Couldn't load chunk")
	
	var chunk = chunk_pscene.instantiate()
	add_child(chunk)
	
	if data.is_empty(): return
	
	load_deep(chunk, data)


func save_deep(node: Node) -> Dictionary:
	var data: Dictionary = {}
	
	if node.has_method("save"):
		data["Data"] = node.save()
	
	var children_dict = {}
	for child in node.get_children():
		var child_result = save_deep(child)
		if !child_result.is_empty():
			var child_uid: String
			if child.scene_file_path.is_empty():
				child_uid = child.name
			else:
				child_uid = ResourceUID.path_to_uid(child.scene_file_path)
			
			if !children_dict.has(child_uid):
				children_dict[child_uid] = []
			children_dict[child_uid].append(child_result)
	
	if !children_dict.is_empty():
		data["Children"] = children_dict
	
	return data


func load_deep(node: Node, data: Dictionary) -> void:
	if data.has("Data") and node.has_method("load_save"):
		node.load_save(data["Data"])
	
	if data.has("Children"):
		var children_key: Dictionary = {}
		for child in node.get_children():
			var child_key: String
			if child.scene_file_path.is_empty():
				child_key = child.name
			else:
				child_key = ResourceUID.path_to_uid(child.scene_file_path)
			
			if !children_key.has(child_key):
				children_key[child_key] = []
			children_key[child_key].append(child)
		
		var used_children: Array = []
		
		for key in data["Children"]:
			var child_data = data["Children"][key]
			var matching_children = children_key.get(key, [])
			
			if child_data is Array:
				for i in child_data.size():
					var child_node: Node
					if i < matching_children.size():
						child_node = matching_children[i]
					else:
						var path: String = ResourceUID.uid_to_path(key)
						if path:
							var resource: PackedScene = load(path)
							child_node = resource.instantiate()
						else:
							child_node = Node3D.new()
							child_node.name = key
						
						if child_node:
							node.add_child(child_node)
							child_node.owner = node.owner
					if child_node:
						used_children.append(child_node)
						load_deep(child_node, child_data[i])
			else:
				var child_node: Node
				if matching_children.size() > 0:
					child_node = matching_children[0]
					used_children.append(child_node)
				else:
					var path: String = ResourceUID.uid_to_path(key)
					if path:
						var resource: PackedScene = load(path)
						child_node = resource.instantiate()
					else:
						child_node = Node3D.new()
						child_node.name = key
					
					if child_node:
						node.add_child(child_node)
						child_node.owner = node.owner
				if child_node:
					used_children.append(child_node)
					load_deep(child_node, child_data)
		
		for child in node.get_children():
			if !used_children.has(child) and child.has_method("save"):
				child.queue_free()
