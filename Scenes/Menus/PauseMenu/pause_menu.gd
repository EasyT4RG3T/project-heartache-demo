extends Control


@onready var menu: VBoxContainer = %Menu
@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var saves_button: Button = %SavesButton
@onready var main_menu_button: Button = %MainMenuButton

const settings_menu_uid: String = "uid://0ogoc8tlkqfx"
const saves_menu_uid: String = "uid://cs7mrt6rnpmfp"
const accept_menu_uid: String = "uid://dckjpcj38rsvw"

var previous_mouse_mode: DisplayServer.MouseMode


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		close()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	hide()
	resume_button.pressed.connect(func(): close())
	
	settings_button.pressed.connect(func():
		var settings_menu_packed: PackedScene = load(settings_menu_uid)
		var settings_menu: Node = settings_menu_packed.instantiate()
		add_child(settings_menu)
		menu.hide()
		settings_menu.tree_exiting.connect(func():
			menu.show()
			InputManager.menu = self))
	
	saves_button.pressed.connect(func():
		var saves_menu_packed: PackedScene = load(saves_menu_uid)
		var saves_menu: Node = saves_menu_packed.instantiate()
		add_child(saves_menu)
		menu.hide()
		saves_menu.tree_exiting.connect(func():
			menu.show()
			InputManager.menu = self))
	
	main_menu_button.pressed.connect(func():
		if SaverLoader.can_save > 0:
			var accept_menu_packed: PackedScene = load(accept_menu_uid)
			var accept_menu: AcceptMenu = accept_menu_packed.instantiate()
			accept_menu.message = "Cannot save at this moment/nQuit without saving?"
			accept_menu.accept_text = "Yes"
			accept_menu.cancel_text = "No"
			add_child(accept_menu)
			accept_menu.accepted.connect(func():
				SaverLoader.save_game_data(SaverLoader.current_slot)
				get_tree().paused = false
				GameManager.load_main_menu())
			accept_menu.cancelled.connect(func():
				accept_menu.queue_free()
				InputManager.menu = self)
			InputManager.menu = accept_menu
			return
		SaverLoader.save_game_data(SaverLoader.current_slot)
		get_tree().paused = false
		GameManager.load_main_menu())


func open() -> void:
	show()
	previous_mouse_mode = DisplayServer.mouse_get_mode()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	InputManager.menu = self


func close() -> void:
	hide()
	DisplayServer.mouse_set_mode(previous_mouse_mode)
	get_tree().paused = false
	InputManager.menu = null
