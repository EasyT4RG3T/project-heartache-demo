extends Node


signal save_requsted(save_data: Dictionary)


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
	_queue_function(_save_game_data, slot)

func load_game_data(slot: int) -> void:
	_queue_function(_load_game_data, slot)

func erase_game_data(slot: int) -> void:
	_queue_function(_erase_game_data, slot)

func save_temp() -> void:
	_queue_function(_save_temp)

func load_temp() -> void:
	_queue_function(_load_temp)


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	stop_thread = false
	load_thread.start(_thread_worker)
	
	await get_tree().process_frame
	
	load_settings()
	load_graphics_settings(0)
	
	var kgjal: GraphicsSettingsResource = load("uid://b1jvwhit3o0bc")
	
	print(kgjal.brightness)


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
			graphics_settings = GRAPHICS_SETTINGS_LOW
		2:
			graphics_settings = GraphicsSettingsResource.new()
			graphics_settings = GRAPHICS_SETTINGS_MEDIUM
		3:
			graphics_settings = GraphicsSettingsResource.new()
			graphics_settings = GRAPHICS_SETTINGS_HIGH
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


func _save_game_data(slot) -> void:
	save_requsted.emit()
	print("save game on slot: ", slot)


func _load_game_data(slot) -> void:
	print("load game from slot: ", slot)


func _erase_game_data(slot) -> void:
	print("erased game from slot: ", slot)

















#func save_game_data(slot: int = 0) -> String:
#	if not DirAccess.dir_exists_absolute(GAME_DATA_PATH):
#		DirAccess.make_dir_recursive_absolute(GAME_DATA_PATH)
#	
#	var save_data: Dictionary = {}
#	save_requsted.emit(save_data)
#	
#	if FileAccess.file_exists(GAME_DATA_PATH + "temp.dat"):
#		var file_read = FileAccess.open(GAME_DATA_PATH + "temp.dat", FileAccess.READ)
#		if !file_read:
#			return "error saving game data to slot " + str(slot) + ", couldn't open temp file"
#		
#		# add data from save_data to file_read data and ovverride existing data?
#		
#		file_read.close()
#	
#	var file = FileAccess.open(GAME_DATA_PATH + "slot_" + str(slot) + ".dat", FileAccess.WRITE)
#	if !file:
#		return "error saving game data to slot " + str(slot) + ", couldn't create the file"
#	
#	file.store_8(GameManager.GAME_VERSION_1)
#	file.store_8(GameManager.GAME_VERSION_2)
#	file.store_8(GameManager.GAME_VERSION_3)
#	
#	var time = Time.get_datetime_string_from_system()
#	file.store_32(Time.get_unix_time_from_datetime_string(time))
#	
#	var data_byte = var_to_bytes(save_data)
#	file.store_buffer(data_byte)
#	file.close()
#	
#	return "saved game data in slot " + str(slot)


#func load_game_data(slot: int = 0) -> String:
#	if !FileAccess.file_exists(GAME_DATA_PATH + "slot_" + str(slot) + ".dat"):
#		return "error loading game data slot " + str(slot) + ", file doesn't exist"
#	
#	var file = FileAccess.open(GAME_DATA_PATH + "slot_" + str(slot) + ".dat", FileAccess.READ)
#	if !file:
#		return "error loading game data slot " + str(slot) + ", couldn't open file"
#	
#	var version_1 = file.get_8()
#	var version_2 = file.get_8()
#	if version_1 != GameManager.GAME_VERSION_1 or version_2 != GameManager.GAME_VERSION_2:
#		return "error loading game data slot " + str(slot) + ", version missmatch"
#	file.seek(7)
#	
#	var data_byte = file.get_buffer(file.get_length() - 7)
#	file.close()
#	
#	var save_data = bytes_to_var(data_byte)
#	if save_data is not Dictionary:
#		return "error loading game data slot " + str(slot) + ", not dictionary"
#	
#	load_requested.emit(save_data)
#	
#	return "loaded game data from slot " + str(slot)


func delete_game_data(slot: int = 0) -> String:
	if !FileAccess.file_exists(GAME_DATA_PATH + "slot_" + str(slot)):
		return "error deleteing game data slot " + str(slot) + ", file not found"
	
	var error = DirAccess.remove_absolute(GAME_DATA_PATH + "slot_" + str(slot))
	if error == OK:
		return "deleted game data slot " + str(slot)
	else:
		return "error deleting game data slot " + str(slot) + ", " + error


func _save_temp(save_data: Dictionary) -> String:
	if not DirAccess.dir_exists_absolute(GAME_DATA_PATH):
		DirAccess.make_dir_recursive_absolute(GAME_DATA_PATH)
	
	var temp_data: Dictionary = {}
	
	if FileAccess.file_exists(GAME_DATA_PATH + "temp.dat"):
		var file_read = FileAccess.open(GAME_DATA_PATH + "temp.dat", FileAccess.READ)
		if !file_read:
			return "error saving temp game data, couldn't open file"
		
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		temp_data = bytes_to_var(read_data_byte)
		file_read.close()
	
	for key in save_data:
		temp_data[key] = save_data[key]
	
	var file_write = FileAccess.open(GAME_DATA_PATH + "temp.dat", FileAccess.WRITE)
	if !file_write:
		return "error saving temp game data, couldn't create the file"
	
	var write_data_byte = var_to_bytes(temp_data)
	file_write.store_buffer(write_data_byte)
	file_write.close()
	
	return "saved temporary game data"


func _load_temp() -> String:
	if !FileAccess.file_exists(GAME_DATA_PATH + "temp.dat"):
		return "error loading temp game data, file doesn't exist"
	
	var file_read = FileAccess.open(GAME_DATA_PATH + "temp.dat", FileAccess.READ)
	if !file_read:
		return "error loading temp game data, couldn't open file"
	
	return "loaded temporary game data"


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
