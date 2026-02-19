extends Control


const graphics_low: String = "uid://cutv363x14c4e"
const graphics_medium: String = "uid://cr40bmj55qsks"
const graphics_high: String = "uid://cn4cbbs6h71o1"


@onready var save_button: Button = %SaveButton
@onready var return_button: Button = %ReturnButton
@onready var default_button: Button = %DefaultButton
@onready var revert_button: Button = %RevertButton

var temp_settings: SettingsResource = SaverLoader.settings.duplicate(true)
var temp_graphics_settings: GraphicsSettingsResource = SaverLoader.graphics_settings.duplicate(true)

var sensitivity: float = temp_settings.sensitivity:
	set(value):
		value = clamp(value, 0.0, 100.0)
		sensitivity = value
		temp_settings.sensitivity = value
		%SensitivityHSlider.value = value
		%SensitivityLineEdit.text = str(value)
		unsaved = true
var max_fps: int = temp_settings.max_fps:
	set(value):
		value = clamp(value, 0, 999)
		max_fps = value
		temp_settings.max_fps = value
		%MaxFPSLineEdit.text = str(value)
		unsaved = true
var vsync: DisplayServer.VSyncMode = temp_settings.vsync:
	set(value):
		if value > 0:
			value = DisplayServer.VSyncMode.VSYNC_ENABLED
			%VsyncCheckButton.button_pressed = true
		else:
			value = DisplayServer.VSyncMode.VSYNC_DISABLED
			%VsyncCheckButton.button_pressed = false
		vsync = value
		temp_settings.vsync = value
		unsaved = true
var fov: int = temp_settings.fov:
	set(value):
		value = clamp(value, 50, 110)
		fov = value
		temp_settings.fov = value
		%FOVLineEdit.text = str(value)
		unsaved = true
var dynamic_fov: bool = temp_settings.dynamic_fov:
	set(value):
		dynamic_fov = value
		temp_settings.dynamic_fov = value
		%DynamicFOVCheckButton.button_pressed = value
		unsaved = true
var window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode():
	set(value):
		window_mode = value
		temp_settings.window_mode = value
		print(value)
		match value:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 2
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
		unsaved = true
var hud_size: float = temp_settings.hud_size:
	set(value):
		value = clamp(value, 0.5, 5)
		hud_size = value
		temp_settings.hud_size = value
		%HUDSizeLineEdit.text = str(value)
		unsaved = true
var static_shader: bool = temp_settings.static_shader:
	set(value):
		static_shader = value
		temp_settings.static_shader = value
		%StaticShaderCheckButton.button_pressed = value
		unsaved = true

var preset: GraphicsSettingsResource = null:
	set(value):
		preset = value
		temp_graphics_settings = value
		_set_all_settings(true)
		unsaved = true
		changed_graphics = true


var unsaved: bool = false:
	set(value):
		unsaved = value
		leave_unsaved = false
		return_button.text = "Return"
var changed_graphics: bool = false
var leave_unsaved: bool = false


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		return_button.pressed.emit()


func _ready() -> void:
	InputManager.menu = self
	
	_set_up_game()
	_set_up_controls()
	_set_up_graphics()
	_set_up_sound()
	
	save_button.pressed.connect(func():
		_save_settings())
	
	return_button.pressed.connect(func():
		if unsaved and !leave_unsaved:
			return_button.text = "Return unsaved"
			leave_unsaved = true
		else:
			queue_free())
	
	default_button.pressed.connect(func():
		_default_settings())
	
	revert_button.pressed.connect(func():
		_revert_settings())


func _set_up_game() -> void:
	%SensitivityHSlider.value = temp_settings.sensitivity
	%SensitivityHSlider.value_changed.connect(func(value: float):
		sensitivity = value)
	%SensitivityLineEdit.text = str(temp_settings.sensitivity)
	%SensitivityLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%SensitivityLineEdit.text.is_valid_float():
			%SensitivityLineEdit.text = str(sensitivity)
		sensitivity = %SensitivityLineEdit.text.to_float())
	%MaxFPSLineEdit.text = str(temp_settings.max_fps)
	%MaxFPSLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%MaxFPSLineEdit.text.is_valid_int():
			%MaxFPSLineEdit.text = str(max_fps)
		max_fps = %MaxFPSLineEdit.text.to_int())
	%VsyncCheckButton.button_pressed = true if temp_settings.vsync > 0 else false
	%VsyncCheckButton.pressed.connect(func():
		if %VsyncCheckButton.button_pressed:
			vsync = DisplayServer.VSyncMode.VSYNC_ENABLED
		else:
			vsync = DisplayServer.VSyncMode.VSYNC_DISABLED)
	%FOVLineEdit.text = str(temp_settings.fov)
	%FOVLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%FOVLineEdit.text.is_valid_int():
			%FOVLineEdit.text = str(fov)
		fov = %FOVLineEdit.text.to_int())
	%DynamicFOVCheckButton.button_pressed = temp_settings.dynamic_fov
	%DynamicFOVCheckButton.pressed.connect(func():
		dynamic_fov = %DynamicFOVCheckButton.button_pressed)
	temp_settings.window_mode = DisplayServer.window_get_mode()
	get_viewport().size_changed.connect(func():
		temp_settings.window_mode = DisplayServer.window_get_mode()
		match temp_settings.window_mode:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 2
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
		)
	match temp_settings.window_mode:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 2
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
	%WindowModeOptionButton.item_selected.connect(func(index: int):
		match index:
			0:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
			1:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
			2:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
			3:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		)
	%HUDSizeLineEdit.text = str(temp_settings.hud_size)
	%HUDSizeLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%HUDSizeLineEdit.text.is_valid_float():
			%HUDSizeLineEdit.text = str(hud_size)
		hud_size = %HUDSizeLineEdit.text.to_float())
	%StaticShaderCheckButton.button_pressed = temp_settings.static_shader
	%StaticShaderCheckButton.pressed.connect(func():
		static_shader = %StaticShaderCheckButton.button_pressed)


func _set_up_controls() -> void:
	pass


func _set_up_graphics() -> void:
	%PresetButtonLow.pressed.connect(func():
		preset = load(graphics_low))
	%PresetButtonMedium.pressed.connect(func():
		preset = load(graphics_medium))
	%PresetButtonHigh.pressed.connect(func():
		preset = load(graphics_high))


func _set_up_sound() -> void:
	pass


func _default_settings() -> void:
	temp_settings = SettingsResource.new()
	
	_set_all_settings()


func _revert_settings() -> void:
	temp_settings = SaverLoader.settings.duplicate(true)
	temp_graphics_settings = SaverLoader.graphics_settings.duplicate(true)
	
	_set_all_settings(true)


func _set_all_settings(graphics: bool = false) -> void:
	sensitivity = temp_settings.sensitivity
	max_fps = temp_settings.max_fps
	vsync = temp_settings.vsync
	fov = temp_settings.fov
	dynamic_fov = temp_settings.dynamic_fov
	window_mode = temp_settings.window_mode
	hud_size = temp_settings.hud_size
	static_shader = temp_settings.static_shader
	
	if !graphics: return
	
	## graphics settings


func _save_settings() -> void:
	unsaved = false
	SaverLoader.settings = temp_settings.duplicate(true)
	SaverLoader.save_settings()
	GameManager.apply_settings_data()
	if changed_graphics:
		SaverLoader.graphics_settings = temp_graphics_settings.duplicate(true)
		SaverLoader.save_graphics_settings()
		GameManager.apply_graphics_settings_data()
