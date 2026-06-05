extends Node3D


#const LOADING_ZONES = preload("uid://ba6jx3djjul6n")
#var loading_zones: Node3D
#const new_game_uids: Array[String] = ["uid://cn6i15e2ohyv5", "uid://cxen7otwqul1c", "uid://b11ecofofpu70", "uid://c1xomtgke6hfn"]

const demo_uid: String = "uid://ly2qmf1awigs"


var story_description: String = "":
	set(value):
		story_description = value
		if GameManager.journal:
			GameManager.journal.quest_rich_text_label.text = story_description

var running: bool = false:
	set(value):
		running = value
		if value == true:# and !loading_zones:
			SaverLoader.can_chunk_save = 0
			#loading_zones = LOADING_ZONES.instantiate()
			#add_child(loading_zones)
			AudioManager.play_ambient("uid://c1auf3n2ayc5b", -10.0, 1.0)


var objects_to_load: int = 0:
	set(value):
		objects_to_load = value
		SaverLoader.progress_message = "Loading Objects: " + str(objects_loaded) + " / " + str(value)
var objects_loaded: int = 0:
	set(value):
		objects_loaded = value
		SaverLoader.progress_message = "Loading Objects: " + str(value) + " / " + str(objects_to_load)


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	child_entered_tree.connect(func(node: Node):
		node.process_mode = Node.PROCESS_MODE_PAUSABLE)


func get_chunks() -> Array:
	var chunks: Array[Node]
	for child: Node in get_children():
		if child is PlayerCharacter: continue
		if child.name == "LoadingZones": continue
		chunks.append(child)
	return chunks


func clear() -> void:
	SaverLoader.can_chunk_save = 1
	SaverLoader.clear_temp()
	for child in get_children():
		child.queue_free()
	#loading_zones = null


func save() -> Dictionary:
	SaverLoader.can_chunk_save = 1
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
	
	SaverLoader.can_chunk_save = 0
	return data


func new_game() -> void:
	#for chunk in new_game_uids:
	#	await load_chunk(chunk)
	
	await load_chunk(demo_uid)
	
	story_description = "I should go to the cafeteria, everyone's already waiting"
	
	return


func load_save(data: Dictionary) -> void:
	story_description = data["data"]["story_description"]
	
	for current_chunk_uid in data["current_chunks_uid"]:
		await load_chunk(current_chunk_uid, data["chunks"][current_chunk_uid])
	
	return


func save_chunk(chunk: Node) -> Dictionary:
	var data: Dictionary = {}
	
	data[ResourceUID.path_to_uid(chunk.scene_file_path)] = save_deep(chunk)
	
	return data


func load_chunk(chunk_uid: String, data: Dictionary = {}) -> void:
	var chunk_pscene: PackedScene = await SaverLoader.thread_load(chunk_uid)
	assert(chunk_pscene != null, "Couldn't load chunk")
	
	var chunk = chunk_pscene.instantiate()
	add_child(chunk)
	
	if data.is_empty():
		if chunk.has_method("first_setup"):
			chunk.first_setup()
		return
	
	_count_data(data)
	
	load_deep(chunk, data)
	
	objects_to_load = 0
	objects_loaded = 0


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


func load_deep(node: Node, data: Dictionary, used: Array = []) -> void:
	if data.has("Data") and node.has_method("load_save"):
		objects_loaded += 1
		node.load_save(data["Data"])
		if !used.has(node):
			used.append(node)
	
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
						used.append(child_node)
						load_deep(child_node, child_data[i], used)
			else:
				var child_node: Node
				if matching_children.size() > 0:
					child_node = matching_children[0]
					used.append(child_node)
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
					used.append(child_node)
					load_deep(child_node, child_data, used)
	
	if node.has_method("save") and !used.has(node):
		node.queue_free()
	for child in node.get_children():
		load_deep(child, {}, used)


func _count_data(data: Dictionary) -> void:
	if data.has("Data"):
		objects_to_load += 1
	if data.has("Children"):
		for child in data["Children"]:
			var child_data = data["Children"][child]
			if child_data is Array:
				for i in child_data.size():
					_count_data(child_data[i])
			else:
				_count_data(child_data)
