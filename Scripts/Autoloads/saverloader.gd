extends Node


@warning_ignore("unused_signal")
signal GameSaved

const SETTINGS_VERSION: int = 1
const accept_menu_uid: String = "uid://dckjpcj38rsvw"

var settings: SettingsResource
var graphics_settings: GraphicsSettingsResource
var dynamic_lights_changed: bool = false

var load_thread: Thread = Thread.new()

var queue_semaphore: Semaphore = Semaphore.new()
var stop_thread: bool = false
var function_queue: Array = []


var GAME_PATH = OS.get_data_dir() + "/project_heartache/"
var SETTINGS_PATH = GAME_PATH + "settings.json"
var GRAPHICS_SETTINGS_PATH = GAME_PATH + "graphics_settings.json"
var GAME_DATA_PATH = GAME_PATH + "saves/"


var can_save: int = 1
var current_slot: String = "0":
	set(value):
		current_slot = value
		settings.last_save = value
		save_settings()


func save_settings() -> void:
	_queue_function(_save_settings_data)

func load_settings() -> void:
	_queue_function(_load_settings_data)

func erase_settings() -> void:
	_queue_function(_erase_settings_data)

func save_graphics_settings() -> void:
	_queue_function(_save_graphics_settings_data)

func load_graphics_settings(preset: int) -> void:
	_queue_function(_load_graphics_settings_data, preset)

func erase_graphics_settings() -> void:
	_queue_function(_erase_graphics_settings_data)

func save_game_data(slot: String) -> void:
	if can_save > 0:
		Console.console_print(str("[color=red]actions blocking saving: ", can_save, "[/color]"))
		return
	if slot == "temp":
		Console.console_print("[color=red]Invalid Slot[/color]")
	var hidden_menus: Array = []
	for menu in get_tree().get_nodes_in_group("Menu"):
		if menu.visible:
			menu.hide()
			hidden_menus.append(menu)
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	for menu in hidden_menus:
		menu.show()
	image.resize(256, 144)
	image.save_png(GAME_DATA_PATH + slot + ".png")
	var save_data: Dictionary = {}
	GameManager.save(save_data)
	_queue_function(_save_game_data, [slot, save_data])

func load_game_data(slot: String) -> void:
	if slot == "temp":
		Console.console_print("[color=red]Invalid Slot[/color]")
	_queue_function(_load_game_data, slot)

func erase_game_data(slot: String) -> void:
	_queue_function(_erase_game_data, slot)

func save_chunk_data(chunk: Node) -> void:
	var save_data: Dictionary = {}
	Game.save_chunk(chunk)
	_queue_function(_save_chunk_data, [ResourceUID.path_to_uid(chunk.scene_file_path), save_data])

func load_chunk_data(chunk_uid: String) -> void:
	_queue_function(_load_chunk_data, chunk_uid)

func thread_load(path: String) -> Resource:
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().physics_frame
	
	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		print("couldn't load resource")
		return
	
	return ResourceLoader.load_threaded_get(path)


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	stop_thread = false
	load_thread.start(_thread_worker)
	
	await get_tree().process_frame
	
	load_settings()
	load_graphics_settings(0)


func _exit_tree() -> void:
	stop_thread = true
	queue_semaphore.post()
	if load_thread.is_started():
		load_thread.wait_to_finish()


func _queue_function(function: Callable, arg = null) -> void:
	function_queue.append({"func": function, "args": arg})
	queue_semaphore.post()


func _thread_worker() -> void:
	while stop_thread == false:
		queue_semaphore.wait()
		
		if stop_thread:
			break
		
		while function_queue.size() > 0 and not stop_thread:
			var function = function_queue.pop_front()
			_process_function(function)


func _process_function(function: Dictionary) -> void:
	if function.args:
		function.func.call(function.args)
	else:
		function.func.call()


func _save_settings_data() -> void:
	var data = _resource_to_dict(settings)
	var error: String = _save_to_json(SETTINGS_PATH, data)
	Console.call_deferred("console_print", "settings data: " + error)


