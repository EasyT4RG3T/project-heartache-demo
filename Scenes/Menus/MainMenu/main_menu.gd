extends Control

@onready var start: Control = %Start

@onready var start_new_game_button: Button = %NewGameButton
@onready var start_continue_button: Button = %ContinueButton
@onready var start_load_game_button: Button = %LoadGameButton
@onready var start_settings_button: Button = %SettingsButton
@onready var start_quit_button: Button = %QuitButton
@onready var start_chunk_button: Button = %ChunkButton
@onready var start_map_select: OptionButton = %MapSelect
@onready var version_label: Label = %VersionLabel


const settings_menu_uid: String = "uid://0ogoc8tlkqfx"
const saves_menu_uid: String = "uid://cs7mrt6rnpmfp"
const accept_menu_uid: String = "uid://dckjpcj38rsvw"

var maps: Dictionary = {}


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		start_quit_button.pressed.emit()


func _ready() -> void:
	InputManager.menu = self
	
	version_label.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	_setup_map_select("res://Scenes/Maps/")
	_setup_start()


func _setup_start() -> void:
	start_new_game_button.pressed.connect(func():
		GameManager.new_game())
	
	if !FileAccess.file_exists(SaverLoader.GAME_DATA_PATH + SaverLoader.current_slot + ".dat"):
		start_continue_button.hide()
	
	start_continue_button.pressed.connect(func():
		if !FileAccess.file_exists(SaverLoader.GAME_DATA_PATH + SaverLoader.current_slot + ".dat"):
			return
		SaverLoader.load_game_data(SaverLoader.current_slot))
	
	start_load_game_button.pressed.connect(func():
		var saves_menu_packed: PackedScene = load(saves_menu_uid)
		var saves_menu: Node = saves_menu_packed.instantiate()
		add_child(saves_menu)
		start.hide()
		saves_menu.tree_exiting.connect(func():
			start.show()
			InputManager.menu = self))
	
	start_settings_button.pressed.connect(func():
		var settings_menu_packed: PackedScene = load(settings_menu_uid)
		var settings_menu: Node = settings_menu_packed.instantiate()
		add_child(settings_menu)
		start.hide()
		settings_menu.tree_exiting.connect(func():
			start.show()
			InputManager.menu = self))
	
	start_chunk_button.pressed.connect(func():
		var map = ResourceUID.path_to_uid(maps[str(start_map_select.get_selected_id())])
		await Game.load_chunk(map)
		GameManager.load_player()
		self.queue_free())
	
	start_quit_button.pressed.connect(func():
		var accept_menu_packed: PackedScene = load(accept_menu_uid)
		var accept_menu: AcceptMenu = accept_menu_packed.instantiate()
		accept_menu.message = "Quit Game?"
		accept_menu.accept_text = "Yes"
		accept_menu.cancel_text = "No"
		add_child(accept_menu)
		accept_menu.accepted.connect(func():
			get_tree().quit())
		accept_menu.cancelled.connect(func():
			accept_menu.queue_free()
			InputManager.menu = self)
		InputManager.menu = accept_menu)


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
					start_map_select.add_item(file.rstrip(".tscn"), map_index)
		if new_folders:
			_setup_map_select(dir + str(folder) + "/", new_folders)
