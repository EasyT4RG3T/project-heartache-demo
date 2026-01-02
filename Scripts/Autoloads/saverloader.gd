extends Node


const GAME_VERSION: int = 1
const SETTINGS_VERSION: int = 1

var settings: SettingsResource
var graphics_settings: GraphicsSettingsResource
var GRAPHICS_SETTINGS_HIGH: GraphicsSettingsResource
var GRAPHICS_SETTINGS_LOW: GraphicsSettingsResource
var GRAPHICS_SETTINGS_MEDIUM: GraphicsSettingsResource


var load_thread: Thread = Thread.new()

var queue_semaphore: Semaphore = Semaphore.new()
var stop_thread: bool = false
var function_queue: Array = []


var GAME_PATH = OS.get_data_dir() + "/project_heartache/"
var SETTINGS_PATH = GAME_PATH + "settings.json"
var GRAPHICS_SETTINGS_PATH = GAME_PATH + "graphics_settings.json"
var GAME_DATA_PATH = GAME_PATH + "saves/"


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

func save_game_data(slot: int) -> void:
	var save_data: Dictionary = {}
	GameManager.save(save_data)
	_queue_function(_save_game_data, [slot, save_data])

func load_game_data(slot: int) -> void:
	_queue_function(_load_game_data, slot)

func load_chunk_data(slot: int, chunk: String) -> void:
	_queue_function(_load_chunk_data, [slot, chunk])

func erase_game_data(slot: int) -> void:
	_queue_function(_erase_game_data, slot)


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
	var slot: int = data[0]
	
	if not DirAccess.dir_exists_absolute(GAME_DATA_PATH):
		DirAccess.make_dir_recursive_absolute(GAME_DATA_PATH)
	
	var game_data: Dictionary = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + str(slot)):
		var file_read = FileAccess.open(GAME_DATA_PATH + str(slot), FileAccess.READ)
		if !file_read:
			Console.call_deferred("console_print", "game data: couldn't open file")
			return
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		game_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	var save_data: Dictionary = data[1]
	
	for key in save_data:
		game_data[key] = save_data[key]
	
	var file_write = FileAccess.open(GAME_DATA_PATH + str(slot), FileAccess.WRITE)
	if !file_write:
		Console.call_deferred("console_print", "game data: couldn't create the file")
		return
	
	var write_data_byte = var_to_bytes(game_data)
	file_write.store_buffer(write_data_byte)
	file_write.close()
	
	Console.call_deferred("console_print", "game data: saved in slot " + str(slot))
	return


func _load_game_data(slot: int) -> void:
	if !FileAccess.file_exists(GAME_DATA_PATH + str(slot)):
		Console.call_deferred("console_print", "game data: file doesn't exist")
		return
	
	var file_read = FileAccess.open(GAME_DATA_PATH + str(slot), FileAccess.READ)
	if !file_read:
		Console.call_deferred("console_print", "game data: couldn't open file")
		return
	
	var game_data: Dictionary = {}
	
	var read_data_byte = file_read.get_buffer(file_read.get_length())
	game_data = bytes_to_var(read_data_byte)
	file_read.close()
	
	GameManager.call_deferred("load_save", game_data)
	
	Console.call_deferred("console_print", "game data: loaded from slot " + str(slot))
	return


func _load_chunk_data(slot: int, chunk: String) -> void:
	print(slot, chunk)


func _erase_game_data(slot) -> void:
	if !FileAccess.file_exists(GAME_DATA_PATH + str(slot)):
		Console.call_deferred("console_print", "game data: slot " + str(slot) + ", file not found")
	
	var error = DirAccess.remove_absolute(GAME_DATA_PATH + str(slot))
	if error == OK:
		Console.call_deferred("console_print", "game data: deleted slot " + str(slot))
	else:
		Console.call_deferred("console_print", "game data: slot " + str(slot) + ", " + error)