func _load_settings_data() -> void:
	settings = SettingsResource.new()
	var error_data: Array = _load_from_json(SETTINGS_PATH)
	var error = error_data[0]
	var data = error_data[1] if error_data.size() > 1 else null
	
	if !data:
		Console.call_deferred("console_print", "settings data: " + error)
		_save_settings_data()
		GameManager.call_deferred("apply_settings_data")
		return
	
	_resource_from_dict(data, settings)
	GameManager.call_deferred("apply_settings_data")
	Console.call_deferred("console_print", "settings data: " + error)


func _erase_settings_data() -> void:
	settings = SettingsResource.new()
	var error: String = _remove_json(SETTINGS_PATH)
	GameManager.call_deferred("apply_settings_data")
	Console.call_deferred("console_print", "settings data: " + error)


func _save_graphics_settings_data() -> void:
	var data = _resource_to_dict(graphics_settings)
	var error: String = _save_to_json(GRAPHICS_SETTINGS_PATH, data)
	Console.call_deferred("console_print", "graphics settings data: " + error)


func _load_graphics_settings_data(preset: int = 0) -> void:
	match preset:
		0:
			graphics_settings = GraphicsSettingsResource.new()
			var error_data: Array = _load_from_json(GRAPHICS_SETTINGS_PATH)
			var error = error_data[0]
			var data = error_data[1] if error_data.size() > 1 else null
			
			if !data:
				Console.call_deferred("console_print", "graphics settings data: " + error)
				_save_graphics_settings_data()
				GameManager.call_deferred("apply_graphics_settings_data")
				return
			
			_resource_from_dict(data, graphics_settings)
		1:
			graphics_settings = GraphicsSettingsResource.new()
			var sett: GraphicsSettingsResource = load("uid://cutv363x14c4e")
			graphics_settings = sett
		2:
			graphics_settings = GraphicsSettingsResource.new()
			var sett: GraphicsSettingsResource = load("uid://cr40bmj55qsks")
			graphics_settings = sett
		3:
			graphics_settings = GraphicsSettingsResource.new()
			var sett: GraphicsSettingsResource = load("uid://cn4cbbs6h71o1")
			graphics_settings = sett
		_:
			Console.call_deferred("console_print", "graphics settings data: invalid preset")
			return
	
	Console.call_deferred("console_print", "graphics settings data: loaded")
	GameManager.call_deferred("apply_graphics_settings_data")


func _erase_graphics_settings_data() -> void:
	graphics_settings = GraphicsSettingsResource.new()
	var error: String = _remove_json(GRAPHICS_SETTINGS_PATH)
	Console.call_deferred("console_print", "graphics settings data: " + error)
	GameManager.call_deferred("apply_graphics_settings_data")


func _save_to_json(path: String, data: Dictionary) -> String:
	if not DirAccess.dir_exists_absolute(GAME_PATH):
		DirAccess.make_dir_recursive_absolute(GAME_PATH)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if !file:
		return "couldn't create the file"
	
	file.store_8(SETTINGS_VERSION)
	file.store_string(JSON.stringify(data, "\t", false))
	file.close()
	
	return "saved"


func _load_from_json(path: String) -> Array:
	if !FileAccess.file_exists(path):
		return ["no settings file, created new settings data"]
	
	var file = FileAccess.open(path, FileAccess.READ)
	if !file:
		return ["file didn't load"]
	
	var version = file.get_8()
	if version != SETTINGS_VERSION:
		file.close()
		return ["wrong version"]
	
	var file_text = file.get_as_text()
	file.close()
	
	var json = JSON.parse_string(file_text)
	if json is not Dictionary:
		return ["not dictionary"]
	
	return ["loaded", json]


func _remove_json(path: String) -> String:
	if not DirAccess.dir_exists_absolute(GAME_PATH):
		return "game folder doesn't exist"
	
	var file = FileAccess.file_exists(path)
	if !file:
		return "file doesn't exist"
	else:
		var dir_error = DirAccess.remove_absolute(path)
		if dir_error == OK:
			return "removed data"
		else:
			return "couldn't remove data"


func _resource_to_dict(resource: Resource) -> Dictionary:
	var data: Dictionary = {}
	
	for property in resource.get_property_list():
		var prop_name = property["name"]
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE and\
		   property["usage"] & PROPERTY_USAGE_STORAGE:
			data[prop_name] = resource.get(prop_name)
	
	return data


