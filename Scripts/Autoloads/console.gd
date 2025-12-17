extends Control


var previous_mouse_mode: DisplayServer.MouseMode


func _ready() -> void:
	hide()


func open() -> void:
	show()
	previous_mouse_mode = DisplayServer.mouse_get_mode()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	InputManager.console_input = true


func close() -> void:
	hide()
	DisplayServer.mouse_set_mode(previous_mouse_mode)
	get_tree().paused = false
	InputManager.console_input = false


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_down"):
		print("console pg down")
