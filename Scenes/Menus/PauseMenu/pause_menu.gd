extends Control


@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton


var previous_mouse_mode: DisplayServer.MouseMode


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		close()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	hide()
	resume_button.pressed.connect(func(): close())
	main_menu_button.pressed.connect(func():
		get_tree().paused = false
		GameManager.load_main_menu())


func open() -> void:
	show()
	previous_mouse_mode = DisplayServer.mouse_get_mode()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	InputManager.menu = self
	InputManager.menu_input = true


func close() -> void:
	hide()
	DisplayServer.mouse_set_mode(previous_mouse_mode)
	get_tree().paused = false
	InputManager.menu = null
	InputManager.menu_input = false