func _resource_from_dict(dictionary: Dictionary, resource: Resource) -> void:
	for key in dictionary:
		if resource.has_method("set"):
			resource.set(key, dictionary[key])


func _save_game_data(data: Array) -> void:
	var slot: String = data[0]
	
	if not DirAccess.dir_exists_absolute(GAME_DATA_PATH):
		DirAccess.make_dir_recursive_absolute(GAME_DATA_PATH)
	
	var game_data: Dictionary = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + slot + ".dat"):
		var file_read = FileAccess.open(GAME_DATA_PATH + slot + ".dat", FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "game data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		game_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	if !game_data.has("game"):
		game_data["game"] = {}
	if !game_data["game"].has("data"):
		game_data["game"]["data"] ={}
	if !game_data["game"].has("current_chunks_uid"):
		game_data["game"]["current_chunks_uid"] = {}
	if !game_data["game"].has("chunks"):
		game_data["game"]["chunks"] = {}
	
	var temp_data: Dictionary = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + "temp"):
		var file_read = FileAccess.open(GAME_DATA_PATH + "temp", FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "game temp data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		temp_data = bytes_to_var(read_data_byte)
		file_read.close()
		
		var error = DirAccess.remove_absolute(GAME_DATA_PATH + "temp")
		if error == OK:
			Console.call_deferred("console_print", "temp game data deleted")
		else:
			Console.call_deferred("console_print", "temp game data: " + error)
	
	if !temp_data.has("game"):
		temp_data["game"] = {}
	if !temp_data["game"].has("data"):
		temp_data["game"]["data"] = {}
	if !temp_data["game"].has("current_chunks_uid"):
		temp_data["game"]["current_chunks_uid"] = {}
	if !temp_data["game"].has("chunks"):
		temp_data["game"]["chunks"] = {}
	
	for chunk in temp_data["game"]["chunks"]:
		game_data["game"]["chunks"][chunk] = temp_data["game"]["chunks"][chunk]
	
	var save_data: Dictionary = data[1]
	
	game_data["player"] = save_data["player"]
	
	game_data["game"]["data"] = save_data["game"]["data"]
	game_data["game"]["current_chunks_uid"] = save_data["game"]["current_chunks_uid"]
	
	for chunk in save_data["game"]["chunks"]:
		game_data["game"]["chunks"][chunk] = save_data["game"]["chunks"][chunk]
	
	game_data["system"] = {
		"datetime": Time.get_datetime_string_from_system(false, true),
	}
	if !game_data["system"].has("version"):
		game_data["system"]["version"] = ProjectSettings.get_setting("application/config/version")
	
	var file_write = FileAccess.open(GAME_DATA_PATH + slot + ".dat", FileAccess.WRITE)
	if !file_write:
		Console.call_deferred("console_print", "game data: couldn't create the file")
		return
	
	var write_data_byte = var_to_bytes(game_data)
	file_write.store_buffer(write_data_byte)
	file_write.close()
	
	Console.call_deferred("console_print", "game data: saved in slot " + slot)
	call_deferred("emit_signal", "GameSaved")


func _load_game_data(slot: String) -> void:
	if !FileAccess.file_exists(GAME_DATA_PATH + slot + ".dat"):
		Console.call_deferred("console_print", "game data: file doesn't exist")
		return
	
	var file_read = FileAccess.open(GAME_DATA_PATH + slot + ".dat", FileAccess.READ)
	if !file_read:
		Console.call_deferred("console_print", "game data: couldn't open file")
		return
	
	var game_data: Dictionary = {}
	
	var read_data_byte = file_read.get_buffer(file_read.get_length())
	game_data = bytes_to_var(read_data_byte)
	file_read.close()
	
	if game_data["system"]["version"] != ProjectSettings.get_setting("application/config/version"):
		call_deferred("_load_version_alert", game_data, slot)
		return
	
	GameManager.call_deferred("load_save", game_data)
	
	Console.call_deferred("console_print", "game data: loaded from slot " + slot)
	
	current_slot = slot
	
	clear_temp()


func _load_version_alert(game_data: Dictionary, slot: String) -> void:
	var previous_menu = InputManager.menu
	var accept_menu_packed: PackedScene = load(accept_menu_uid)
	var accept_menu: AcceptMenu = accept_menu_packed.instantiate()
	accept_menu.message = "Loading a save from a different game version/nAre you sure you want to continue?"
	accept_menu.accept_text = "Yes, load anyway"
	accept_menu.cancel_text = "No, abort"
	get_tree().root.add_child(accept_menu)
	accept_menu.accepted.connect(func():
		accept_menu.queue_free()
		GameManager.load_save(game_data)
		Console.console_print("game data: different version loaded from slot " + slot)
		current_slot = slot
		clear_temp())
	accept_menu.cancelled.connect(func():
		accept_menu.queue_free()
		InputManager.menu = previous_menu)
	InputManager.menu = accept_menu


func _erase_game_data(slot: String) -> void:
	if !FileAccess.file_exists(GAME_DATA_PATH + slot + ".dat"):
		Console.call_deferred("console_print", "game data: slot " + slot + ", file not found")
	
	if FileAccess.file_exists(GAME_DATA_PATH + slot + ".png"):
		DirAccess.remove_absolute(GAME_DATA_PATH + slot + ".png")
	
	var error = DirAccess.remove_absolute(GAME_DATA_PATH + slot + ".dat")
	if error == OK:
		Console.call_deferred("console_print", "game data: deleted slot " + slot)
	else:
		Console.call_deferred("console_print", "game data: slot " + slot + ", " + error)


func _save_chunk_data(data: Array) -> void:
	var uid: String = data[0]
	if not DirAccess.dir_exists_absolute(GAME_DATA_PATH):
		DirAccess.make_dir_recursive_absolute(GAME_DATA_PATH)
	
	var game_data: Dictionary = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + "temp"):
		var file_read = FileAccess.open(GAME_DATA_PATH + "temp", FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "chunk game data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		game_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	var save_data: Dictionary = data[1]
	
	if !game_data.has("game"):
		game_data["game"] = {}
	if !game_data["game"].has("chunks"):
		game_data["chunks"] = {}
	game_data["game"]["chunks"][uid] = save_data[uid]
	
	var file_write = FileAccess.open(GAME_DATA_PATH + "temp", FileAccess.WRITE)
	if !file_write:
		Console.call_deferred("console_print", "chunk game data: couldn't create the file")
		return
	
	var write_data_byte = var_to_bytes(game_data)
	file_write.store_buffer(write_data_byte)
	file_write.close()
	
	Console.call_deferred("console_print", "chunk game data: saved")


func _load_chunk_data(chunk_uid: String) -> void:
	var game_data = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + "temp"):
		var file_read = FileAccess.open(GAME_DATA_PATH + "temp", FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "chunk game data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		game_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	if game_data.has("game"):
		if game_data["game"].has("chunks"):
			if game_data["game"]["chunks"].has(chunk_uid):
				Game.call_deferred("load_chunk", chunk_uid, game_data["game"]["chunks"][chunk_uid])
				return
	
	if FileAccess.file_exists(GAME_DATA_PATH + current_slot):
		var file_read = FileAccess.open(GAME_DATA_PATH + current_slot, FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "game data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		game_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	if game_data.has("game"):
		if game_data["game"].has("chunks"):
			if game_data["game"]["chunks"].has(chunk_uid):
				Game.call_deferred("load_chunk", chunk_uid, game_data["game"]["chunks"][chunk_uid])
				return
	
	Game.call_deferred("load_chunk", chunk_uid)


func clear_temp() -> void:
	if !FileAccess.file_exists(GAME_DATA_PATH + "temp"):
		return
	var error = DirAccess.remove_absolute(GAME_DATA_PATH + "temp")
	if error == OK:
		Console.call_deferred("console_print", "temp game data deleted")
	else:
		Console.call_deferred("console_print", "temp game data: " + error)


func _override_dic_deep(old: Dictionary, new: Dictionary) -> Dictionary:
	for key in new:
		if old.has(key) and key is Dictionary:
			old[key] = _override_dic_deep(old[key], new[key])
		old[key] = new[key]
	
	return old
