extends Control


@onready var intro: Control = %Intro
@onready var warnings: Control = %Warnings


func take_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_go_next()
	elif event.is_action("escape") or event.is_action("spacebar") or event.is_action("enter") and event.is_pressed():
		_go_next()


func _ready() -> void:
	%BrightnessTest.hide()
	%BrightnessControl.hide()
	
	InputManager.menu = self
	intro.show()
	warnings.hide()
	
	%Timer.timeout.connect(func():
		_go_next())
	
	%Timer.start(5.0)


func _go_next() -> void:
	%Timer.start(5.0)
	if intro.visible:
		intro.hide()
		warnings.show()
	elif warnings.visible:
		warnings.hide()
		if SaverLoader.settings.first_time:
			_show_brightness()
		else:
			GameManager.load_main_menu()
			await get_tree().process_frame
			queue_free()


func _show_brightness() -> void:
	%BrightnessTest.show()
	%BrightnessControl.show()
	
	$ColorRect.hide()
	
	%BrightnessTest/Camera3D.make_current()
	
	%BrightnessHSlider.value = SaverLoader.graphics_settings.brightness
	%BrightnessHSlider.value_changed.connect(func(value: float):
		SaverLoader.graphics_settings.brightness = value
		GameManager.DEFAULT_ENVIRONMENT.adjustment_brightness = value)
	
	%Button.pressed.connect(func():
		SaverLoader.save_graphics_settings()
		GameManager.load_main_menu()
		await get_tree().process_frame
		queue_free())
