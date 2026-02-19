extends Control


@onready var intro: Control = %Intro
@onready var warnings: Control = %Warnings


func take_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if intro.visible:
			intro.hide()
			warnings.show()
		else:
			GameManager.load_main_menu()
			await get_tree().process_frame
			queue_free()
	elif event.is_action("escape") or event.is_action("spacebar") or event.is_action("enter")\
		 and event.is_pressed():
		if intro.visible:
			intro.hide()
			warnings.show()
		else:
			GameManager.load_main_menu()
			await get_tree().process_frame
			queue_free()


func _ready() -> void:
	InputManager.menu = self
	intro.show()
	warnings.hide()
	await get_tree().create_timer(2.0).timeout
	intro.hide()
	warnings.show()
	await get_tree().create_timer(2.0).timeout
	GameManager.load_main_menu()
	await get_tree().process_frame
	queue_free()
