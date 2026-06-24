extends Control


func take_input(event: InputEvent) -> void:
	if %ThanksText.modulate.a < 1: return
	if event is InputEventMouseButton and event.is_pressed():
		_go_next()
	elif event.is_action_pressed("escape") or event.is_action_pressed("spacebar") or event.is_action_pressed("enter"):
		_go_next()


func _ready() -> void:
	SaverLoader.hide_loading_screen()
	InputManager.menu = self
	%ThanksText.show()
	%ThanksText.modulate.a = 0.0
	%CreditsText.hide()


func _physics_process(delta: float) -> void:
	if %ThanksText.modulate.a < 1:
		%ThanksText.modulate.a += delta


func _go_next() -> void:
	if %ThanksText.visible:
		%ThanksText.hide()
		%CreditsText.show()
	elif %CreditsText.visible:
		Console.menu_hint = true
		GameManager.load_main_menu()
