extends Control


func open() -> void:
	show()
	get_tree().paused = true
	InputManager.console_input = true


func close() -> void:
	hide()
	get_tree().paused = false
	InputManager.console_input = false


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_down"):
		print("console pg down")
