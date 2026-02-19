extends Control


@onready var return_button: Button = %ReturnButton


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		return_button.pressed.emit()


func _ready() -> void:
	InputManager.menu = self
	return_button.pressed.connect(func():
		queue_free())
