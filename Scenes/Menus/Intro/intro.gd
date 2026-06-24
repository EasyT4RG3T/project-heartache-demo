extends Control


@onready var intro: Control = %Intro
@onready var warnings: Control = %Warnings
@onready var hud: Control = %Hud

var blink: float = 0.0


func take_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		_go_next()
	elif event.is_action_pressed("escape") or event.is_action_pressed("spacebar") or event.is_action_pressed("enter"):
		_go_next()


func _ready() -> void:
	%BrightnessTest.hide()
	%BrightnessControl.hide()
	
	InputManager.menu = self
	intro.show()
	warnings.hide()
	hud.hide()
	
	%Timer.timeout.connect(func():
		_go_next())
	
	%Timer.start(3.0)


func _physics_process(delta: float) -> void:
	blink += delta
	queue_redraw()


func _go_next() -> void:
	%Timer.start(5.0)
	if intro.visible:
		intro.hide()
		warnings.show()
	elif warnings.visible:
		warnings.hide()
		if SaverLoader.settings.first_time:
			_show_hud()
		else:
			GameManager.load_main_menu()
			await get_tree().process_frame
			queue_free()


func _show_hud() -> void:
	hud.show()
	%ThoughtLabel.offset_top = 2.0 + 50.0 * SaverLoader.settings.hud_size
	
	%PersistentCrosshairCheckButton.pressed.connect(func():
		SaverLoader.settings.persistent_crosshair = %PersistentCrosshairCheckButton.button_pressed)
	
	%HUDSizeLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%HUDSizeLineEdit.text.is_valid_float():
			%HUDSizeLineEdit.text = str(SaverLoader.settings.hud_size)
		SaverLoader.settings.hud_size = %HUDSizeLineEdit.text.to_float()
		%ThoughtLabel.add_theme_font_size_override("normal_font_size", 25 * SaverLoader.settings.hud_size)
		%ThoughtLabel.offset_top = 2.0 + 50.0 * SaverLoader.settings.hud_size)
	
	%SubtitlesSizeLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%SubtitlesSizeLineEdit.text.is_valid_int():
			%SubtitlesSizeLineEdit.text = str(SaverLoader.settings.subtitles)
		SaverLoader.settings.subtitles = %SubtitlesSizeLineEdit.text.to_int()
		%ExampleText.text = "[font_size="+str(SaverLoader.settings.subtitles)+"]Example Text[/font_size]")
	
	%HudButton.pressed.connect(func():
		SaverLoader.save_settings()
		hud.hide()
		_show_brightness())


func _draw() -> void:
	if !hud.visible: return
	if blink > 2:
		blink = 0.0
	if blink > 1 and !SaverLoader.settings.persistent_crosshair: return
	var center = get_viewport().get_visible_rect().size / 2
	center -= Vector2(15, 15)
	if SaverLoader.settings.persistent_crosshair:
		draw_circle(center, 3.0 * SaverLoader.settings.hud_size, Color.DIM_GRAY * Color(1, 1, 1, 0.8))
		draw_circle(center, 2.0 * SaverLoader.settings.hud_size, Color.LIGHT_GRAY * Color(1, 1, 1, 0.8))
	else:
		draw_circle(center, 4.0 * SaverLoader.settings.hud_size, Color.DIM_GRAY * Color(1, 1, 1, 0.8))
		draw_circle(center, 3.0 * SaverLoader.settings.hud_size, Color.LIGHT_GRAY * Color(1, 1, 1, 0.8))


func _show_brightness() -> void:
	%BrightnessTest.show()
	%BrightnessControl.show()
	
	$ColorRect.hide()
	
	%BrightnessTest/Camera3D.make_current()
	
	%BrightnessHSlider.value = SaverLoader.graphics_settings.brightness
	%BrightnessHSlider.value_changed.connect(func(value: float):
		SaverLoader.graphics_settings.brightness = value
		GameManager.DEFAULT_ENVIRONMENT.adjustment_brightness = value)
	
	%BrightnessButton.pressed.connect(func():
		SaverLoader.save_graphics_settings()
		GameManager.load_main_menu()
		await get_tree().process_frame
		queue_free())
