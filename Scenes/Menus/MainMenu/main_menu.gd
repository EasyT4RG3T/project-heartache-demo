extends Control


@onready var demo_button: Button = %DemoButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var chunk_button: Button = %ChunkButton
@onready var map_select: OptionButton = %MapSelect


var maps: Dictionary = {}


func _ready() -> void:
	_setup_map_select("res://Scenes/Maps/")
	chunk_button.pressed.connect(func():
		GameManager.load_chunk(maps[str(map_select.get_selected_id())])
		self.queue_free())
	quit_button.pressed.connect(func(): get_tree().quit.call_deferred())


func _setup_map_select(dir: String, folders: Array = []) -> void:
	if !folders:
		var base_dir = DirAccess.open(dir)
		
		if !base_dir:
			print("ERROR: " + str(dir))
			return
		
		var new_folders = base_dir.get_directories()
		
		if !new_folders:
			print("ERROR: empty directory")
			return
		
		_setup_map_select(dir, new_folders)
	
	for folder: String in folders:
		var base_dir = DirAccess.open(dir + str(folder) + "/")
		
		if !base_dir:
			print("ERROR: " + str(folder))
			return
		
		var new_files = base_dir.get_files()
		var new_folders = base_dir.get_directories()
		
		if new_files:
			for file in new_files:
				if file.contains(".tscn"):
					var map_index = maps.size()
					maps[str(map_index)] = dir + folder + "/" + file
					map_select.add_item(file.rstrip(".tscn"), map_index)
		if new_folders:
			_setup_map_select(dir + str(folder) + "/", new_folders)
